{{/*
Usage: {{ include "base.secrets" (dict "ctx" $ctx) }}
*/}}
{{ define "base.secrets" -}}
{{ $ctx := .ctx -}}
{{ $secrets := include "base.secrets.merged" (dict "ctx" $ctx) | fromYaml -}}
{{- range $postfix, $unit := $secrets }}
{{ $unit = include "base.secrets.unit" (dict "postfix" $postfix "unit" $unit "ctx" $ctx) | fromYaml -}}
{{ if and $unit.enabled (or $unit.data $unit.stringData) -}}
apiVersion: v1
kind: Secret
{{ $_ := unset $unit "enabled" -}}
{{ $_ = unset $unit "mount" -}}
{{ $unit | toYaml }}
---
{{- end }}
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base.secrets.unit" (dict "postfix" $postfix "unit" $unit "ctx" $ctx) }}
*/}}
{{ define "base.secrets.unit" -}}
{{ $postfix := .postfix -}}
{{ $unit := .unit -}}
{{ $ctx := .ctx -}}
{{ $defaultunit := include "base.secrets.default.unit" (dict "postfix" $postfix "ctx" $ctx) | fromYaml -}}
{{ $unit = mustMergeOverwrite $defaultunit $unit -}}
{{ $payload := dict -}}
{{ if eq $postfix "envVars" -}}
{{ $payload = include "base.secrets.envVars.payload" (dict "unit" $unit "ctx" $ctx) | fromYaml -}}
{{ else if eq $postfix "files" -}}
{{ $payload = include "base.secrets.files.payload" (dict "unit" $unit "ctx" $ctx) | fromYaml -}}
{{ else -}}
{{ $payload = include "base.secrets.others.payload" (dict "unit" $unit "ctx" $ctx) | fromYaml -}}
{{- end }}
{{ if $payload.data -}}
{{ $_ := set $unit "data" $payload.data -}}
{{ else -}}
{{ $_ := unset $unit "data" -}}
{{- end }}
{{ if $payload.stringData -}}
{{ $_ := set $unit "stringData" $payload.stringData -}}
{{ else -}}
{{ $_ := unset $unit "stringData" -}}
{{- end }}
{{ if not $unit.metadata.annotations -}}
{{ $_ := unset $unit.metadata "annotations" -}}
{{- end }}
{{ tpl ($unit | toYaml) $ctx.abs }}
{{- end }}

{{/*
Usage: {{ include "base.secrets.envVars.payload" (dict "unit" $unit "ctx" $ctx) }}
*/}}
{{ define "base.secrets.envVars.payload" -}}
{{ $unit := .unit -}}
{{ $ctx := .ctx -}}
{{ if $unit.data -}}
{{ print "data: " }}
{{ range $k, $v := $unit.data -}}
{{ printf "%s: %s" (tpl $k $ctx.abs) ((tpl $v $ctx.abs) | b64enc) | nindent 2 }}
{{- end }}
{{- end }}
{{- if $unit.stringData }}
{{ fail "secrets.envVars does not support 'stringData'" }}
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base.secrets.files.payload" (dict "unit" $unit "ctx" $ctx) }}
*/}}
{{ define "base.secrets.files.payload" -}}
{{ $unit := .unit -}}
{{ $ctx := .ctx -}}
{{ if $unit.data -}}
{{ print "data:" }}
{{ range $k, $v := $unit.data -}}
{{ $filepath := tpl $k $ctx.abs -}}
{{ printf "%s: |" (include "base.util.dnsCompatible" (dict "filepath" $filepath)) | indent 2 }}
{{ if mustRegexMatch "(.+)(\\.yaml|\\.yml)$" (base $filepath) -}}
{{ (tpl ($v | toYaml) $ctx.abs | b64enc) | indent 4 }}
{{ else if mustRegexMatch "(.+)(\\.json)$" (base $filepath) -}}
{{ (tpl ($v | toJson) $ctx.abs | b64enc) | indent 4 }}
{{ else if mustRegexMatch "(.+)(\\.toml)$" (base $filepath) -}}
{{ (tpl ($v | toToml) $ctx.abs | b64enc) | indent 4 }}
{{ else -}}
{{ (tpl ($v | toString) $ctx.abs | b64enc) | indent 4 }}
{{ end -}}
{{- end }}
{{- end }}
{{- if $unit.stringData }}
{{ fail "secrets.files does not support 'stringData'" }}
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base.secrets.files.name" (dict "ctx" $ctx) }}
*/}}
{{ define "base.secrets.files.volume.name" -}}
{{ $ctx := .ctx -}}
{{ print "secret-files" }}
{{- end }}

