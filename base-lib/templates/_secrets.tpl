{{/*
Secret template for base-library chart
Usage: {{ include "base-lib.secrets" (dict "secrets" .Values.secrets "ctx" $) }}
*/}}
{{ define "base-lib.secrets" -}}
{{ $secrets := .secrets -}}
{{ $ctx := .ctx -}}
{{ $defaults := include "base-lib.defaults" (dict "ctx" $ctx) | fromYaml -}}
{{ $defaultSecrets := $defaults.secrets -}}
{{ $secrets = mustMergeOverwrite $defaultSecrets $secrets -}}
{{- range $postfix, $content := $secrets }}
{{ $payload := include "base-lib.secrets.payload" (dict "postfix" $postfix "content" $content "ctx" $ctx) | fromYaml -}}
{{ if $payload -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "base-lib.secrets.name" (dict "postfix" $postfix "ctx" $ctx) }}
  labels: {{ include "base-lib.labels" (dict "ctx" $ctx) | nindent 4 }}
  {{- with $content.annotations }}
  annotations: {{ tpl (toYaml .) $ctx | nindent 4 }}
  {{- end }}
{{- with $content.type }}
type: {{ tpl (toYaml .) $ctx }}
{{- end }}
{{ $payload | toYaml }}
---
{{- end }}
{{- end }}
{{- end }}

{{/*
Secret content helper
Usage: {{ include "base-lib.secrets.content" (dict "postfix" $postfix "content" $content "ctx" $ctx) }}
*/}}
{{ define "base-lib.secrets.payload" -}}
{{ $postfix := .postfix -}}
{{ $content := .content -}}
{{ $ctx := .ctx -}}
{{ if eq $postfix "envVars" -}}
{{ include "base-lib.secrets.content.envVars" (dict "content" $content "ctx" $ctx) }}
{{ else if eq $postfix "files" -}}
{{ include "base-lib.secrets.content.files" (dict "content" $content "ctx" $ctx) }}
{{ else -}}
{{ include "base-lib.secrets.content.others" (dict "content" $content "ctx" $ctx) }}
{{- end }}
{{- end }}

{{/*
Secret envVars content helper
Usage: {{ include "base-lib.secrets.content.envVars" (dict "content" $content "ctx" $ctx) }}
*/}}
{{ define "base-lib.secrets.content.envVars" -}}
{{ $content := .content -}}
{{ $ctx := .ctx -}}
{{ if $content.data -}}
{{ print "data:" }}
{{ range $k, $v := $content.data -}}
{{ printf "%s: %s" (tpl $k $ctx) ((tpl $v $ctx) | b64enc) | indent 2 }}
{{- end }}
{{- end }}
{{- if $content.stringData }}
{{ fail "secrets.envVars does not support 'stringData'" }}
{{- end }}
{{- end }}

{{/*
Secret files content helper
Usage: {{ include "base-lib.secrets.content.files" (dict "val" $v "ctx" $ctx) }}
*/}}
{{ define "base-lib.secrets.content.files" -}}
{{ $content := .content -}}
{{ $ctx := .ctx -}}
{{ if $content.data -}}
{{ print "data:" }}
{{ range $k, $v := $content.data -}}
{{ $filepath := tpl $k $ctx -}}
{{ printf "%s: |" (include "base-lib.util.dnsCompatible" (dict "filepath" $filepath)) | indent 2 }}
{{ if mustRegexMatch "(.+)(\\.yaml|\\.yml)$" (base $filepath) -}}
{{ (tpl ($v | toYaml) $ctx | b64enc) | indent 4 }}
{{ else if mustRegexMatch "(.+)(\\.json)$" (base $filepath) -}}
{{ (tpl ($v | toJson) $ctx | b64enc) | indent 4 }}
{{ else if mustRegexMatch "(.+)(\\.toml)$" (base $filepath) -}}
{{ (tpl ($v | toToml) $ctx | b64enc) | indent 4 }}
{{ else -}}
{{ (tpl ($v | toString) $ctx | b64enc) | indent 4 }}
{{ end -}}
{{- end }}
{{- end }}
{{- if $content.stringData }}
{{ fail "secrets.files does not support 'stringData'" }}
{{- end }}
{{- end }}

{{/*
Secret others content helper
Usage: {{ include "base-lib.secrets.content.others" (dict "content" $content "ctx" $ctx) }}
*/}}
{{ define "base-lib.secrets.content.others" -}}
{{ $content := .content -}}
{{ $ctx := .ctx -}}
{{- with $content.data }}
data: {{ tpl (toYaml .) $ctx | nindent 2 }}
{{- end }}
{{- with $content.stringData }}
stringData: {{ tpl (toYaml .) $ctx | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Secret name helper
Usage: {{ include "base-lib.secrets.name" (dict "postfix" $postfix "ctx" $) }}
*/}}
{{ define "base-lib.secrets.name" -}}
{{ $postfix := .postfix -}}
{{ $ctx := .ctx -}}
{{ printf "%s-%s" (include "base-lib.fullname" (dict "ctx" $ctx)) ($postfix | kebabcase) }}
{{- end }}
