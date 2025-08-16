{{/*
Template for volume mounts
Usage: {{ include "base-lib.volumeMounts" (dict "val" $val "ctx" $ctx) }}
*/}}
{{ define "base-lib.volumeMounts" -}}
{{ $ctx := .ctx -}}
{{ $val := .val -}}
{{ $volumeMounts := list -}}
{{ if and $val.configMaps.files.enabled $val.configMaps.files.data -}}
{{ $cmVolumeMountsMounts := include "base-lib.configMaps.files.volumeMounts" (dict "files" $val.configMaps.files "ctx" $ctx) | fromYaml -}}
{{ range $cmVolumeMountsMounts.volumeMounts -}}
{{ $volumeMounts = append $volumeMounts . -}}
{{ end -}}
{{ end -}}
{{ range $k, $_ := $val.secrets.files.data -}}
{{ $name := include "base-lib.volumes.secret.name" (dict "ctx" $ctx) -}}
{{ $volumeMount := include "base-lib.volumeMounts.files.default" (dict "path" "name" $name $k "ctx" $ctx) | fromYaml -}}
{{ $volumeMounts = append $volumeMounts $volumeMount -}}
{{ end -}}
{{ if $val.persistentVolumeClaims -}}
{{ range $k, $v := $val.persistentVolumeClaims -}}
{{ $name := include "base-lib.volumes.persistentVolumeClaims.name" (dict "postfix" $k "ctx" $ctx) -}}
{{ $volumeMount := mustMergeOverwrite $v.mount (dict "name" $name) -}}
{{ $volumeMounts = append $volumeMounts $volumeMount -}}
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
