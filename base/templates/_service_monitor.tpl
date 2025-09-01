{{/*
ServiceMonitor template for baserary chart
Usage: {{ include "base.serviceMonitor" (dict "ctx" $ctx) }}
*/}}
{{ define "base.serviceMonitor" -}}
{{ $ctx := .ctx -}}
{{ $serviceMonitor := include "base.serviceMonitor.default.merged" (dict "ctx" $ctx) | fromYaml -}}
{{ $content := include "base.serviceMonitor.content" (dict "serviceMonitor" $serviceMonitor "ctx" $ctx) | fromYaml -}}
{{ if and $content.enabled $content.spec.endpoints -}}
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
{{ $_ := unset $content "enabled" -}}
{{ $content | toYaml }}
---
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base.serviceMonitor.content" (dict "serviceMonitor" $serviceMonitor "ctx" $ctx) }}
*/}}
{{ define "base.serviceMonitor.content" -}}
{{ $serviceMonitor := .serviceMonitor -}}
{{ $ctx := .ctx -}}
{{ $override := include "base.serviceMonitor.override" (dict "serviceMonitor" $serviceMonitor "ctx" $ctx) | fromYaml -}}
{{ $content := mustMergeOverwrite $serviceMonitor $override -}}
{{ if not $content.metadata.annotations -}}
{{ $_ := unset $content.metadata "annotations" -}}
{{- end }}
{{ tpl ($content | toYaml) $ctx.abs }}
{{- end }}

{{/*
Usage: {{ include "base.serviceMonitor.payload" (dict "content" $content "ctx" $ctx) }}
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
Usage: {{ $serviceMonitor := include "base.serviceMonitor.default.merged" (dict "ctx" $ctx) | fromYaml -}}
*/}}
{{ define "base.serviceMonitor.default.merged" -}}
{{ $ctx := .ctx -}}
{{ $default := include "base.serviceMonitor.default" (dict "ctx" $ctx) | fromYaml -}}
{{ $serviceMonitor := $ctx.val.serviceMonitor | default dict }}
{{ mustMergeOverwrite $default $serviceMonitor | toYaml }}
{{- end }}
