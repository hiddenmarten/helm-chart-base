{{/*
PersistentVolumeClaim template for baserary chart
Usage: {{ include "base.persistentVolumeClaims" (dict "ctx" $ctx) }}
*/}}
{{ define "base.persistentVolumeClaims" -}}
{{ $ctx := .ctx -}}
{{ $persistentVolumeClaims := include "base.persistentVolumeClaims.merged" (dict "ctx" $ctx) | fromYaml -}}
{{- range $postfix, $persistentVolumeClaim := $persistentVolumeClaims }}
{{ $unit := include "base.persistentVolumeClaims.unit" (dict "postfix" $postfix "persistentVolumeClaim" $persistentVolumeClaim "ctx" $ctx) | fromYaml -}}
{{ if and $unit.enabled $unit.spec.resources.requests.storage $unit.mount.mountPath -}}
apiVersion: v1
kind: PersistentVolumeClaim
{{ $_ := unset $unit "enabled" -}}
{{ $_ = unset $unit "mount" -}}
{{ $unit | toYaml }}
---
{{- end }}
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base.persistentVolumeClaims.unit" (dict "postfix" $postfix "persistentVolumeClaim" $persistentVolumeClaim "ctx" $ctx) }}
*/}}
{{ define "base.persistentVolumeClaims.unit" -}}
{{ $postfix := .postfix -}}
{{ $persistentVolumeClaim := .persistentVolumeClaim -}}
{{ $ctx := .ctx -}}
{{ $unit := include "base.persistentVolumeClaims.unit.merged" (dict "postfix" $postfix "persistentVolumeClaim" $persistentVolumeClaim "ctx" $ctx) | fromYaml -}}
{{ if not $unit.metadata.annotations -}}
{{ $_ := unset $unit.metadata "annotations" -}}
{{- end }}
{{ tpl ($unit | toYaml) $ctx.abs }}
{{- end }}

{{/*
Usage: {{ include "base.persistentVolumeClaims.name" (dict "postfix" $postfix "ctx" $ctx) }}
*/}}
{{ define "base.persistentVolumeClaims.name" -}}
{{ $postfix := .postfix -}}
{{ $ctx := .ctx -}}
{{ printf "%s-%s" (include "base.fullname" (dict "ctx" $ctx)) ($postfix | kebabcase) }}
{{- end }}

{{/*
Usage: {{ include "base.persistentVolumeClaims.unit.default" (dict "postfix" $postfix "ctx" $ctx) }}
*/}}
{{ define "base.persistentVolumeClaims.unit.default" -}}
{{ $ctx := .ctx -}}
{{ $postfix := .postfix -}}
enabled: true
metadata:
  name: {{ include "base.persistentVolumeClaims.name" (dict "postfix" $postfix "ctx" $ctx) }}
  labels: {{ include "base.labels" (dict "ctx" $ctx) | nindent 4 }}
  annotations: {}
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: null
mount: {}
{{- end }}

{{/*
Usage: {{ $persistentVolumeClaims := include "base.persistentVolumeClaims.unit.merged" (dict "postfix" $postfix "persistentVolumeClaim" $persistentVolumeClaim "ctx" $ctx) | fromYaml -}}
*/}}
{{ define "base.persistentVolumeClaims.unit.merged" -}}
{{ $ctx := .ctx -}}
{{ $postfix := .postfix -}}
{{ $persistentVolumeClaim := .persistentVolumeClaim -}}
{{ $default := include "base.persistentVolumeClaims.unit.default" (dict "postfix" $postfix "persistentVolumeClaim" $persistentVolumeClaim "ctx" $ctx) | fromYaml -}}
{{ mustMergeOverwrite $default $persistentVolumeClaim | toYaml }}
{{- end }}

{{/*
Usage: {{ include "base.persistentVolumeClaims.volume.name" (dict "postfix" $postfix "ctx" $ctx) }}
*/}}
{{ define "base.persistentVolumeClaims.volume.name" -}}
{{ $ctx := .ctx -}}
{{ $postfix := .postfix -}}
{{ printf "%s-%s" ("persistent-volume-claim" | kebabcase) ($postfix | kebabcase) }}
{{- end }}

