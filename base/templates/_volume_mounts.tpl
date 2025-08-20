{{/*
Template for volume mounts
Usage: {{ include "base.volumeMounts" (dict "val" $val "ctx" $ctx) }}
*/}}
{{ define "base.volumeMounts" -}}
{{ $ctx := .ctx -}}
{{ $val := .val -}}
{{ $volumeMounts := list -}}
{{ $cmVolumeMounts := include "base.configMaps.files.volumeMounts" (dict "content" $val.configMaps.files "ctx" $ctx) | fromYaml -}}
{{ range $cmVolumeMounts.volumeMounts -}}
{{ $volumeMounts = append $volumeMounts . -}}
{{ end -}}
{{ $secretVolumeMounts := include "base.secrets.files.volumeMounts" (dict "content" $val.secrets.files "ctx" $ctx) | fromYaml -}}
{{ range $secretVolumeMounts.volumeMounts -}}
{{ $volumeMounts = append $volumeMounts . -}}
{{ end -}}
{{ if $val.persistentVolumeClaims -}}
{{ $pvcVolumeMounts := include "base.persistentVolumeClaims.volumeMounts" (dict "persistentVolumeClaims" $val.persistentVolumeClaims "ctx" $ctx) | fromYaml -}}
{{ range $pvcVolumeMounts.volumeMounts -}}
{{ $volumeMounts = append $volumeMounts . -}}
{{ end -}}
{{ end -}}
{{ if ne (len $volumeMounts) 0 -}}
volumeMounts: {{ toYaml $volumeMounts | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Template for configmap volume mount
Usage: {{ include "base.volumeMounts.default" (dict "path" $k "name" $name "ctx" $ctx) }}
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
