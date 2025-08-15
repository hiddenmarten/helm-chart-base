{{/*
Template for volumes
Usage: {{ include "base-lib.volumes" (dict "val" $val "ctx" $ctx) }}
*/}}
{{ define "base-lib.volumes" -}}
{{ $ctx := .ctx -}}
{{ $val := .val -}}
{{ $volumes := list -}}
{{ if $val.configMaps.files.data -}}
{{ $volumes = append $volumes (include "base-lib.volumes.configMap.volume" (dict "ctx" $ctx) | fromYaml) -}}
{{ end -}}
{{ if $val.secrets.files.data -}}
{{ $volumes = append $volumes (include "base-lib.volumes.secret.volume" (dict "ctx" $ctx) | fromYaml) -}}
{{ end -}}
{{ if $val.persistentVolumeClaims -}}
{{ range $k, $_ := $val.persistentVolumeClaims -}}
{{ $volumes = append $volumes (include "base-lib.volumes.persistentVolumeClaims.volume" (dict "postfix" $k "ctx" $ctx) | fromYaml) -}}
{{ end -}}
{{ end -}}
{{ if ne (len $volumes) 0 -}}
{{ print "volumes:" | indent 6 }}
{{ toYaml $volumes | indent 8 }}
{{ end -}}
{{ end -}}

{{/*
Template for configmap files volume name
Usage: {{ include "base-lib.volumes.configMap.name" (dict "ctx" $ctx) }}
*/}}
{{ define "base-lib.volumes.configMap.name" -}}
{{ $ctx := .ctx -}}
{{ print "config-map-files" }}
{{- end }}

{{/*
Template for configmap volume
Usage: {{ include "base-lib.volumes.configMap.volume" (dict "ctx" $) }}
*/}}
{{ define "base-lib.volumes.configMap.volume" -}}
{{ $ctx := .ctx -}}
name: {{ include "base-lib.volumes.configMap.name" (dict "ctx" $ctx) }}
configMap:
  name: {{ include "base-lib.configMaps.name" (dict "postfix" "files" "ctx" $ctx) }}
{{- end }}

{{/*
Template for secret files volume name
Usage: {{ include "base-lib.volumes.secret.name" (dict "ctx" $ctx) }}
*/}}
{{ define "base-lib.volumes.secret.name" -}}
{{ $ctx := .ctx -}}
{{ print "secret-files" }}
{{- end }}

{{/*
Template for secret volume
Usage: {{ include "base-lib.volumes.secret.volume" (dict "ctx" $ctx) }}
*/}}
{{ define "base-lib.volumes.secret.volume" -}}
{{ $ctx := .ctx -}}
name: {{ include "base-lib.volumes.secret.name" (dict "ctx" $ctx) }}
secret:
  secretName: {{ include "base-lib.secrets.name" (dict "postfix" "files" "ctx" $ctx) }}
{{- end }}

{{/*
Template for PersistentVolumeClaims files volume name
Usage: {{ include "base-lib.volumes.persistentVolumeClaims.name" (dict "postfix" $postfix "ctx" $ctx) }}
*/}}
{{ define "base-lib.volumes.persistentVolumeClaims.name" -}}
{{ $ctx := .ctx -}}
{{ $postfix := .postfix -}}
{{ printf "%s-%s" ("persistentVolumeClaim" | kebabcase) $postfix }}
{{- end }}

{{/*
Template for PersistentVolumeClaims volume
Usage: {{ include "base-lib.volumes.persistentVolumeClaims.volume" (dict "postfix" $postfix "ctx" $ctx) }}
*/}}
{{ define "base-lib.volumes.persistentVolumeClaims.volume" -}}
{{ $ctx := .ctx -}}
{{ $postfix := .postfix }}
name: {{ include "base-lib.volumes.persistentVolumeClaims.name" (dict "postfix" $postfix "ctx" $ctx) }}
persistentVolumeClaim:
  claimName: {{ include "base-lib.persistentVolumeClaims.name" (dict "postfix" $postfix "ctx" $ctx) }}
{{- end }}
