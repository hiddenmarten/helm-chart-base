{{/*
Template for volumes
Usage: {{ include "base-lib.volumes" (dict "val" $val "ctx" $ctx) }}
*/}}
{{ define "base-lib.volumes" -}}
{{ $ctx := .ctx -}}
{{ $val := .val -}}
{{ $volumes := list -}}
{{ if and $val.configMaps.files.enabled $val.configMaps.files.data -}}
{{ $volume := include "base-lib.configMaps.files.volume" (dict "ctx" $ctx) | fromYaml -}}
{{ $volumes = append $volumes $volume -}}
{{ end -}}
{{ if and $val.secrets.files.enabled $val.secrets.files.data -}}
{{ $volume := include "base-lib.secrets.files.volume" (dict "ctx" $ctx) | fromYaml -}}
{{ $volumes = append $volumes $volume -}}
{{ end -}}
{{ if $val.persistentVolumeClaims -}}
{{ range $k, $_ := $val.persistentVolumeClaims -}}
{{ $volume := include "base-lib.persistentVolumeClaims.volume" (dict "postfix" $k "ctx" $ctx) | fromYaml -}}
{{ $volumes = append $volumes $volume -}}
{{ end -}}
{{ end -}}
{{ if ne (len $volumes) 0 -}}
{{ print "volumes:" | indent 6 }}
{{ $volumes | toYaml | indent 8 }}
{{ end -}}
{{ end -}}
