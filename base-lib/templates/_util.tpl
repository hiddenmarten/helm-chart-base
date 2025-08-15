{{/*
Template that makes path dns-compatible
Usage: {{ include "base-lib.util.dnsCompatible" (dict "filepath" $filepath) }}
*/}}
{{ define "base-lib.util.dnsCompatible" -}}
{{ $filepath := .filepath -}}
{{ $filepath | replace "/" "___" | quote }}
{{- end }}
