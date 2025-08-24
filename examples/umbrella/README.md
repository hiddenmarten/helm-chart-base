# umbrella

![Version: 0.0.1](https://img.shields.io/badge/Version-0.0.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

An umbrella chart for vault-postgres stack

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../postgres | postgres | 0.0.1 |
| file://../vault | vault | 0.0.1 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| postgres.configMaps.files.data."/docker-entrypoint-initdb.d/001-vault-schema.sql" | string | `"CREATE DATABASE vault;\n\\c vault;\n\nCREATE TABLE vault_kv_store (\n  parent_path TEXT COLLATE \"C\" NOT NULL,\n  path        TEXT COLLATE \"C\",\n  key         TEXT COLLATE \"C\",\n  value       BYTEA,\n  CONSTRAINT pkey PRIMARY KEY (path, key)\n);\n\nCREATE INDEX parent_path_idx ON vault_kv_store (parent_path);\n"` |  |
| vault.configMaps.files.data."/vault/config/config.json".storage.postgresql.connection_url | string | `"postgres://postgres:postgres@umbrella-postgres:5432/vault?sslmode=disable"` |  |

