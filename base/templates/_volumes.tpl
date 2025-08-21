{{/*
Template for volumes
Usage: {{ include "base.volumes" (dict "configMaps" $configMaps "secrets" $secrets "persistentVolumeClaims" $persistentVolumeClaims "ctx" $ctx) }}
*/}}
{{ define "base.volumes" -}}
{{ $ctx := .ctx -}}
{{ $configMaps := .configMaps -}}
{{ $secrets := .secrets -}}
{{ $persistentVolumeClaims := .persistentVolumeClaims -}}
{{ $volumes := list -}}
{{ $cmVolumes := include "base.configMaps.files.volumes" (dict "content" $configMaps.files "ctx" $ctx) | fromYaml -}}
{{ range $cmVolumes.volumes -}}
{{ $volumes = append $volumes . -}}
{{ end -}}
{{ $secretVolumes := include "base.secrets.files.volumes" (dict "content" $secrets.files "ctx" $ctx) | fromYaml -}}
{{ range $secretVolumes.volumes -}}
{{ $volumes = append $volumes . -}}
{{ end -}}
{{ $pvcVolumes := include "base.persistentVolumeClaims.volumes" (dict "persistentVolumeClaims" $persistentVolumeClaims "ctx" $ctx) | fromYaml -}}
{{ range $pvcVolumes.volumes -}}
{{ $volumes = append $volumes . -}}
{{ end -}}
{{ if ne (len $volumes) 0 -}}
volumes: {{ $volumes | toYaml | nindent 2 }}
{{ end -}}
{{ end -}}
