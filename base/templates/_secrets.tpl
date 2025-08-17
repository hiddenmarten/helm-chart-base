{{/*
Usage: {{ include "base.secrets" (dict "secrets" .Values.secrets "ctx" $) }}
*/}}
{{ define "base.secrets" -}}
{{ $secrets := .secrets -}}
{{ $ctx := .ctx -}}
{{- range $postfix, $content := $secrets }}
{{ $content = include "base.secrets.content" (dict "postfix" $postfix "content" $content "ctx" $ctx) | fromYaml -}}
{{ if and $content.enabled (or $content.data $content.stringData) -}}
apiVersion: v1
kind: Secret
{{ $_ := unset $content "enabled" -}}
{{ $_ = unset $content "mount" -}}
{{ $content | toYaml }}
---
{{- end }}
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base.secrets.content" (dict "postfix" $postfix "content" $content "ctx" $ctx) }}
*/}}
{{ define "base.secrets.content" -}}
{{ $postfix := .postfix -}}
{{ $content := .content -}}
{{ $ctx := .ctx -}}
{{ $defaultContent := include "base.secrets.default.content" (dict "postfix" $postfix "ctx" $ctx) | fromYaml -}}
{{ $content = mustMergeOverwrite $defaultContent $content -}}
{{ $payload := dict -}}
{{ if eq $postfix "envVars" -}}
{{ $payload = include "base.secrets.envVars.payload" (dict "content" $content "ctx" $ctx) | fromYaml -}}
{{ else if eq $postfix "files" -}}
{{ $payload = include "base.secrets.files.payload" (dict "content" $content "ctx" $ctx) | fromYaml -}}
{{ else -}}
{{ $payload = include "base.secrets.others.payload" (dict "content" $content "ctx" $ctx) | fromYaml -}}
{{- end }}
{{ if $payload.data -}}
{{ $_ := set $content "data" $payload.data -}}
{{ else -}}
{{ $_ := unset $content "data" -}}
{{- end }}
{{ if $payload.stringData -}}
{{ $_ := set $content "stringData" $payload.stringData -}}
{{ else -}}
{{ $_ := unset $content "stringData" -}}
{{- end }}
{{ if not $content.metadata.annotations -}}
{{ $_ := unset $content.metadata "annotations" -}}
{{- end }}
{{ tpl ($content | toYaml) $ctx }}
{{- end }}

{{/*
Usage: {{ include "base.secrets.envVars.payload" (dict "content" $content "ctx" $ctx) }}
*/}}
{{ define "base.secrets.envVars.payload" -}}
{{ $content := .content -}}
{{ $ctx := .ctx -}}
{{ if $content.data -}}
{{ print "data: " }}
{{ range $k, $v := $content.data -}}
{{ printf "%s: %s" (tpl $k $ctx) ((tpl $v $ctx) | b64enc) | nindent 2 }}
{{- end }}
{{- end }}
{{- if $content.stringData }}
{{ fail "secrets.envVars does not support 'stringData'" }}
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base.secrets.files.payload" (dict "content" $content "ctx" $ctx) }}
*/}}
{{ define "base.secrets.files.payload" -}}
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
Usage: {{ include "base.secrets.others.payload" (dict "content" $content "ctx" $ctx) }}
*/}}
{{ define "base.secrets.others.payload" -}}
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

{{/*
Usage: {{ include "base.secrets.default.content" (dict "postfix" $postfix "ctx" $ctx) }}
*/}}
{{ define "base.secrets.default.content" -}}
{{ $ctx := .ctx -}}
{{ $postfix := .postfix -}}
enabled: true
metadata:
  name: {{ include "base.secrets.name" (dict "postfix" $postfix "ctx" $ctx) }}
  labels: {{ include "base.labels" (dict "ctx" $ctx) | nindent 4 }}
  annotations: {}
data: {}
stringData: {}
mount: {}
{{- end }}
