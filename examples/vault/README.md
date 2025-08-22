# vault

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

A HashiCorp Vault using base library

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../../base | base | 0.0.1 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| configMaps.files.data."/vault/config.d/config.json".disable_mlock | bool | `true` |  |
| configMaps.files.data."/vault/config.d/config.json".storage.file.path | string | `"/vault/file"` |  |
| configMaps.files.data."/vault/config.d/config.json".ui | bool | `true` |  |
| deployment.spec.template.spec.containers.vault.image.repository | string | `"hashicorp/vault"` |  |
| deployment.spec.template.spec.containers.vault.image.tag | string | `"1.20.2"` |  |
| ingress.spec.rules."vault.example.local".http.paths./.backend.service.port.name | string | `"http"` |  |
| ingress.spec.rules."vault.example.local".tls.secretName | string | `"vault-tls-secret"` |  |
| persistentVolumeClaims.file.mount.mountPath | string | `"/vault/file"` |  |
| persistentVolumeClaims.file.spec.resources.requests.storage | string | `"1Gi"` |  |
| secrets.envVars.data.VAULT_DEV_ROOT_TOKEN_ID | string | `"root"` |  |
| service.spec.ports.http.port | int | `8200` |  |
| serviceMonitor.spec.endpoints.http.path | string | `"/sys/metrics"` |  |

