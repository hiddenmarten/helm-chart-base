# mono

![Version: 0.0.1](https://img.shields.io/badge/Version-0.0.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

A mono chart for vault-postgres stack

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../../base | base | 0.0.1 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| postgres.configMaps.files.data."/docker-entrypoint-initdb.d/001-vault-schema.sql" | string | `"CREATE DATABASE vault;\n\\c vault;\n\nCREATE TABLE vault_kv_store (\n  parent_path TEXT COLLATE \"C\" NOT NULL,\n  path        TEXT COLLATE \"C\",\n  key         TEXT COLLATE \"C\",\n  value       BYTEA,\n  CONSTRAINT pkey PRIMARY KEY (path, key)\n);\n\nCREATE INDEX parent_path_idx ON vault_kv_store (parent_path);\n"` |  |
| postgres.nameOverride | string | `"postgres"` |  |
| postgres.secrets.envVars.data.POSTGRES_PASSWORD | string | `"postgres"` |  |
| postgres.service.spec.ports.tcp.port | int | `5432` |  |
| postgres.statefulset.spec.template.metadata.annotations."base.chart.hiddenmarten.me/config-maps-hash" | string | `""` |  |
| postgres.statefulset.spec.template.spec.containers.postgres.image.repository | string | `"postgres"` |  |
| postgres.statefulset.spec.template.spec.containers.postgres.image.tag | string | `"17.6"` |  |
| postgres.statefulset.spec.volumeClaimTemplates.data.mount.mountPath | string | `"/var/lib/postgresql/data"` |  |
| postgres.statefulset.spec.volumeClaimTemplates.data.spec.resources.requests.storage | string | `"20Gi"` |  |
| vault.configMaps.files.data."/vault/config/config.json".disable_mlock | bool | `true` |  |
| vault.configMaps.files.data."/vault/config/config.json".storage.postgresql.connection_url | string | `"postgres://postgres:postgres@mono-postgres:5432/vault?sslmode=disable"` |  |
| vault.configMaps.files.data."/vault/config/config.json".ui | bool | `true` |  |
| vault.deployment.spec.template.spec.containers.vault.image.repository | string | `"hashicorp/vault"` |  |
| vault.deployment.spec.template.spec.containers.vault.image.tag | string | `"1.20.2"` |  |
| vault.ingress.spec.rules."vault.example.local".http.paths./.backend.service.port.name | string | `"http"` |  |
| vault.ingress.spec.rules."vault.example.local".tls.secretName | string | `"vault-tls-secret"` |  |
| vault.nameOverride | string | `"vault"` |  |
| vault.secrets.envVars.data.VAULT_DEV_ROOT_TOKEN_ID | string | `"root"` |  |
| vault.service.spec.ports.http.port | int | `8200` |  |
| vault.serviceMonitor.spec.endpoints.http.path | string | `"/sys/metrics"` |  |

