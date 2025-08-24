{{/*
ServiceAccount template for baserary chart
Usage: {{ include "base.serviceAccount" (dict "serviceAccount" $serviceAccount "ctx" $ctx) }}
*/}}
{{ define "base.serviceAccount" -}}
{{ $serviceAccount := .serviceAccount -}}
{{ $ctx := .ctx -}}
{{ $content := include "base.serviceAccount.content" (dict "content" $serviceAccount "ctx" $ctx) | fromYaml -}}
{{ if $content.create -}}
apiVersion: v1
kind: ServiceAccount
{{ $_ := unset $content "create" -}}
{{ $content | toYaml }}
---
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base.serviceAccount.content" (dict "content" $content "ctx" $ctx) }}
*/}}
{{ define "base.serviceAccount.content" -}}
{{ $content := .content -}}
{{ $ctx := .ctx -}}
{{ $defaultContent := include "base.serviceAccount.default.content" (dict "ctx" $ctx) | fromYaml -}}
{{ $content = mustMergeOverwrite $defaultContent $content -}}
{{ if not $content.metadata.annotations -}}
{{ $_ := unset $content.metadata "annotations" -}}
{{- end }}
{{ tpl ($content | toYaml) $ctx.abs }}
{{- end }}

{{/*
Usage: {{ include "base.serviceAccount.default.content" (dict "ctx" $ctx) }}
*/}}
{{ define "base.serviceAccount.default.content" -}}
{{ $ctx := .ctx -}}
create: true
metadata:
  name: {{ include "base.fullname" (dict "ctx" $ctx) }}
  labels: {{ include "base.labels" (dict "ctx" $ctx) | nindent 4 }}
  annotations: {}
{{- end }}

{{/*
Usage: {{ include "base.serviceAccount.name" (dict "serviceAccount" $serviceAccount "ctx" $ctx) }}
*/}}
{{ define "base.serviceAccount.name" -}}
{{ $ctx := .ctx -}}
{{ $serviceAccount := .serviceAccount -}}
{{ $content := $serviceAccount -}}
{{ $defaultContent := include "base.serviceAccount.default.content" (dict "ctx" $ctx) | fromYaml -}}
{{ $content = mustMergeOverwrite $defaultContent $content -}}
{{ $content.metadata.name }}
{{- end }}
