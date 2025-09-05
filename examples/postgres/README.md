# postgres

![Version: 0.0.1](https://img.shields.io/badge/Version-0.0.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

An example of Postgres using base library

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../../base | base | 0.0.1 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| secrets.envVars.data.POSTGRES_PASSWORD | string | `"postgres"` |  |
| service.spec.ports.tcp.port | int | `5432` |  |
| statefulset.spec.template.spec.containers.postgres.image.repository | string | `"postgres"` |  |
| statefulset.spec.template.spec.containers.postgres.image.tag | string | `"17.6"` |  |
| statefulset.spec.template.spec.initContainers.db-migrate.command[0] | string | `"sh"` |  |
| statefulset.spec.template.spec.initContainers.db-migrate.command[1] | string | `"-c"` |  |
| statefulset.spec.template.spec.initContainers.db-migrate.command[2] | string | `"until pg_isready -h db; do sleep 1; done"` |  |
| statefulset.spec.template.spec.initContainers.db-migrate.image.repository | string | `"migrate/migrate"` |  |
| statefulset.spec.volumeClaimTemplates.data.mount.mountPath | string | `"/var/lib/postgresql/data"` |  |
| statefulset.spec.volumeClaimTemplates.data.spec.resources.requests.storage | string | `"20Gi"` |  |

