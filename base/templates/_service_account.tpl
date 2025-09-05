{{/*
ServiceAccount template for baserary chart
Usage: {{ include "base.serviceAccount" (dict "ctx" $ctx) }}
*/}}
{{ define "base.serviceAccount" -}}
{{ $ctx := .ctx -}}
{{ $serviceAccount := include "base.serviceAccount.merged" (dict "ctx" $ctx) | fromYaml -}}
{{ $unit := include "base.serviceAccount.unit" (dict "serviceAccount" $serviceAccount "ctx" $ctx) | fromYaml -}}
{{ if $unit.create -}}
apiVersion: v1
kind: ServiceAccount
{{ $_ := unset $unit "create" -}}
{{ $unit | toYaml }}
---
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base.serviceAccount.unit" (dict "serviceAccount" $serviceAccount "ctx" $ctx) }}
*/}}
{{ define "base.serviceAccount.unit" -}}
{{ $serviceAccount := .serviceAccount -}}
{{ $ctx := .ctx -}}
{{ if not $serviceAccount.metadata.annotations -}}
{{ $_ := unset $serviceAccount.metadata "annotations" -}}
{{- end }}
{{ tpl ($serviceAccount | toYaml) $ctx.abs }}
{{- end }}

{{/*
Usage: {{ include "base.serviceAccount.name" (dict "ctx" $ctx) }}
*/}}
{{ define "base.serviceAccount.name" -}}
{{ $ctx := .ctx -}}
{{ $serviceAccount := include "base.serviceAccount.merged" (dict "ctx" $ctx) | fromYaml -}}
{{ $unit := include "base.serviceAccount.unit" (dict "serviceAccount" $serviceAccount "ctx" $ctx) | fromYaml -}}
{{ $unit.metadata.name }}
{{- end }}

{{/*
Usage: {{ include "base.serviceAccount.default" (dict "ctx" $ctx) }}
*/}}
{{ define "base.serviceAccount.default" -}}
{{ $ctx := .ctx -}}
create: true
metadata:
  name: {{ include "base.fullname" (dict "ctx" $ctx) }}
  labels: {{ include "base.labels" (dict "ctx" $ctx) | nindent 4 }}
  annotations: {}
{{- end }}

{{/*
Usage: {{ $serviceAccount := include "base.serviceAccount.merged" (dict "ctx" $ctx) | fromYaml -}}
*/}}
{{ define "base.serviceAccount.merged" -}}
{{ $ctx := .ctx -}}
{{ $default := include "base.serviceAccount.default" (dict "ctx" $ctx) | fromYaml -}}
{{ $serviceAccount := $ctx.val.serviceAccount | default dict }}
{{ mustMergeOverwrite $default $serviceAccount | toYaml }}
{{- end }}
