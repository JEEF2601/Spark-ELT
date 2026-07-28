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
	wget -nv -O /opt/spark/local-jars/wildfly-openssl-2.1.4.Final.jar https://repo1.maven.org/maven2/org/wildfly/openssl/wildfly-openssl/2.1.4.Final/wildfly-openssl-2.1.4.Final.jar; \
	wget -nv -O /opt/spark/local-jars/postgresql-42.7.4.jar https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.4/postgresql-42.7.4.jar

# La imagen base trae pip 22; lo actualizamos para evitar fallos con installs VCS.
RUN python3 -m pip install --no-cache-dir --upgrade pip setuptools wheel

# Instalar dependencias Python primero (mejor cache de capas)
COPY requirements.txt .
RUN python3 -m pip install --no-cache-dir -r requirements.txt

# Instalar paquete etl-jobs desde repositorio GitHub
ARG ETL_JOBS_GIT_URL=https://github.com/JEEF2601/etl-jobs.git
ARG ETL_JOBS_VERSION=v0.1.4
RUN python3 -m pip install --no-cache-dir git+${ETL_JOBS_GIT_URL}@${ETL_JOBS_VERSION}

USER spark
