{{/*
Usage: {{ include "base.volumes" (dict "volumes" $volumes "ctx" $ctx) }}
*/}}
{{ define "base.volumes" -}}
{{ $ctx := .ctx -}}
{{ $volumes := .volumes -}}
{{ $configMaps := include "base.configMaps.merged" (dict "ctx" $ctx) | fromYaml -}}
{{ $secrets := include "base.secrets.merged" (dict "ctx" $ctx) | fromYaml -}}
{{ $persistentVolumeClaims := include "base.persistentVolumeClaims.merged" (dict "ctx" $ctx) | fromYaml -}}
{{ $volumesList := list -}}
{{ $asListVolumes := include "base.volumes.asList" (dict "volumes" $volumes "ctx" $ctx) | fromYaml -}}
{{ $cmVolumes := include "base.configMaps.files.volumes" (dict "unit" $configMaps.files "ctx" $ctx) | fromYaml -}}
{{ $secretVolumes := include "base.secrets.files.volumes" (dict "unit" $secrets.files "ctx" $ctx) | fromYaml -}}
{{ $pvcVolumes := include "base.persistentVolumeClaims.volumes" (dict "persistentVolumeClaims" $persistentVolumeClaims "ctx" $ctx) | fromYaml -}}
{{ $volumesList = concat $volumesList $cmVolumes.volumes $secretVolumes.volumes $pvcVolumes.volumes $asListVolumes.volumes -}}
{{ if ne (len $volumesList) 0 -}}
volumes: {{ $volumesList | toYaml | nindent 2 }}
{{ end -}}
{{ end -}}

{{/*
Usage: {{ include "base.volumes.asList" (dict "volumes" $volumes "ctx" $ctx) }}
*/}}
{{ define "base.volumes.asList" -}}
{{ $ctx := .ctx -}}
{{ $volumes := .volumes -}}
{{ $volumesList := list -}}
{{ range $name, $unit := $volumes }}
{{ $_ := set $unit "name" $name -}}
{{ $volumesList = append $volumesList $unit -}}
{{ end -}}
{{ dict "volumes" $volumesList | toYaml }}
{{ end -}}
