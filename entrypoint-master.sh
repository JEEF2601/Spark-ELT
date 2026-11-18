#!/usr/bin/env bash
# Script para iniciar Spark Master únicamente.
# No utiliza Spark Connect (eliminado por requerimientos de arquitectura).

set -Eeuo pipefail

SPARK_HOME="${SPARK_HOME:-/opt/spark}"
MASTER_HOST="${SPARK_MASTER_HOST:-spark-master}"
MASTER_PORT="${SPARK_MASTER_PORT:-7077}"
MASTER_WEBUI_PORT="${SPARK_MASTER_WEBUI_PORT:-8180}"

echo "Iniciando Spark Master..."
echo "Configuración: --host $MASTER_HOST --port $MASTER_PORT --webui-port $MASTER_WEBUI_PORT"

# Iniciamos el Master en primer plano para que Docker pueda supervisar el proceso directamente.
exec "$SPARK_HOME/bin/spark-class" \
    org.apache.spark.deploy.master.Master \
    --host "$MASTER_HOST" \
    --port "$MASTER_PORT" \
    --webui-port "$MASTER_WEBUI_PORT"
