{{/*Add optional hashes from `secrets` and `configMaps`, both of them have to go through tpl before calculating hash itself
ServiceMonitor template for baserary chart
Usage: {{ include "base.serviceMonitor" (dict "ctx" $ctx) }}
*/}}
{{ define "base.serviceMonitor" -}}
{{ $ctx := .ctx -}}
{{ $serviceMonitor := include "base.serviceMonitor.merged" (dict "ctx" $ctx) | fromYaml -}}
{{ $serviceMonitor = include "base.serviceMonitor.override" (dict "serviceMonitor" $serviceMonitor "ctx" $ctx) | fromYaml -}}
{{ if and $serviceMonitor.enabled $serviceMonitor.spec.endpoints -}}
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
{{ $_ := unset $serviceMonitor "enabled" -}}
{{ $serviceMonitor | toYaml }}
---
{{- end }}
{{- end }}

{{/*
Usage: {{ $serviceMonitor = include "base.serviceMonitor.override" (dict "serviceMonitor" $serviceMonitor "ctx" $ctx) | fromYaml -}}
*/}}
{{ define "base.serviceMonitor.override" -}}
{{ $serviceMonitor := .serviceMonitor -}}
{{ $ctx := .ctx -}}
{{ $serviceMonitor = include "base.serviceMonitor.override.spec" (dict "serviceMonitor" $serviceMonitor "ctx" $ctx) | fromYaml -}}
{{ if not $serviceMonitor.metadata.annotations -}}
{{ $_ := unset $serviceMonitor.metadata "annotations" -}}
{{- end }}
{{ tpl ($serviceMonitor | toYaml) $ctx.abs }}
{{- end }}

{{/*
Usage: {{ include "base.serviceMonitor.override" (dict "unit" $unit "ctx" $ctx) }}
*/}}
{{ define "base.serviceMonitor.override.spec" -}}
{{ $serviceMonitor := .serviceMonitor -}}
{{ $spec := $serviceMonitor.spec -}}
{{ $endpoints := $spec.endpoints -}}
{{ $ctx := .ctx -}}
{{ $endpoints = include "base.serviceMonitor.endpoints" (dict "endpoints" $endpoints "ctx" $ctx) | fromYaml -}}
{{ $spec = include "base.util.replaceOrUnset" (dict "dict" $spec "key" "endpoints" "value" $endpoints.endpoints) | fromYaml }}
{{ $serviceMonitor = include "base.util.replaceOrUnset" (dict "dict" $serviceMonitor "key" "spec" "value" $spec) | fromYaml }}
{{ $serviceMonitor | toYaml }}
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
  selector:
    matchLabels: {{ include "base.selectorLabels" (dict "ctx" $ctx) | nindent 6 }}
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
