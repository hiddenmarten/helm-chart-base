{{/*
Usage: {{ include "base.job" (dict "ctx" $ctx) }}
*/}}
{{ define "base.job" -}}
{{ $ctx := .ctx -}}
{{ $job := include "base.job.merged" (dict "ctx" $ctx) | fromYaml -}}
{{ $job = include "base.job.override" (dict "job" $job "ctx" $ctx) | fromYaml -}}
{{ if and $job.enabled (index $job.spec "template") -}}
apiVersion: batch/v1
kind: Job
{{ $_ := unset $job "enabled" -}}
{{ $job | toYaml }}
---
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base.job.override" (dict "job" $job "ctx" $ctx) }}
*/}}
{{ define "base.job.override" -}}
{{ $ctx := .ctx -}}
{{ $job := .job -}}
{{ $spec := $job.spec -}}
{{ $pod := include "base.pod" (dict "pod" (index $spec "template") "ctx" $ctx) | fromYaml -}}
{{ $_ := set $spec "template" $pod -}}
{{ $_ = set $job "spec" $spec -}}
{{ tpl ($job | toYaml) $ctx.abs }}
{{- end }}

{{/*
Usage: {{ include "base.job.default" (dict "ctx" $ctx) }}
*/}}
{{ define "base.job.default" -}}
{{ $ctx := .ctx -}}
enabled: true
metadata:
  name: {{ include "base.fullname" (dict "ctx" $ctx) }}
  labels: {{ include "base.labels" (dict "ctx" $ctx) | nindent 4 }}
spec:
  template: {}
{{- end }}

{{/*
Usage: {{ $job := include "base.job.merged" (dict "ctx" $ctx) | fromYaml -}}
*/}}
{{ define "base.job.merged" -}}
{{ $ctx := .ctx -}}
{{ $default := include "base.job.default" (dict "ctx" $ctx) | fromYaml -}}
{{ $job := $ctx.val.job | default dict }}
{{ mustMergeOverwrite $default $job | toYaml }}
{{- end }}
