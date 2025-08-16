{{/*
Usage: {{ include "base-lib.configMaps" (dict "cms" .Values.configMaps "ctx" $) }}
*/}}
{{ define "base-lib.configMaps" -}}
{{ $cms := .configMaps -}}
{{ $ctx := .ctx -}}
{{ $defaults := include "base-lib.defaults" (dict "ctx" $ctx) | fromYaml -}}
{{ $defaultCms := $defaults.configMaps -}}
{{ $cms = mustMergeOverwrite $defaultCms $cms -}}
{{- range $postfix, $content := $cms }}
{{ $payload := include "base-lib.configMaps.payload" (dict "postfix" $postfix "content" $content "ctx" $ctx) | fromYaml -}}
{{ if and $content.enabled $payload -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "base-lib.configMaps.name" (dict "postfix" $postfix "ctx" $ctx) }}
  labels: {{ include "base-lib.labels" (dict "ctx" $ctx) | nindent 4 }}
  {{- with $content.annotations }}
  annotations: {{ tpl (. | toYaml) $ctx | nindent 4 }}
  {{- end }}
{{ tpl ($payload | toYaml) $ctx }}
---
{{- end }}
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base-lib.configMaps.content" (dict "postfix" $postfix "content" $content "ctx" $ctx) }}
*/}}
{{ define "base-lib.configMaps.payload" -}}
{{ $postfix := .postfix -}}
{{ $content := .content -}}
{{ $ctx := .ctx -}}
{{ if eq $postfix "envVars" -}}
{{ include "base-lib.configMaps.envVars.content" (dict "content" $content "ctx" $ctx) }}
{{ else if eq $postfix "files" -}}
{{ include "base-lib.configMaps.files.content" (dict "content" $content "ctx" $ctx) }}
{{ else -}}
{{ include "base-lib.configMaps.others.content" (dict "content" $content "ctx" $ctx) }}
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base-lib.configMaps.envVars.content" (dict "content" $content "ctx" $ctx) }}
*/}}
{{ define "base-lib.configMaps.envVars.content" -}}
{{ $content := .content -}}
{{ $ctx := .ctx -}}
{{ if $content.data -}}
{{ print "data: " }}
{{ range $k, $v := $content.data -}}
{{ printf "%s: %s" $k $v | nindent 2 }}
{{- end }}
{{- end }}
{{- if $content.binaryData }}
{{ fail "configMaps.envVars does not support 'binaryData'" }}
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base-lib.configMaps.files.content" (dict "content" $content "ctx" $ctx) }}
*/}}
{{ define "base-lib.configMaps.files.content" -}}
{{ $content := .content -}}
{{ $ctx := .ctx -}}
{{ if $content.data -}}
{{ print "data:" }}
{{ range $k, $v := $content.data -}}
{{ $filepath := $k -}}
{{ printf "%s: |" (include "base-lib.util.dnsCompatible" (dict "filepath" $filepath)) | indent 2 }}
{{ if mustRegexMatch "(.+)(\\.yaml|\\.yml)$" (base $filepath) -}}
{{ $v | toYaml | indent 4 }}
{{ else if mustRegexMatch "(.+)(\\.json)$" (base $filepath) -}}
{{ $v | toJson | indent 4 }}
{{ else if mustRegexMatch "(.+)(\\.toml)$" (base $filepath) -}}
{{ $v | toToml | indent 4 }}
{{ else -}}
{{ $v | toString | indent 4 }}
{{ end -}}
{{- end }}
{{- end }}
{{- if $content.binaryData }}
{{ fail "configMaps.files does not support 'binaryData'" }}
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base-lib.volumes.configMap.name" (dict "ctx" $ctx) }}
*/}}
{{ define "base-lib.configMaps.files.name" -}}
{{ $ctx := .ctx -}}
{{ print "config-map-files" }}
{{- end }}

{{/*
Usage: {{ include "base-lib.volumes.configMap.volume" (dict "ctx" $ctx) }}
*/}}
{{ define "base-lib.configMaps.files.volume" -}}
{{ $ctx := .ctx -}}
name: {{ include "base-lib.configMaps.files.name" (dict "ctx" $ctx) }}
configMap:
  name: {{ include "base-lib.configMaps.name" (dict "postfix" "files" "ctx" $ctx) }}
{{- end }}

{{/*
Usage: {{ include "base-lib.configMaps.files.volumeMounts" (dict "files" $files "ctx" $ctx) }}
*/}}
{{ define "base-lib.configMaps.files.volumeMounts" -}}
{{ $files := .files -}}
{{ $ctx := .ctx -}}
{{ $mounts := list -}}
{{ range $path, $_ := $files.data -}}
{{ $name := include "base-lib.configMaps.files.name" (dict "ctx" $ctx) -}}
{{ $defaultMount := include "base-lib.volumeMounts.files.default" (dict "path" $path "name" $name "ctx" $ctx) | fromYaml -}}
{{ $mount := mustMergeOverwrite $defaultMount $files.mount -}}
{{ $mounts = append $mounts $mount -}}
{{- end }}
volumeMounts: {{ $mounts | toYaml | nindent 2 }}
{{- end }}

{{/*
Usage: {{ include "base-lib.configMaps.others.content" (dict "content" $content "ctx" $ctx) }}
*/}}
{{ define "base-lib.configMaps.others.content" -}}
{{ $content := .content -}}
{{ $ctx := .ctx -}}
{{- with $content.data }}
data: {{ toYaml . | nindent 2 }}
{{- end }}
{{- with $content.binaryData }}
binaryData: {{ toYaml . | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base-lib.configMapName" (dict "postfix" $postfix "ctx" $ctx) }}
*/}}
{{ define "base-lib.configMaps.name" -}}
{{ $postfix := .postfix -}}
{{ $ctx := .ctx -}}
{{ printf "%s-%s" (include "base-lib.fullname" (dict "ctx" $ctx)) ($postfix | kebabcase) }}
{{- end }}
