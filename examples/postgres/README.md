# postgres

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

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
| statefulset.spec.volumeClaimTemplates.data.mount.mountPath | string | `"/var/lib/postgresql/data"` |  |
| statefulset.spec.volumeClaimTemplates.data.spec.resources.requests.storage | string | `"20Gi"` |  |

