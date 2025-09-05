{{/*
Template for volumes
Usage: {{ include "base.volumes" (dict "volumes" $volumes "ctx" $ctx) }}
*/}}
{{ define "base.volumes" -}}
{{ $ctx := .ctx -}}
{{ $volumes := .volumes -}}
{{ $configMaps := include "base.configMaps.merged" (dict "ctx" $ctx) | fromYaml -}}
{{ $secrets := include "base.secrets.merged" (dict "ctx" $ctx) | fromYaml -}}
{{ $persistentVolumeClaims := include "base.persistentVolumeClaims.merged" (dict "ctx" $ctx) | fromYaml -}}
{{ $volumesList := list -}}
{{ $cmVolumes := include "base.configMaps.files.volumes" (dict "unit" $configMaps.files "ctx" $ctx) | fromYaml -}}
{{ range $cmVolumes.volumes -}}
{{ $volumesList = append $volumesList . -}}
{{ end -}}
{{ $secretVolumes := include "base.secrets.files.volumes" (dict "unit" $secrets.files "ctx" $ctx) | fromYaml -}}
{{ range $secretVolumes.volumes -}}
{{ $volumesList = append $volumesList . -}}
{{ end -}}
{{ $pvcVolumes := include "base.persistentVolumeClaims.volumes" (dict "persistentVolumeClaims" $persistentVolumeClaims "ctx" $ctx) | fromYaml -}}
{{ range $pvcVolumes.volumes -}}
{{ $volumesList = append $volumesList . -}}
{{ end -}}
{{ if ne (len $volumesList) 0 -}}
volumes: {{ $volumesList | toYaml | nindent 2 }}
{{ end -}}
{{ end -}}
