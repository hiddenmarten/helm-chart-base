{{/*
Usage: {{ include "base.deployment" (dict "ctx" $ctx) }}
*/}}
{{ define "base.deployment" -}}
{{ $ctx := .ctx -}}
{{ $deployment := include "base.deployment.merged" (dict "ctx" $ctx) | fromYaml -}}
{{ $unit := include "base.deployment.unit" (dict "deployment" $deployment "ctx" $ctx) | fromYaml -}}
{{ if $unit.enabled -}}
apiVersion: apps/v1
kind: Deployment
{{ $_ := unset $unit "enabled" -}}
{{ $unit | toYaml }}
---
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base.deployment.unit" (dict "deployment" $deployment "ctx" $ctx) }}
*/}}
{{ define "base.deployment.unit" -}}
{{ $ctx := .ctx -}}
{{ $deployment := .deployment -}}
{{ $spec := $deployment.spec -}}
{{ $pod := include "base.pod" (dict "pod" (index $spec "template") "ctx" $ctx) | fromYaml -}}
{{ $_ := set $spec "template" $pod -}}
{{ $_ = set $deployment "spec" $spec -}}
{{ $deployment | toYaml }}
{{- end }}

{{/*
Usage: {{ include "base.deployment.default" (dict "ctx" $ctx) }}
*/}}
{{ define "base.deployment.default" -}}
{{ $ctx := .ctx -}}
enabled: true
metadata:
  name: {{ include "base.fullname" (dict "ctx" $ctx) }}
  labels: {{ include "base.labels" (dict "ctx" $ctx) | nindent 4 }}
spec:
  template: {}
  selector:
    matchLabels: {{ include "base.selectorLabels" (dict "ctx" $ctx) | nindent 6 }}
{{- end }}

{{/*
Usage: {{ $deployment := include "base.deployment.merged" (dict "ctx" $ctx) | fromYaml -}}
*/}}
{{ define "base.deployment.merged" -}}
{{ $ctx := .ctx -}}
{{ $default := include "base.deployment.default" (dict "ctx" $ctx) | fromYaml -}}
{{ $deployment := $ctx.val.deployment | default dict }}
{{ mustMergeOverwrite $default $deployment | toYaml }}
{{- end }}
