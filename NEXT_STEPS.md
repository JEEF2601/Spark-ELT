# Proximos pasos de estabilizacion

## Estado actual

La logica principal de `influx_to_r2` y `cryptocompare_to_r2` ya fue migrada a `spark-jobs/jobs/`.

## Fase 1: Validacion funcional

1. Ejecutar `influx_to_r2.py` en runtime de jobs y validar salida en R2.
2. Ejecutar `cryptocompare_to_r2.py` y validar capas bronze/silver en R2.
3. Completar implementacion real de `daily_aggregation.py`.
4. Confirmar ejecucion desde Dagster con `SPARK_RUNNER_MODE=ssh`.

## Fase 2: Compartir codigo comun

1. Mover utilidades repetidas a `common/spark_session.py` y `common/utils.py`.
2. Estandarizar logging y manejo de errores.
3. Hacer validacion de config al inicio de cada job.

## Fase 3: Calidad y despliegue

1. Agregar tests unitarios para transformaciones puras.
2. Configurar CI (lint + tests).
3. Publicar imagen Docker o paquete interno del repositorio `spark-jobs`.

## Fase 4: Limpieza final en Dagster

1. Eliminar codigo Spark residual del repo Dagster.
2. Dejar solo la orquestacion (ops/jobs/schedules) y el runner.
3. Mantener `job_registry.yaml` como contrato entre ambos repositorios.
