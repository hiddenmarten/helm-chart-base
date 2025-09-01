{{/*
ServiceAccount template for baserary chart
Usage: {{ include "base.serviceAccount" (dict "ctx" $ctx) }}
*/}}
{{ define "base.serviceAccount" -}}
{{ $ctx := .ctx -}}
{{ $serviceAccount := include "base.serviceAccount.default.merged" (dict "ctx" $ctx) | fromYaml -}}
{{ $content := include "base.serviceAccount.content" (dict "serviceAccount" $serviceAccount "ctx" $ctx) | fromYaml -}}
{{ if $content.create -}}
apiVersion: v1
kind: ServiceAccount
{{ $_ := unset $content "create" -}}
{{ $content | toYaml }}
---
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base.serviceAccount.content" (dict "serviceAccount" $serviceAccount "ctx" $ctx) }}
*/}}
{{ define "base.serviceAccount.content" -}}
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
{{ $serviceAccount := include "base.serviceAccount.default.merged" (dict "ctx" $ctx) | fromYaml -}}
{{ $content := include "base.serviceAccount.content" (dict "serviceAccount" $serviceAccount "ctx" $ctx) | fromYaml -}}
{{ $content.metadata.name }}
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
Usage: {{ $serviceAccount := include "base.serviceAccount.default.merged" (dict "ctx" $ctx) | fromYaml -}}
*/}}
{{ define "base.serviceAccount.default.merged" -}}
{{ $ctx := .ctx -}}
{{ $default := include "base.serviceAccount.default" (dict "ctx" $ctx) | fromYaml -}}
{{ $serviceAccount := $ctx.val.serviceAccount | default dict }}
{{ mustMergeOverwrite $default $serviceAccount | toYaml }}
{{- end }}
