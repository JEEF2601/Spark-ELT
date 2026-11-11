#!/usr/bin/env bash
set -Eeuo pipefail

SPARK_HOME="${SPARK_HOME:-/opt/spark}"
MASTER_HOST="${SPARK_MASTER_HOST:-spark-master}"
MASTER_PORT="${SPARK_MASTER_PORT:-7077}"
MASTER_WEBUI_PORT="${SPARK_MASTER_WEBUI_PORT:-8180}"
CONNECT_PORT="${SPARK_CONNECT_PORT:-15002}"

MASTER_PID=""
CONNECT_PID=""

cleanup() {
    echo "Deteniendo servicios Spark..."

    if [[ -n "$CONNECT_PID" ]] && kill -0 "$CONNECT_PID" 2>/dev/null; then
        kill "$CONNECT_PID" 2>/dev/null || true
    fi

    if [[ -n "$MASTER_PID" ]] && kill -0 "$MASTER_PID" 2>/dev/null; then
        kill "$MASTER_PID" 2>/dev/null || true
    fi

    [[ -z "$CONNECT_PID" ]] || wait "$CONNECT_PID" 2>/dev/null || true
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

    if (echo > "/dev/tcp/127.0.0.1/$MASTER_PORT") 2>/dev/null; then
        break
    fi

    if [[ "$i" -eq 30 ]]; then
        echo "ERROR: Timeout esperando Spark Master."
        exit 1
    fi

    sleep 1
done

echo "Spark Master disponible en spark://$MASTER_HOST:$MASTER_PORT"

echo "Iniciando Spark Connect..."

"$SPARK_HOME/sbin/start-connect-server.sh" --wait \
    --master "spark://$MASTER_HOST:$MASTER_PORT" \
    --conf "spark.connect.grpc.binding.port=$CONNECT_PORT" \
    --conf "spark.connect.grpc.binding.address=0.0.0.0" &

CONNECT_PID=$!

echo "Spark Connect iniciado. Monitoreando servicios..."

# El contenedor debe terminar si cualquiera de los dos servicios falla.
wait -n "$MASTER_PID" "$CONNECT_PID"

echo "ERROR: Uno de los servicios Spark terminó inesperadamente."
exit 1
