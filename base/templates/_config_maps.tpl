{{/*
Usage: {{ include "base.configMaps" (dict "ctx" $ctx) }}
*/}}
{{ define "base.configMaps" -}}
{{ $ctx := .ctx -}}
{{ $configMaps := include "base.configMaps.merged" (dict "ctx" $ctx) | fromYaml -}}
{{- range $postfix, $unit := $configMaps }}
{{ $unit = include "base.configMaps.unit" (dict "postfix" $postfix "unit" $unit "ctx" $ctx) | fromYaml -}}
{{ if and $unit.enabled (or $unit.data $unit.binaryData) -}}
apiVersion: v1
kind: ConfigMap
{{ $_ := unset $unit "enabled" -}}
{{ $_ = unset $unit "mount" -}}
{{ $unit | toYaml }}
---
{{- end }}
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base.configMaps.unit" (dict "postfix" $postfix "unit" $unit "ctx" $ctx) }}
*/}}
{{ define "base.configMaps.unit" -}}
{{ $postfix := .postfix -}}
{{ $unit := .unit -}}
{{ $ctx := .ctx -}}
{{ $defaultunit := include "base.configMaps.unit.default" (dict "postfix" $postfix "ctx" $ctx) | fromYaml -}}
{{ $unit = mustMergeOverwrite $defaultunit $unit -}}
{{ $payload := dict -}}
{{ if eq $postfix "envVars" -}}
{{ $payload = include "base.configMaps.envVars.payload" (dict "unit" $unit "ctx" $ctx) | fromYaml -}}
{{ else if eq $postfix "files" -}}
{{ $payload = include "base.configMaps.files.payload" (dict "unit" $unit "ctx" $ctx) | fromYaml -}}
{{ else -}}
{{ $payload = include "base.configMaps.others.payload" (dict "unit" $unit "ctx" $ctx) | fromYaml -}}
{{- end }}
{{ if $payload.data -}}
{{ $_ := set $unit "data" $payload.data -}}
{{ else -}}
{{ $_ := unset $unit "data" -}}
{{- end }}
{{ if $payload.binaryData -}}
{{ $_ := set $unit "binaryData" $payload.binaryData -}}
{{ else -}}
{{ $_ := unset $unit "binaryData" -}}
{{- end }}
{{ if not $unit.metadata.annotations -}}
{{ $_ := unset $unit.metadata "annotations" -}}
{{- end }}
{{ tpl ($unit | toYaml) $ctx.abs }}
{{- end }}

{{/*
Usage: {{ include "base.configMaps.envVars.unit" (dict "unit" $unit "ctx" $ctx) }}
*/}}
{{ define "base.configMaps.envVars.payload" -}}
{{ $unit := .unit -}}
{{ $ctx := .ctx -}}
{{ if $unit.data -}}
{{ print "data: " }}
{{ range $k, $v := $unit.data -}}
{{ printf "%s: %s" $k $v | nindent 2 }}
{{- end }}
{{- end }}
{{- if $unit.binaryData }}
{{ fail "configMaps.envVars does not support 'binaryData'" }}
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base.configMaps.files.unit" (dict "unit" $unit "ctx" $ctx) }}
*/}}
{{ define "base.configMaps.files.payload" -}}
{{ $unit := .unit -}}
{{ $ctx := .ctx -}}
{{ if $unit.data -}}
{{ print "data:" }}
{{ range $k, $v := $unit.data -}}
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
{{- if $unit.binaryData }}
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
{{ $unit := .unit -}}
{{ $defaultunit := include "base.configMaps.unit.default" (dict "postfix" "files" "ctx" $ctx) | fromYaml -}}
{{ $unit = mustMergeOverwrite $defaultunit $unit -}}
{{ $volumes := list -}}
{{ if and $unit.enabled $unit.data -}}
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
Usage: {{ include "base.configMaps.files.volumeMounts" (dict "unit" $unit "ctx" $ctx) }}
*/}}
{{ define "base.configMaps.files.volumeMounts" -}}
{{ $unit := .unit -}}
{{ $ctx := .ctx -}}
{{ $defaultunit := include "base.configMaps.unit.default" (dict "postfix" "files" "ctx" $ctx) | fromYaml -}}
{{ $unit = mustMergeOverwrite $defaultunit $unit -}}
{{ $mounts := list -}}
{{ if and $unit.enabled $unit.data -}}
{{ range $path, $_ := $unit.data -}}
{{ $name := include "base.configMaps.files.volume.name" (dict "ctx" $ctx) -}}
{{ $defaultMount := include "base.volumeMounts.files.default" (dict "path" $path "name" $name "ctx" $ctx) | fromYaml -}}
{{ $mount := mustMergeOverwrite $defaultMount $unit.mount -}}
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
{{ $default := include "base.configMaps.unit.default" (dict "postfix" "envVars" "ctx" $ctx) | fromYaml -}}
{{ $envVars = mustMergeOverwrite $default $envVars -}}
{{ $items := list -}}
{{ if and $envVars.data $envVars.enabled -}}
{{ $items = append $items (dict "configMapRef" (dict "name" $envVars.metadata.name)) -}}
{{- end }}
{{ dict "envFrom" $items | toYaml }}
{{- end }}

{{/*
Usage: {{ include "base.configMaps.others.unit" (dict "unit" $unit "ctx" $ctx) }}
*/}}
{{ define "base.configMaps.others.payload" -}}
{{ $unit := .unit -}}
{{ $ctx := .ctx -}}
{{- with $unit.data }}
data: {{ toYaml . | nindent 2 }}
{{- end }}
{{- with $unit.binaryData }}
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
Usage: {{ include "base.configMaps.unit.default" (dict "postfix" $postfix "ctx" $ctx) }}
*/}}
{{ define "base.configMaps.unit.default" -}}
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
Usage: {{ $configMaps := include "base.configMaps.merged" (dict "ctx" $ctx) | fromYaml -}}
*/}}
{{ define "base.configMaps.merged" -}}
{{ $ctx := .ctx -}}
{{ $default := include "base.configMaps.default" (dict "ctx" $ctx) | fromYaml -}}
{{ $configMaps := $ctx.val.configMaps | default dict }}
{{ mustMergeOverwrite $default $configMaps | toYaml }}
{{- end }}
