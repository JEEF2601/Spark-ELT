FROM apache/spark:4.0.1-python3

USER root

WORKDIR /opt/spark-jobs

RUN apt-get update \
	&& apt-get install -y --no-install-recommends ca-certificates git wget \
	&& rm -rf /var/lib/apt/lists/*

RUN set -eux; \
	mkdir -p /opt/spark/local-jars; \
	wget -nv -O /opt/spark/local-jars/hadoop-aws-3.4.1.jar https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.4.1/hadoop-aws-3.4.1.jar; \
	wget -nv -O /opt/spark/local-jars/bundle-2.29.52.jar https://repo1.maven.org/maven2/software/amazon/awssdk/bundle/2.29.52/bundle-2.29.52.jar; \
	wget -nv -O /opt/spark/local-jars/analyticsaccelerator-s3-1.2.1.jar https://repo1.maven.org/maven2/software/amazon/s3/analyticsaccelerator/analyticsaccelerator-s3/1.2.1/analyticsaccelerator-s3-1.2.1.jar; \
	wget -nv -O /opt/spark/local-jars/wildfly-openssl-2.1.4.Final.jar https://repo1.maven.org/maven2/org/wildfly/openssl/wildfly-openssl/2.1.4.Final/wildfly-openssl-2.1.4.Final.jar

# La imagen base trae pip 22; lo actualizamos para evitar fallos con installs VCS.
RUN python3 -m pip install --no-cache-dir --upgrade pip setuptools wheel

# Instalar dependencias Python primero (mejor cache de capas)
COPY requirements.txt .
RUN python3 -m pip install --no-cache-dir -r requirements.txt

# Instalar paquete etl-jobs desde repositorio GitHub
ARG ETL_JOBS_GIT_URL=https://github.com/JEEF2601/etl-jobs.git
ARG ETL_JOBS_VERSION=v0.1.4
RUN python3 -m pip install --no-cache-dir git+${ETL_JOBS_GIT_URL}@${ETL_JOBS_VERSION}

# Exponer los archivos del paquete etl_jobs en WORKDIR (/opt/spark-jobs/) para que
# spark-submit invocado via `docker exec` pueda resolverlos por ruta absoluta sin
# depender del classpath Python. Esto es necesario cuando Dagster (en VPS remota) usa
# SPARK_RUNNER_MODE=docker_ssh y pasa rutas como /opt/spark-jobs/jobs/influx_to_r2.py.
RUN python3 - <<'EOF'
import etl_jobs, shutil, os
src = os.path.dirname(os.path.abspath(etl_jobs.__file__))
dst = "/opt/spark-jobs"
for root, _dirs, files in os.walk(src):
    for fname in files:
        if fname.endswith(".py"):
            rel = os.path.relpath(os.path.join(root, fname), src)
            dest_path = os.path.join(dst, rel)
            os.makedirs(os.path.dirname(dest_path), exist_ok=True)
            shutil.copy2(os.path.join(root, fname), dest_path)
EOF

USER spark