{{/*
Usage: {{ include "base.persistentVolumeClaims.volume" (dict "postfix" $postfix "ctx" $ctx) }}
*/}}
{{ define "base.persistentVolumeClaims.volume" -}}
{{ $ctx := .ctx -}}
{{ $postfix := .postfix }}
name: {{ include "base.persistentVolumeClaims.volume.name" (dict "postfix" $postfix "ctx" $ctx) }}
persistentVolumeClaim:
  claimName: {{ include "base.persistentVolumeClaims.name" (dict "postfix" $postfix "ctx" $ctx) }}
{{- end }}

{{/*
Usage: {{ include "base.persistentVolumeClaims.volumes" (dict "persistentVolumeClaims" $persistentVolumeClaims "ctx" $ctx) }}
*/}}
{{ define "base.persistentVolumeClaims.volumes" -}}
{{ $ctx := .ctx -}}
{{ $persistentVolumeClaims := .persistentVolumeClaims }}
{{ $volumes := list -}}
{{ range $postfix, $unit := $persistentVolumeClaims -}}
{{ $default := include "base.persistentVolumeClaims.unit.default" (dict "postfix" $postfix "ctx" $ctx) | fromYaml -}}
{{ $unit = mustMergeOverwrite $default $unit -}}
{{ if and $unit.enabled $unit.spec.resources.requests.storage $unit.mount.mountPath -}}
{{ $volumes = append $volumes (include "base.persistentVolumeClaims.volume" (dict "postfix" $postfix "ctx" $ctx) | fromYaml) -}}
{{- end }}
{{- end }}
{{ dict "volumes" $volumes | toYaml }}
{{- end }}

{{/*
Usage: {{ include "base.persistentVolumeClaims.volumeMounts" (dict "persistentVolumeClaims" $persistentVolumeClaims "ctx" $ctx) }}
*/}}
{{ define "base.persistentVolumeClaims.volumeMounts" -}}
{{ $ctx := .ctx -}}
{{ $persistentVolumeClaims := .persistentVolumeClaims }}
{{ $list := list -}}
{{ range $postfix, $unit := $persistentVolumeClaims -}}
{{ $default := include "base.persistentVolumeClaims.unit.default" (dict "postfix" $postfix "ctx" $ctx) | fromYaml -}}
{{ $unit = mustMergeOverwrite $default $unit -}}
{{ if and $unit.enabled $unit.spec.resources.requests.storage $unit.mount.mountPath -}}
{{ $name := include "base.persistentVolumeClaims.volume.name" (dict "postfix" $postfix "ctx" $ctx) -}}
{{ $default := include "base.persistentVolumeClaims.volumeMount.default" (dict "name" $name "ctx" $ctx) | fromYaml -}}
{{ $item := mustMergeOverwrite $default $unit.mount -}}
{{ $list = append $list $item -}}
{{- end }}
{{- end }}
{{ dict "volumeMounts" $list | toYaml }}
{{- end }}

{{/*
Usage: {{ include "base.persistentVolumeClaims.volumeMount.default" (dict "name" $name "ctx" $ctx) }}
*/}}
{{ define "base.persistentVolumeClaims.volumeMount.default" -}}
{{ $name := .name -}}
{{ $ctx := .ctx -}}
{{ dict "name" $name | toYaml }}
{{- end }}


{{/*
Usage: {{ $persistentVolumeClaims := include "base.persistentVolumeClaims.merged" (dict "ctx" $ctx) | fromYaml -}}
*/}}
{{ define "base.persistentVolumeClaims.merged" -}}
{{ $ctx := .ctx -}}
{{ $persistentVolumeClaims := $ctx.val.persistentVolumeClaims | default dict -}}
{{ $persistentVolumeClaims | toYaml }}
{{- end }}
