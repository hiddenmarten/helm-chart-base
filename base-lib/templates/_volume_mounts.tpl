{{/*
Template for volume mounts
Usage: {{ include "base-lib.volumeMounts" (dict "val" $val "ctx" $ctx) }}
*/}}
{{ define "base-lib.volumeMounts" -}}
{{ $ctx := .ctx -}}
{{ $val := .val -}}
{{ $volumeMounts := list -}}
{{ $cmVolumeMounts := include "base-lib.configMaps.files.volumeMounts" (dict "content" $val.configMaps.files "ctx" $ctx) | fromYaml -}}
{{ range $cmVolumeMounts.volumeMounts -}}
{{ $volumeMounts = append $volumeMounts . -}}
{{ end -}}
{{ if and $val.secrets.files.enabled $val.secrets.files.data -}}
{{ $secretVolumeMounts := include "base-lib.secrets.files.volumeMounts" (dict "files" $val.secrets.files "ctx" $ctx) | fromYaml -}}
{{ range $secretVolumeMounts.volumeMounts -}}
{{ $volumeMounts = append $volumeMounts . -}}
{{ end -}}
{{ end -}}
{{ if $val.persistentVolumeClaims -}}
{{ $pvcVolumeMounts := include "base-lib.persistentVolumeClaims.volumeMounts" (dict "persistentVolumeClaims" $val.persistentVolumeClaims "ctx" $ctx) | fromYaml -}}
{{ range $pvcVolumeMounts.volumeMounts -}}
{{ $volumeMounts = append $volumeMounts . -}}
{{ end -}}
{{ end -}}
{{ if ne (len $volumeMounts) 0 -}}
{{ print "volumeMounts:" | indent 10 }}
{{ toYaml $volumeMounts | indent 12 }}
{{- end }}
{{- end }}

{{/*
Template for configmap volume mount
Usage: {{ include "base-lib.volumeMounts.default" (dict "path" $k "name" $name "ctx" $ctx) }}
*/}}
{{ define "base-lib.volumeMounts.files.default" -}}
{{ $path := .path -}}
{{ $name := .name -}}
{{ $ctx := .ctx -}}
name: {{ $name }}
mountPath: {{ $path }}
subPath: {{ include "base-lib.util.dnsCompatible" (dict "filepath" $path) }}
readOnly: true
{{- end }}
