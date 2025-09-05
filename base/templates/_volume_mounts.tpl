
{{/*
Template for configmap volume mount
Usage: {{ include "base.volumeMounts.files.default" (dict "path" $k "name" $name "ctx" $ctx) }}
*/}}
{{ define "base.volumeMounts.files.default" -}}
{{ $path := .path -}}
{{ $name := .name -}}
{{ $ctx := .ctx -}}
name: {{ $name }}
mountPath: {{ $path }}
subPath: {{ include "base.util.dnsCompatible" (dict "filepath" $path) }}
readOnly: true
{{- end }}
