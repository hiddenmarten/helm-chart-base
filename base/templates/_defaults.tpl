{{/*
Default template for baserary chart
Usage: {{ include "base.defaults" (dict "ctx" $ctx) }}
*/}}
{{ define "base.defaults" -}}
{{ $ctx := .ctx }}
# Put them to global?
nameOverride: ""
fullnameOverride: ""

deployment:
  spec:
    replicas: 1
    template:
      spec:
        container: {}

serviceAccount: {}
service: {}
ingress: {}
serviceMonitor: {}
configMaps:
  envVars: {}
  files: {}
secrets:
  envVars: {}
  files: {}
persistentVolumeClaims: {}
{{- end }}
