FROM apache/spark:4.0.1-python3

USER root

WORKDIR /opt/spark-jobs

# Instalar dependencias Python primero (mejor cache de capas)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar codigo del proyecto e instalar como paquete
COPY . .
RUN pip install --no-cache-dir -e .

USER spark
