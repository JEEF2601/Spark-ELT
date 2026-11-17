#!/usr/bin/env bash
set -Eeuo pipefail

SPARK_HOME="${SPARK_HOME:-/opt/spark}"
MASTER_HOST="${SPARK_MASTER_HOST:-spark-master}"
MASTER_PORT="${SPARK_MASTER_PORT:-7077}"
MASTER_WEBUI_PORT="${SPARK_MASTER_WEBUI_PORT:-8180}"

MASTER_PID=""

cleanup() {
    echo "Deteniendo Spark Master..."
    if [[ -n "$MASTER_PID" ]] && kill -0 "$MASTER_PID" 2>/dev/null; then
        kill "$MASTER_PID" 2>/dev/null || true
    fi
    [[ -z "$MASTER_PID" ]] || wait "$MASTER_PID" 2>/dev/null || true
}

trap cleanup EXIT
trap 'exit 0' SIGTERM SIGINT

echo "Iniciando Spark Master..."

"$SPARK_HOME/bin/spark-class" \
    org.apache.spark.deploy.master.Master \
    --host "$MASTER_HOST" \
    --port "$MASTER_PORT" \
    --webui-port "$MASTER_WEBUI_PORT" &

MASTER_PID=$!

echo "Esperando disponibilidad del Master..."

for i in $(seq 1 30); do
    if ! kill -0 "$MASTER_PID" 2>/dev/null; then
        echo "ERROR: Spark Master terminó inesperadamente."
        exit 1
    fi

    if (echo > "/dev/tcp/$MASTER_HOST/$MASTER_PORT") 2>/dev/null; then
        break
    fi

    if [[ "$i" -eq 30 ]]; then
        echo "ERROR: Timeout esperando Spark Master."
        exit 1
    fi

    sleep 1
done

echo "Spark Master disponible en spark://$MASTER_HOST:$MASTER_PORT. Monitoreando..."

wait "$MASTER_PID"
