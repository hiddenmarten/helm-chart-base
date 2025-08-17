{{/*
Usage: {{ include "base.secrets" (dict "secrets" .Values.secrets "ctx" $) }}
*/}}
{{ define "base.secrets" -}}
{{ $secrets := .secrets -}}
{{ $ctx := .ctx -}}
{{ $defaults := include "base.defaults" (dict "ctx" $ctx) | fromYaml -}}
{{ $defaultSecrets := $defaults.secrets -}}
{{ $secrets = mustMergeOverwrite $defaultSecrets $secrets -}}
{{- range $postfix, $content := $secrets }}
{{ $payload := include "base.secrets.payload" (dict "postfix" $postfix "content" $content "ctx" $ctx) | fromYaml -}}
{{ if and $content.enabled $payload -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "base.secrets.name" (dict "postfix" $postfix "ctx" $ctx) }}
  labels: {{ include "base.labels" (dict "ctx" $ctx) | nindent 4 }}
  {{- with $content.annotations }}
  annotations: {{ tpl (. | toYaml) $ctx | nindent 4 }}
  {{- end }}
{{- with $content.type }}
type: {{ tpl (. | toYaml) $ctx }}
{{- end }}
{{ $payload | toYaml }}
---
{{- end }}
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base.secrets.payload" (dict "postfix" $postfix "content" $content "ctx" $ctx) }}
*/}}
{{ define "base.secrets.payload" -}}
{{ $postfix := .postfix -}}
{{ $content := .content -}}
{{ $ctx := .ctx -}}
{{ if eq $postfix "envVars" -}}
{{ include "base.secrets.envVars.content" (dict "content" $content "ctx" $ctx) }}
{{ else if eq $postfix "files" -}}
{{ include "base.secrets.files.content" (dict "content" $content "ctx" $ctx) }}
{{ else -}}
{{ include "base.secrets.others.content" (dict "content" $content "ctx" $ctx) }}
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base.secrets.envVars.content" (dict "content" $content "ctx" $ctx) }}
*/}}
{{ define "base.secrets.envVars.content" -}}
{{ $content := .content -}}
{{ $ctx := .ctx -}}
{{ if $content.data -}}
{{ print "data:" }}
{{ range $k, $v := $content.data -}}
{{ printf "%s: %s" (tpl $k $ctx) ((tpl $v $ctx) | b64enc) | nindent 2 }}
{{- end }}
{{- end }}
{{- if $content.stringData }}
{{ fail "secrets.envVars does not support 'stringData'" }}
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base.secrets.files.content" (dict "content" $content "ctx" $ctx) }}
*/}}
{{ define "base.secrets.files.content" -}}
{{ $content := .content -}}
{{ $ctx := .ctx -}}
{{ if $content.data -}}
{{ print "data:" }}
{{ range $k, $v := $content.data -}}
{{ $filepath := tpl $k $ctx -}}
{{ printf "%s: |" (include "base.util.dnsCompatible" (dict "filepath" $filepath)) | indent 2 }}
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
Usage: {{ include "base.secrets.files.name" (dict "ctx" $ctx) }}
*/}}
{{ define "base.secrets.files.name" -}}
{{ $ctx := .ctx -}}
{{ print "secret-files" }}
{{- end }}

{{/*
Usage: {{ include "base.secrets.files.volume" (dict "ctx" $ctx) }}
*/}}
{{ define "base.secrets.files.volume" -}}
{{ $ctx := .ctx -}}
name: {{ include "base.secrets.files.name" (dict "ctx" $ctx) }}
secret:
  secretName: {{ include "base.secrets.name" (dict "postfix" "files" "ctx" $ctx) }}
{{- end }}

{{/*
Usage: {{ include "base.secrets.files.volumeMounts" (dict "files" $files "ctx" $ctx) }}
*/}}
{{ define "base.secrets.files.volumeMounts" -}}
{{ $files := .files -}}
{{ $ctx := .ctx -}}
{{ $mounts := list -}}
{{ range $path, $_ := $files.data -}}
{{ $name := include "base.secrets.files.name" (dict "ctx" $ctx) -}}
{{ $defaultMount := include "base.volumeMounts.files.default" (dict "path" $path "name" $name "ctx" $ctx) | fromYaml -}}
{{ $mount := mustMergeOverwrite $defaultMount $files.mount -}}
{{ $mounts = append $mounts $mount -}}
{{- end }}
volumeMounts: {{ $mounts | toYaml | nindent 2 }}
{{- end }}

{{/*
Usage: {{ include "base.secrets.others.content" (dict "content" $content "ctx" $ctx) }}
*/}}
{{ define "base.secrets.others.content" -}}
{{ $content := .content -}}
{{ $ctx := .ctx -}}
{{- with $content.data }}
data: {{ tpl (. | toYaml) $ctx | nindent 2 }}
{{- end }}
{{- with $content.stringData }}
stringData: {{ tpl (. | toYaml) $ctx | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base.secrets.name" (dict "postfix" $postfix "ctx" $) }}
*/}}
{{ define "base.secrets.name" -}}
{{ $postfix := .postfix -}}
{{ $ctx := .ctx -}}
{{ printf "%s-%s" (include "base.fullname" (dict "ctx" $ctx)) ($postfix | kebabcase) }}
{{- end }}
