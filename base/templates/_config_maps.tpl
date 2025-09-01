{{/*
Usage: {{ include "base.configMaps" (dict "ctx" $ctx) }}
*/}}
{{ define "base.configMaps" -}}
{{ $ctx := .ctx -}}
{{ $configMaps := include "base.configMaps.default.merged" (dict "ctx" $ctx) | fromYaml -}}
{{- range $postfix, $content := $configMaps }}
{{ $content = include "base.configMaps.content" (dict "postfix" $postfix "content" $content "ctx" $ctx) | fromYaml -}}
{{ if and $content.enabled (or $content.data $content.binaryData) -}}
apiVersion: v1
kind: ConfigMap
{{ $_ := unset $content "enabled" -}}
{{ $_ = unset $content "mount" -}}
{{ $content | toYaml }}
---
{{- end }}
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base.configMaps.content" (dict "postfix" $postfix "content" $content "ctx" $ctx) }}
*/}}
{{ define "base.configMaps.content" -}}
{{ $postfix := .postfix -}}
{{ $content := .content -}}
{{ $ctx := .ctx -}}
{{ $defaultContent := include "base.configMaps.default.content" (dict "postfix" $postfix "ctx" $ctx) | fromYaml -}}
{{ $content = mustMergeOverwrite $defaultContent $content -}}
{{ $payload := dict -}}
{{ if eq $postfix "envVars" -}}
{{ $payload = include "base.configMaps.envVars.payload" (dict "content" $content "ctx" $ctx) | fromYaml -}}
{{ else if eq $postfix "files" -}}
{{ $payload = include "base.configMaps.files.payload" (dict "content" $content "ctx" $ctx) | fromYaml -}}
{{ else -}}
{{ $payload = include "base.configMaps.others.payload" (dict "content" $content "ctx" $ctx) | fromYaml -}}
{{- end }}
{{ if $payload.data -}}
{{ $_ := set $content "data" $payload.data -}}
{{ else -}}
{{ $_ := unset $content "data" -}}
{{- end }}
{{ if $payload.binaryData -}}
{{ $_ := set $content "binaryData" $payload.binaryData -}}
{{ else -}}
{{ $_ := unset $content "binaryData" -}}
{{- end }}
{{ if not $content.metadata.annotations -}}
{{ $_ := unset $content.metadata "annotations" -}}
{{- end }}
{{ tpl ($content | toYaml) $ctx.abs }}
{{- end }}

{{/*
Usage: {{ include "base.configMaps.envVars.content" (dict "content" $content "ctx" $ctx) }}
*/}}
{{ define "base.configMaps.envVars.payload" -}}
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
Usage: {{ include "base.configMaps.files.content" (dict "content" $content "ctx" $ctx) }}
*/}}
{{ define "base.configMaps.files.payload" -}}
{{ $content := .content -}}
{{ $ctx := .ctx -}}
{{ if $content.data -}}
{{ print "data:" }}
{{ range $k, $v := $content.data -}}
{{ $filepath := $k -}}
{{ printf "%s: |" (include "base.util.dnsCompatible" (dict "filepath" $filepath)) | indent 2 }}
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
Usage: {{ include "base.volumes.configMap.volume.name" (dict "ctx" $ctx) }}
*/}}
{{ define "base.configMaps.files.volume.name" -}}
{{ $ctx := .ctx -}}
{{ print "config-map-files" }}
{{- end }}

{{/*
Usage: {{ include "base.volumes.configMap.volumes" (dict "ctx" $ctx) }}
*/}}
{{ define "base.configMaps.files.volumes" -}}
{{ $ctx := .ctx -}}
{{ $content := .content -}}
{{ $defaultContent := include "base.configMaps.default.content" (dict "postfix" "files" "ctx" $ctx) | fromYaml -}}
{{ $content = mustMergeOverwrite $defaultContent $content -}}
{{ $volumes := list -}}
{{ if and $content.enabled $content.data -}}
{{ $volumes = append $volumes (include "base.configMaps.files.volume" (dict "ctx" $ctx) | fromYaml) -}}
{{- end }}
volumes: {{ $volumes | toYaml | nindent 2 }}
{{- end }}

