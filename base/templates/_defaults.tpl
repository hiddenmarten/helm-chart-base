{{/*
Default template for baserary chart
Usage: {{ include "base.defaults" (dict "ctx" $ctx) }}
*/}}
{{ define "base.defaults" -}}
{{ $ctx := .ctx }}
# Put them to global?
nameOverride: ""
fullnameOverride: ""

# Workload section
replicaCount: 1
image: {}
securityContext: {}
resources: {}
livenessProbe: {}
readinessProbe: {}
imagePullSecrets: []
nodeSelector: {}
tolerations: []
affinity: {}
pod:
  annotations: {}
  labels: {}
  securityContext: {}

# Non-workload
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
