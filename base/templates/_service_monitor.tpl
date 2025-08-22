{{/*
ServiceMonitor template for baserary chart
Usage: {{ include "base.serviceMonitor" (dict "serviceMonitor" .Values.serviceMonitor "ctx" $ctx) }}
*/}}
{{ define "base.serviceMonitor" -}}
{{ $serviceMonitor := .serviceMonitor -}}
{{ $ctx := .ctx -}}
{{ $content := include "base.serviceMonitor.content" (dict "content" $serviceMonitor "ctx" $ctx) | fromYaml -}}
{{ if and $content.enabled $content.spec.endpoints -}}
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
{{ $_ := unset $content "enabled" -}}
{{ $content | toYaml }}
---
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base.serviceMonitor.content" (dict "content" $content "ctx" $ctx) }}
*/}}
{{ define "base.serviceMonitor.content" -}}
{{ $content := .content -}}
{{ $ctx := .ctx -}}
{{ $defaultContent := include "base.serviceMonitor.default.content" (dict "ctx" $ctx) | fromYaml -}}
{{ $payload := include "base.serviceMonitor.payload" (dict "content" $content "ctx" $ctx) | fromYaml -}}
{{ $content = mustMergeOverwrite $defaultContent $content $payload -}}
{{ if not $content.metadata.annotations -}}
{{ $_ := unset $content.metadata "annotations" -}}
{{- end }}
{{ tpl ($content | toYaml) $ctx }}
{{- end }}

{{/*
Usage: {{ include "base.serviceMonitor.payload" (dict "content" $content "ctx" $ctx) }}
*/}}
{{ define "base.serviceMonitor.payload" -}}
{{ $content := .content -}}
{{ $ctx := .ctx -}}
{{ $endpoints := include "base.serviceMonitor.endpoints" (dict "endpoints" $content.spec.endpoints "ctx" $ctx) | fromYaml -}}
{{ $payload := dict "spec" $endpoints -}}
{{ $payload | toYaml }}
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
Usage: {{ include "base.serviceMonitor.default.content" (dict "ctx" $ctx) }}
*/}}
{{ define "base.serviceMonitor.default.content" -}}
{{ $ctx := .ctx -}}
enabled: true
metadata:
  name: {{ include "base.fullname" (dict "ctx" $ctx) }}
  labels: {{ include "base.labels" (dict "ctx" $ctx) | nindent 4 }}
  annotations: {}
spec:
  endpoints: {}
{{- end }}
