{{/*
Template that makes path dns-compatible
Usage: {{ include "base.util.dnsCompatible" (dict "filepath" $filepath) }}
*/}}
{{ define "base.util.dnsCompatible" -}}
{{ $filepath := .filepath -}}
{{ $filepath | replace "/" "___" | quote }}
{{- end }}
