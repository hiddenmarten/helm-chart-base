{{/*
Template for volume mounts
Usage: {{ include "base-lib.volumeMounts" (dict "val" $val "ctx" $ctx) }}
*/}}
{{ define "base-lib.volumeMounts" -}}
{{ $ctx := .ctx -}}
{{ $val := .val -}}
{{ $volumeMounts := list -}}
{{ range $k, $_ := $val.configMaps.files.data -}}
{{ $name := include "base-lib.volumes.configMap.name" (dict "ctx" $ctx) -}}
{{ $volumeMount := include "base-lib.volumeMounts.files.mount" (dict "path" $k "name" $name "ctx" $ctx) | fromYaml -}}
{{ $volumeMounts = append $volumeMounts $volumeMount -}}
{{ end -}}
{{ range $k, $_ := $val.secrets.files.data -}}
{{ $name := include "base-lib.volumes.secret.name" (dict "ctx" $ctx) -}}
{{ $volumeMount := include "base-lib.volumeMounts.files.mount" (dict "path" "name" $name $k "ctx" $ctx) | fromYaml -}}
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
Usage: {{ include "base-lib.volumeMounts.mount" (dict "path" $k "name" $name "ctx" $ctx) }}
*/}}
{{ define "base-lib.volumeMounts.files.mount" -}}
{{ $path := .path -}}
{{ $name := .name -}}
{{ $ctx := .ctx -}}
name: {{ $name }}
mountPath: {{ $path }}
subPath: {{ include "base-lib.util.dnsCompatible" (dict "filepath" $path) }}
readOnly: true
{{- end }}
