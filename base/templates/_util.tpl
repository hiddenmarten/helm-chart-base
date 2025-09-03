{{/*
Template that makes path dns-compatible
Usage: {{ include "base.util.dnsCompatible" (dict "filepath" $filepath) }}
*/}}
{{ define "base.util.dnsCompatible" -}}
{{ $filepath := .filepath -}}
{{ $filepath | replace "/" "___" | quote }}
{{- end }}

{{/*
Replace the value if already exists, unsets key if value for key is empty, if key does not exists, then returns the very same dict
Usage: {{ $dict = include "base.util.replaceOrUnset" (dict "dict" $dict "key" $key "value" $value) | fromYaml }}
*/}}
{{ define "base.util.replaceOrUnset" -}}
{{ $dict := .dict -}}
{{ $key := .key -}}
{{ $value := .value -}}
{{ if hasKey $dict $key -}}
{{ if index $dict $key -}}
{{ $_ := set $dict $key $value -}}
{{- else }}
{{ $_ := unset $dict $key -}}
{{- end }}
{{- end }}
{{ $dict | toYaml }}
{{- end }}
