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
| base.image.pullPolicy | string | `"IfNotPresent"` |  |
| base.image.repository | string | `"hashicorp/vault"` |  |
| base.image.tag | string | `"1.20.2"` |  |
| base.ingress.spec.rules."vault.example.local".tls.secretName | string | `"vault-tls-secret"` |  |
| base.service.spec.ports.http.port | int | `8200` |  |

