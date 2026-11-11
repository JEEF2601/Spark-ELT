#!/bin/bash

# Cargar variables de entorno para Spark si existen
# SPARK_MASTER_PORT=${SPARK_MASTER_PORT:-7077}
# SPARK_MASTER_WEBUI_PORT=${SPARK_MASTER_WEBUI_PORT:-8180}
# SPARK_CONNECT_PORT=${SPARK_CONNECT_PORT:-15002}

echo "Iniciando Spark Master..."
/opt/spark/bin/spark-class org.apache.spark.deploy.master.Master \
    --host $(hostname) \
    --port 7077 \
    --webui-port 8180 &

# Esperar a que el Master esté listo
sleep 5

echo "Iniciando Spark Connect Server..."
# Usamos el script oficial de Spark para iniciar el servidor de Connect
/opt/spark/sbin/start-connect-server.sh \
    --master spark://$(hostname):7077 \
    --conf spark.connect.grpc.binding.port=15002 \
    --conf spark.connect.grpc.binding.address=0.0.0.0

# Mantener el script vivo y monitorear procesos
# start-connect-server.sh corre en background por defecto, 
# pero podemos monitorear el log o simplemente esperar.
# Para que Docker no se detenga, esperamos al proceso del Master o el de Connect.

echo "Servidores iniciados. Monitoreando..."

# Función para limpieza al recibir señales de stop
_term() { 
  echo "Deteniendo servicios Spark..."
  /opt/spark/sbin/stop-connect-server.sh
  # El Master se detendrá al caer el contenedor o podemos matarlo explícitamente
  pkill -f org.apache.spark.deploy.master.Master
  exit 0
}

trap _term SIGTERM SIGINT

# Spark Connect genera un archivo pid en /opt/spark/pids/ si está configurado, 
# o podemos simplemente esperar.
while true; do
  ps aux | grep -q "org.apache.spark.deploy.master.Master" || exit 1
  ps aux | grep -q "org.apache.spark.sql.connect.service.SparkConnectServer" || exit 1
  sleep 10
done