{{/*
Usage: {{ include "base.volumes.configMap.volume" (dict "ctx" $ctx) }}
*/}}
{{ define "base.configMaps.files.volume" -}}
{{ $ctx := .ctx -}}
name: {{ include "base.configMaps.files.volume.name" (dict "ctx" $ctx) }}
configMap:
  name: {{ include "base.configMaps.name" (dict "postfix" "files" "ctx" $ctx) }}
{{- end }}

{{/*
Usage: {{ include "base.configMaps.files.volumeMounts" (dict "content" $content "ctx" $ctx) }}
*/}}
{{ define "base.configMaps.files.volumeMounts" -}}
{{ $content := .content -}}
{{ $ctx := .ctx -}}
{{ $defaultContent := include "base.configMaps.default.content" (dict "postfix" "files" "ctx" $ctx) | fromYaml -}}
{{ $content = mustMergeOverwrite $defaultContent $content -}}
{{ $mounts := list -}}
{{ if and $content.enabled $content.data -}}
{{ range $path, $_ := $content.data -}}
{{ $name := include "base.configMaps.files.volume.name" (dict "ctx" $ctx) -}}
{{ $defaultMount := include "base.volumeMounts.files.default" (dict "path" $path "name" $name "ctx" $ctx) | fromYaml -}}
{{ $mount := mustMergeOverwrite $defaultMount $content.mount -}}
{{ $mounts = append $mounts $mount -}}
{{- end }}
{{- end }}
volumeMounts: {{ $mounts | toYaml | nindent 2 }}
{{- end }}

{{/*
Usage: {{ include "base.configMaps.envFrom" (dict "envVars" $envVars "ctx" $ctx) }}
*/}}
{{ define "base.configMaps.envFrom" -}}
{{ $envVars := .envVars -}}
{{ $ctx := .ctx -}}
{{ $default := include "base.configMaps.default.content" (dict "postfix" "envVars" "ctx" $ctx) | fromYaml -}}
{{ $envVars = mustMergeOverwrite $default $envVars -}}
{{ $items := list -}}
{{ if and $envVars.data $envVars.enabled -}}
{{ $items = append $items (dict "configMapRef" (dict "name" $envVars.metadata.name)) -}}
{{- end }}
{{ dict "envFrom" $items | toYaml }}
{{- end }}

{{/*
Usage: {{ include "base.configMaps.others.content" (dict "content" $content "ctx" $ctx) }}
*/}}
{{ define "base.configMaps.others.payload" -}}
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
Usage: {{ include "base.configMaps.name" (dict "postfix" $postfix "ctx" $ctx) }}
*/}}
{{ define "base.configMaps.name" -}}
{{ $postfix := .postfix -}}
{{ $ctx := .ctx -}}
{{ printf "%s-%s" (include "base.fullname" (dict "ctx" $ctx)) ($postfix | kebabcase) }}
{{- end }}

{{/*
Usage: {{ include "base.configMaps.default.content" (dict "postfix" $postfix "ctx" $ctx) }}
*/}}
{{ define "base.configMaps.default.content" -}}
{{ $ctx := .ctx -}}
{{ $postfix := .postfix -}}
enabled: true
metadata:
  name: {{ include "base.configMaps.name" (dict "postfix" $postfix "ctx" $ctx) }}
  labels: {{ include "base.labels" (dict "ctx" $ctx) | nindent 4 }}
  annotations: {}
data: {}
binaryData: {}
mount: {}
{{- end }}

{{/*
Usage: {{ include "base.configMaps.default" (dict "ctx" $ctx) }}
*/}}
{{ define "base.configMaps.default" -}}
{{ $ctx := .ctx -}}
envVars: {}
files: {}
{{- end }}

{{/*
Usage: {{ $configMaps := include "base.configMaps.default.merge" (dict "ctx" $ctx) | fromYaml -}}
*/}}
{{ define "base.configMaps.default.merged" -}}
{{ $ctx := .ctx -}}
{{ $default := include "base.configMaps.default" (dict "ctx" $ctx) | fromYaml -}}
{{ $configMaps := $ctx.val.configMaps | default dict }}
{{ mustMergeOverwrite $default $configMaps | toYaml }}
{{- end }}
