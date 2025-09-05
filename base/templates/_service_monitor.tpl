{{/*Add optional hashes from `secrets` and `configMaps`, both of them have to go through tpl before calculating hash itself
ServiceMonitor template for baserary chart
Usage: {{ include "base.serviceMonitor" (dict "ctx" $ctx) }}
*/}}
{{ define "base.serviceMonitor" -}}
{{ $ctx := .ctx -}}
{{ $serviceMonitor := include "base.serviceMonitor.merged" (dict "ctx" $ctx) | fromYaml -}}
{{ $unit := include "base.serviceMonitor.unit" (dict "serviceMonitor" $serviceMonitor "ctx" $ctx) | fromYaml -}}
{{ if and $unit.enabled $unit.spec.endpoints -}}
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
{{ $_ := unset $unit "enabled" -}}
{{ $unit | toYaml }}
---
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base.serviceMonitor.unit" (dict "serviceMonitor" $serviceMonitor "ctx" $ctx) }}
*/}}
{{ define "base.serviceMonitor.unit" -}}
{{ $serviceMonitor := .serviceMonitor -}}
{{ $ctx := .ctx -}}
{{ $override := include "base.serviceMonitor.override" (dict "serviceMonitor" $serviceMonitor "ctx" $ctx) | fromYaml -}}
{{ $unit := mustMergeOverwrite $serviceMonitor $override -}}
{{ if not $unit.metadata.annotations -}}
{{ $_ := unset $unit.metadata "annotations" -}}
{{- end }}
{{ tpl ($unit | toYaml) $ctx.abs }}
{{- end }}

{{/*
Usage: {{ include "base.serviceMonitor.payload" (dict "unit" $unit "ctx" $ctx) }}
*/}}
{{ define "base.serviceMonitor.override" -}}
{{ $serviceMonitor := .serviceMonitor -}}
{{ $ctx := .ctx -}}
{{ $endpoints := include "base.serviceMonitor.endpoints" (dict "endpoints" $serviceMonitor.spec.endpoints "ctx" $ctx) | fromYaml -}}
{{ $override := dict "spec" $endpoints -}}
{{ $override | toYaml }}
{{- end }}

{{/*
Usage: {{ include "base.serviceMonitor.endpoints" (dict "endpoints" $endpoints "ctx" $ctx) }}
*/}}
{{ define "base.serviceMonitor.endpoints" -}}
{{ $endpoints := .endpoints -}}
{{ $ctx := .ctx -}}
{{ $endpointsList := list -}}
{{- range $k, $v := $endpoints }}
{{ $endpoint := $v -}}
{{ if not $endpoint.port -}}
{{ $_ := set $endpoint "port" $k -}}
{{ end -}}
{{ $endpointsList = append $endpointsList $endpoint -}}
{{- end }}
{{ if $endpointsList -}}
selector:
  matchLabels: {{ include "base.selectorLabels" (dict "ctx" $ctx) | nindent 4 }}
endpoints: {{ $endpointsList | toYaml | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base.serviceMonitor.default" (dict "ctx" $ctx) }}
*/}}
{{ define "base.serviceMonitor.default" -}}
{{ $ctx := .ctx -}}
enabled: true
metadata:
  name: {{ include "base.fullname" (dict "ctx" $ctx) }}
  labels: {{ include "base.labels" (dict "ctx" $ctx) | nindent 4 }}
  annotations: {}
spec:
  endpoints: {}
{{- end }}

{{/*
Usage: {{ $serviceMonitor := include "base.serviceMonitor.merged" (dict "ctx" $ctx) | fromYaml -}}
*/}}
{{ define "base.serviceMonitor.merged" -}}
{{ $ctx := .ctx -}}
{{ $default := include "base.serviceMonitor.default" (dict "ctx" $ctx) | fromYaml -}}
{{ $serviceMonitor := $ctx.val.serviceMonitor | default dict }}
{{ mustMergeOverwrite $default $serviceMonitor | toYaml }}
{{- end }}
