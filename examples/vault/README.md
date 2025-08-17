# vault

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

A HashiCorp Vault helm chart using base

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../../base-test | base-test | 0.0.1 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| base-test.configMaps.files.data."/vault/config.d/config.json".disable_mlock | bool | `true` |  |
| base-test.configMaps.files.data."/vault/config.d/config.json".storage.file.path | string | `"/vault/file"` |  |
| base-test.configMaps.files.data."/vault/config.d/config.json".ui | bool | `true` |  |
| base-test.image.repository | string | `"hashicorp/vault"` |  |
| base-test.image.tag | string | `"1.20.2"` |  |
| base-test.ingress.spec.rules."vault.example.local".http.paths./.backend.service.port.name | string | `"http"` |  |
| base-test.ingress.spec.rules."vault.example.local".tls.secretName | string | `"vault-tls-secret"` |  |
| base-test.persistentVolumeClaims.file.mount.mountPath | string | `"/vault/file"` |  |
| base-test.persistentVolumeClaims.file.spec.resources.requests.storage | string | `"1Gi"` |  |
| base-test.secrets.envVars.data.VAULT_DEV_ROOT_TOKEN_ID | string | `"root"` |  |
| base-test.service.spec.ports.http.port | int | `8200` |  |
| base-test.serviceMonitor.spec.endpoints.http.path | string | `"/sys/metrics"` |  |

