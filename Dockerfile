FROM apache/spark:4.0.1-python3

USER root

WORKDIR /opt/spark-jobs

RUN apt-get update \
	&& apt-get install -y --no-install-recommends git \
	&& rm -rf /var/lib/apt/lists/*

# La imagen base trae pip 22; lo actualizamos para evitar fallos con installs VCS.
RUN python3 -m pip install --no-cache-dir --upgrade pip setuptools wheel

# Instalar dependencias Python primero (mejor cache de capas)
COPY Spark-ELT/requirements.txt .
RUN python3 -m pip install --no-cache-dir -r requirements.txt

# Instalar paquete etl-jobs desde repositorio GitHub
ARG ETL_JOBS_GIT_URL=https://github.com/JEEF2601/etl-jobs.git
ARG ETL_JOBS_VERSION=v0.1.0
RUN python3 -m pip install --no-cache-dir git+${ETL_JOBS_GIT_URL}@${ETL_JOBS_VERSION}

USER spark
