{{/*
Template for volumes
Usage: {{ include "base.volumes" (dict "val" $val "ctx" $ctx) }}
*/}}
{{ define "base.volumes" -}}
{{ $ctx := .ctx -}}
{{ $val := .val -}}
{{ $volumes := list -}}
{{ $cmVolumes := include "base.configMaps.files.volumes" (dict "content" $val.configMaps.files "ctx" $ctx) | fromYaml -}}
{{ range $cmVolumes.volumes -}}
{{ $volumes = append $volumes . -}}
{{ end -}}
{{ $secretVolumes := include "base.secrets.files.volumes" (dict "content" $val.secrets.files "ctx" $ctx) | fromYaml -}}
{{ range $secretVolumes.volumes -}}
{{ $volumes = append $volumes . -}}
{{ end -}}
{{ if $val.persistentVolumeClaims -}}
{{ $pvcVolumes := include "base.persistentVolumeClaims.volumes" (dict "persistentVolumeClaims" $val.persistentVolumeClaims "ctx" $ctx) | fromYaml -}}
{{ range $pvcVolumes.volumes -}}
{{ $volumes = append $volumes . -}}
{{ end -}}
{{ end -}}
{{ if ne (len $volumes) 0 -}}
{{ print "volumes:" | indent 6 }}
{{ $volumes | toYaml | indent 8 }}
{{ end -}}
{{ end -}}
