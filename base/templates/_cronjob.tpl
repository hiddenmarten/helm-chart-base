{{/*
Usage: {{ include "base.cronjob" (dict "ctx" $ctx) }}
*/}}
{{ define "base.cronjob" -}}
{{ $ctx := .ctx -}}
{{ $cronjob := include "base.cronjob.merged" (dict "ctx" $ctx) | fromYaml -}}
{{ if and $cronjob.enabled $cronjob.spec.schedule $cronjob.spec.jobTemplate -}}
{{ $unit := include "base.cronjob.unit" (dict "cronjob" $cronjob "ctx" $ctx) | fromYaml -}}
apiVersion: batch/v1
kind: CronJob
{{ $_ := unset $unit "enabled" -}}
{{ $unit | toYaml }}
---
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base.cronjob.unit" (dict "cronjob" $cronjob "ctx" $ctx) }}
*/}}
{{ define "base.cronjob.unit" -}}
{{ $ctx := .ctx -}}
{{ $cronjob := .cronjob -}}
{{ $spec := $cronjob.spec -}}
{{ $jobTemplate := $spec.jobTemplate -}}
{{ $jobSpec := $jobTemplate.spec -}}
{{ $pod := include "base.pod" (dict "pod" (index $jobSpec "template") "ctx" $ctx) | fromYaml -}}
{{ $_ := set $jobSpec "template" $pod -}}
{{ $_ = set $jobTemplate "spec" $jobSpec -}}
{{ $_ = set $spec "jobTemplate" $jobTemplate -}}
{{ $_ = set $cronjob "spec" $spec -}}
{{ tpl ($cronjob | toYaml) $ctx.abs }}
{{- end }}

{{/*
Usage: {{ include "base.cronjob.default" (dict "ctx" $ctx) }}
*/}}
{{ define "base.cronjob.default" -}}
{{ $ctx := .ctx -}}
enabled: true
metadata:
  name: {{ include "base.fullname" (dict "ctx" $ctx) }}
  labels: {{ include "base.labels" (dict "ctx" $ctx) | nindent 4 }}
spec:
  schedule: ""
  jobTemplate: {}
{{- end }}

{{/*
Usage: {{ $cronjob := include "base.cronjob.merged" (dict "ctx" $ctx) | fromYaml -}}
*/}}
{{ define "base.cronjob.merged" -}}
{{ $ctx := .ctx -}}
{{ $default := include "base.cronjob.default" (dict "ctx" $ctx) | fromYaml -}}
{{ $cronjob := $ctx.val.cronjob | default dict }}
{{ mustMergeOverwrite $default $cronjob | toYaml }}
{{- end }}
