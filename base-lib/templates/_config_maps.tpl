{{/*
ConfigMap template for base-library chart
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
{{ if $payload -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "base-lib.configMaps.name" (dict "postfix" $postfix "ctx" $ctx) }}
  labels: {{ include "base-lib.labels" (dict "ctx" $ctx) | nindent 4 }}
  {{- with $content.annotations }}
  annotations: {{ tpl (toYaml .) $ctx | nindent 4 }}
  {{- end }}
{{ $payload | toYaml }}
---
{{- end }}
{{- end }}
{{- end }}

{{/*
ConfigMap content helper
Usage: {{ include "base-lib.configMaps.content" (dict "postfix" $postfix "content" $content "ctx" $ctx) }}
*/}}
{{ define "base-lib.configMaps.payload" -}}
{{ $postfix := .postfix -}}
{{ $content := .content -}}
{{ $ctx := .ctx -}}
{{ if eq $postfix "envVars" -}}
{{ include "base-lib.configMaps.content.envVars" (dict "content" $content "ctx" $ctx) }}
{{ else if eq $postfix "files" -}}
{{ include "base-lib.configMaps.content.files" (dict "content" $content "ctx" $ctx) }}
{{ else -}}
{{ include "base-lib.configMaps.content.others" (dict "content" $content "ctx" $ctx) }}
{{- end }}
{{- end }}

{{/*
ConfigMap envVars content helper
Usage: {{ include "base-lib.configMaps.content.envVars" (dict "content" $content "ctx" $ctx) }}
*/}}
{{ define "base-lib.configMaps.content.envVars" -}}
{{ $content := .content -}}
{{ $ctx := .ctx -}}
{{ if $content.data -}}
{{ print "data:" }}
{{ range $k, $v := $content.data -}}
{{ printf "%s: %s" (tpl $k $ctx) (tpl $v $ctx) | indent 2 }}
{{- end }}
{{- end }}
{{- if $content.binaryData }}
{{ fail "configMaps.envVars does not support 'binaryData'" }}
{{- end }}
{{- end }}

{{/*
ConfigMap files content helper
Usage: {{ include "base-lib.configMaps.content.files" (dict "content" $content "ctx" $ctx) }}
*/}}
{{ define "base-lib.configMaps.content.files" -}}
{{ $content := .content -}}
{{ $ctx := .ctx -}}
{{ if $content.data -}}
{{ print "data:" }}
{{ range $k, $v := $content.data -}}
{{ $filepath := tpl $k $ctx -}}
{{ printf "%s: |" (include "base-lib.util.dnsCompatible" (dict "filepath" $filepath)) | indent 2 }}
{{ if mustRegexMatch "(.+)(\\.yaml|\\.yml)$" (base $filepath) -}}
{{ tpl ($v | toYaml) $ctx | indent 4 }}
{{ else if mustRegexMatch "(.+)(\\.json)$" (base $filepath) -}}
{{ tpl ($v | toJson) $ctx | indent 4 }}
{{ else if mustRegexMatch "(.+)(\\.toml)$" (base $filepath) -}}
{{ tpl ($v | toToml) $ctx | indent 4 }}
{{ else -}}
{{ tpl ($v | toString) $ctx | indent 4 }}
{{ end -}}
{{- end }}
{{- end }}
{{- if $content.binaryData }}
{{ fail "configMaps.files does not support 'binaryData'" }}
{{- end }}
{{- end }}

{{/*
ConfigMap others content helper
Usage: {{ include "base-lib.configMaps.content.others" (dict "content" $content "ctx" $ctx) }}
*/}}
{{ define "base-lib.configMaps.content.others" -}}
{{ $content := .content -}}
{{ $ctx := .ctx -}}
{{- with $content.data }}
data: {{ tpl (toYaml .) $ctx | nindent 2 }}
{{- end }}
{{- with $content.binaryData }}
binaryData: {{ tpl (toYaml .) $ctx | nindent 2 }}
{{- end }}
{{- end }}

{{/*
ConfigMap name helper
Usage: {{ include "base-lib.configMapName" (dict "postfix" $postfix "ctx" $ctx) }}
*/}}
{{ define "base-lib.configMaps.name" -}}
{{ $postfix := .postfix -}}
{{ $ctx := .ctx -}}
{{ printf "%s-%s" (include "base-lib.fullname" (dict "ctx" $ctx)) ($postfix | kebabcase) }}
{{- end }}
