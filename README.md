# spark-jobs

Repositorio de jobs de Spark desacoplado de Dagster.

## Estructura

```text
spark-jobs/
|- jobs/
|- common/
|- configs/
|- job_registry.yaml
|- requirements.txt
|- pyproject.toml
`- setup.py
```

## Ejecucion local de un job

```bash
spark-submit jobs/influx_to_r2.py
```

## Variables de entorno de jobs

Las variables de conexion de datos y runtime Spark viven en este repositorio.

1. Copia `spark-jobs/.env.example` a tu archivo de entorno de jobs.
2. Completa credenciales de InfluxDB y R2.
3. Ejecuta los jobs con ese entorno cargado.

## Registro de jobs

El archivo `job_registry.yaml` define `entrypoint`, `params` y configuracion Spark por job.
Dagster consume este registro para ejecutar cada job por nombre.

## Siguiente paso

Revisa `NEXT_STEPS.md` para el plan de migracion recomendado.
