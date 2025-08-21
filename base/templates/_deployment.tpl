{{/*
Usage: {{ include "base.deployment" (dict "val" .Values "ctx" $) }}
*/}}
{{ define "base.deployment" -}}
{{ $ctx := .ctx -}}
{{ $val := .val -}}
{{ $defaults := include "base.defaults" (dict "ctx" $ctx) | fromYaml -}}
{{ $val = mustMergeOverwrite $defaults $val -}}
{{ $content := include "base.deployment.content" (dict "val" $val "ctx" $ctx) | fromYaml -}}
{{ if $content }}
apiVersion: apps/v1
kind: Deployment
{{ $content | toYaml }}
---
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base.deployment" (dict "val" $val "ctx" $ctx) }}
*/}}
{{ define "base.deployment.content" -}}
{{ $ctx := .ctx -}}
{{ $val := .val -}}
metadata:
  name: {{ include "base.fullname" (dict "ctx" $ctx) }}
  labels: {{ include "base.labels" (dict "ctx" $ctx) | nindent 4 }}
spec:
  selector:
    matchLabels: {{ include "base.selectorLabels" (dict "ctx" $ctx) | nindent 6 }}
  {{ $pod := include "base.pod" (dict "val" $val "ctx" $ctx) | fromYaml -}}
  {{ if $pod -}}
  template: {{ $pod | toYaml | nindent 4 }}
  {{- end }}
{{- end }}
