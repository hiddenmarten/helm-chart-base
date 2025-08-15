# vault

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

A HashiCorp Vault helm chart using base

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../../base | base | 0.0.1 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| base.configMap.files."/vault/config.d/config.json".disable_mlock | bool | `true` |  |
| base.configMap.files."/vault/config.d/config.json".storage.file.path | string | `"{{ .Values.base.persistentVolumeClaims.data.mount.mountPath }}"` |  |
| base.configMap.files."/vault/config.d/config.json".ui | bool | `true` |  |
| base.image.repository | string | `"hashicorp/vault"` |  |
| base.image.tag | string | `"1.20.2"` |  |
| base.ingress.spec.rules."vault.example.local".tls.secretName | string | `"vault-tls-secret"` |  |
| base.persistentVolumeClaims.data.mount.mountPath | string | `"/vault/data"` |  |
| base.persistentVolumeClaims.data.spec.resources.requests.storage | string | `"1Gi"` |  |
| base.secrets.envVars.VAULT_DEV_ROOT_TOKEN_ID | string | `"root"` |  |
| base.service.spec.ports.http.port | int | `8200` |  |
| base.serviceMonitor.spec.endpoints.http.path | string | `"/sys/metrics"` |  |

