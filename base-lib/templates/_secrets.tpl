{{/*
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
{{ if and $content.enabled $payload -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "base-lib.secrets.name" (dict "postfix" $postfix "ctx" $ctx) }}
  labels: {{ include "base-lib.labels" (dict "ctx" $ctx) | nindent 4 }}
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
Usage: {{ include "base-lib.secrets.payload" (dict "postfix" $postfix "content" $content "ctx" $ctx) }}
*/}}
{{ define "base-lib.secrets.payload" -}}
{{ $postfix := .postfix -}}
{{ $content := .content -}}
{{ $ctx := .ctx -}}
{{ if eq $postfix "envVars" -}}
{{ include "base-lib.secrets.envVars.content" (dict "content" $content "ctx" $ctx) }}
{{ else if eq $postfix "files" -}}
{{ include "base-lib.secrets.files.content" (dict "content" $content "ctx" $ctx) }}
{{ else -}}
{{ include "base-lib.secrets.others.content" (dict "content" $content "ctx" $ctx) }}
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base-lib.secrets.envVars.content" (dict "content" $content "ctx" $ctx) }}
*/}}
{{ define "base-lib.secrets.envVars.content" -}}
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
Usage: {{ include "base-lib.secrets.files.content" (dict "content" $content "ctx" $ctx) }}
*/}}
{{ define "base-lib.secrets.files.content" -}}
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
Usage: {{ include "base-lib.secrets.files.name" (dict "ctx" $ctx) }}
*/}}
{{ define "base-lib.secrets.files.name" -}}
{{ $ctx := .ctx -}}
{{ print "secret-files" }}
{{- end }}

{{/*
Usage: {{ include "base-lib.secrets.files.volume" (dict "ctx" $ctx) }}
*/}}
{{ define "base-lib.secrets.files.volume" -}}
{{ $ctx := .ctx -}}
name: {{ include "base-lib.secrets.files.name" (dict "ctx" $ctx) }}
secret:
  secretName: {{ include "base-lib.secrets.name" (dict "postfix" "files" "ctx" $ctx) }}
{{- end }}

{{/*
Usage: {{ include "base-lib.secrets.files.volumeMounts" (dict "files" $files "ctx" $ctx) }}
*/}}
{{ define "base-lib.secrets.files.volumeMounts" -}}
{{ $files := .files -}}
{{ $ctx := .ctx -}}
{{ $mounts := list -}}
{{ range $path, $_ := $files.data -}}
{{ $name := include "base-lib.secrets.files.name" (dict "ctx" $ctx) -}}
{{ $defaultMount := include "base-lib.volumeMounts.files.default" (dict "path" $path "name" $name "ctx" $ctx) | fromYaml -}}
{{ $mount := mustMergeOverwrite $defaultMount $files.mount -}}
{{ $mounts = append $mounts $mount -}}
{{- end }}
volumeMounts: {{ $mounts | toYaml | nindent 2 }}
{{- end }}

{{/*
Usage: {{ include "base-lib.secrets.others.content" (dict "content" $content "ctx" $ctx) }}
*/}}
{{ define "base-lib.secrets.others.content" -}}
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
Usage: {{ include "base-lib.secrets.name" (dict "postfix" $postfix "ctx" $) }}
*/}}
{{ define "base-lib.secrets.name" -}}
{{ $postfix := .postfix -}}
{{ $ctx := .ctx -}}
{{ printf "%s-%s" (include "base-lib.fullname" (dict "ctx" $ctx)) ($postfix | kebabcase) }}
{{- end }}