{{/*
Usage: {{ include "base.volumes.secrets.volumes" (dict "ctx" $ctx) }}
*/}}
{{ define "base.secrets.files.volumes" -}}
{{ $ctx := .ctx -}}
{{ $unit := .unit -}}
{{ $defaultunit := include "base.secrets.default.unit" (dict "postfix" "files" "ctx" $ctx) | fromYaml -}}
{{ $unit = mustMergeOverwrite $defaultunit $unit -}}
{{ $volumes := list -}}
{{ if and $unit.enabled $unit.data -}}
{{ $volumes = append $volumes (include "base.secrets.files.volume" (dict "ctx" $ctx) | fromYaml) -}}
{{- end }}
volumes: {{ $volumes | toYaml | nindent 2 }}
{{- end }}

{{/*
Usage: {{ include "base.secrets.files.volume" (dict "ctx" $ctx) }}
*/}}
{{ define "base.secrets.files.volume" -}}
{{ $ctx := .ctx -}}
name: {{ include "base.secrets.files.volume.name" (dict "ctx" $ctx) }}
secret:
  secretName: {{ include "base.secrets.name" (dict "postfix" "files" "ctx" $ctx) }}
{{- end }}

{{/*
Usage: {{ include "base.secrets.files.volumeMounts" (dict "files" $files "ctx" $ctx) }}
*/}}
{{ define "base.secrets.files.volumeMounts" -}}
{{ $unit := .unit -}}
{{ $ctx := .ctx -}}
{{ $defaultunit := include "base.secrets.default.unit" (dict "postfix" "files" "ctx" $ctx) | fromYaml -}}
{{ $unit = mustMergeOverwrite $defaultunit $unit -}}
{{ $mounts := list -}}
{{ if and $unit.enabled $unit.data -}}
{{ range $path, $_ := $unit.data -}}
{{ $name := include "base.secrets.files.volume.name" (dict "ctx" $ctx) -}}
{{ $defaultMount := include "base.volumeMounts.files.default" (dict "path" $path "name" $name "ctx" $ctx) | fromYaml -}}
{{ $mount := mustMergeOverwrite $defaultMount $unit.mount -}}
{{ $mounts = append $mounts $mount -}}
{{- end }}
{{- end }}
volumeMounts: {{ $mounts | toYaml | nindent 2 }}
{{- end }}

{{/*
Usage: {{ include "base.secrets.envFrom" (dict "envVars" $envVars "ctx" $ctx) }}
*/}}
{{ define "base.secrets.envFrom" -}}
{{ $envVars := .envVars -}}
{{ $ctx := .ctx -}}
{{ $default := include "base.secrets.default.unit" (dict "postfix" "envVars" "ctx" $ctx) | fromYaml -}}
{{ $envVars = mustMergeOverwrite $default $envVars -}}
{{ $items := list -}}
{{ if and $envVars.data $envVars.enabled -}}
{{ $items = append $items (dict "secretRef" (dict "name" $envVars.metadata.name)) -}}
{{- end }}
{{ dict "envFrom" $items | toYaml }}
{{- end }}

{{/*
Usage: {{ include "base.secrets.others.payload" (dict "unit" $unit "ctx" $ctx) }}
*/}}
{{ define "base.secrets.others.payload" -}}
{{ $unit := .unit -}}
{{ $ctx := .ctx -}}
{{- with $unit.data }}
data: {{ tpl (. | toYaml) $ctx.abs | nindent 2 }}
{{- end }}
{{- with $unit.stringData }}
stringData: {{ tpl (. | toYaml) $ctx.abs | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base.secrets.name" (dict "postfix" $postfix "ctx" $ctx) }}
*/}}
{{ define "base.secrets.name" -}}
{{ $postfix := .postfix -}}
{{ $ctx := .ctx -}}
{{ printf "%s-%s" (include "base.fullname" (dict "ctx" $ctx)) ($postfix | kebabcase) }}
{{- end }}

{{/*
Usage: {{ include "base.secrets.default.unit" (dict "postfix" $postfix "ctx" $ctx) }}
*/}}
{{ define "base.secrets.default.unit" -}}
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

{{/*
Usage: {{ include "base.secrets.default" (dict "ctx" $ctx) }}
*/}}
{{ define "base.secrets.default" -}}
{{ $ctx := .ctx -}}
envVars: {}
files: {}
{{- end }}

{{/*
Usage: {{ $secrets := include "base.secrets.merged" (dict "ctx" $ctx) | fromYaml -}}
*/}}
{{ define "base.secrets.merged" -}}
{{ $ctx := .ctx -}}
{{ $default := include "base.secrets.default" (dict "ctx" $ctx) | fromYaml -}}
{{ $secrets := $ctx.val.secrets | default dict }}
{{ mustMergeOverwrite $default $secrets | toYaml }}
{{- end }}
