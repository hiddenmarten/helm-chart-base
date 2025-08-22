{{/*
PersistentVolumeClaim template for baserary chart
Usage: {{ include "base.persistentVolumeClaims" (dict "persistentVolumeClaims" .Values.persistentVolumeClaims "ctx" $ctx) }}
*/}}
{{ define "base.persistentVolumeClaims" -}}
{{ $persistentVolumeClaims := .persistentVolumeClaims -}}
{{ $ctx := .ctx -}}
{{- range $postfix, $content := $persistentVolumeClaims }}
{{ $content = include "base.persistentVolumeClaims.content" (dict "postfix" $postfix "content" $content "ctx" $ctx) | fromYaml -}}
{{ if and $content.enabled $content.spec.resources.requests.storage -}}
apiVersion: v1
kind: PersistentVolumeClaim
{{ $_ := unset $content "enabled" -}}
{{ $_ = unset $content "mount" -}}
{{ $content | toYaml }}
---
{{- end }}
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base.persistentVolumeClaims.content" (dict "postfix" $postfix "content" $content "ctx" $ctx) }}
*/}}
{{ define "base.persistentVolumeClaims.content" -}}
{{ $postfix := .postfix -}}
{{ $content := .content -}}
{{ $ctx := .ctx -}}
{{ $defaultContent := include "base.persistentVolumeClaims.default.content" (dict "postfix" $postfix "ctx" $ctx) | fromYaml -}}
{{ $content = mustMergeOverwrite $defaultContent $content -}}
{{ if not $content.metadata.annotations -}}
{{ $_ := unset $content.metadata "annotations" -}}
{{- end }}
{{ tpl ($content | toYaml) $ctx }}
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
Usage: {{ include "base.persistentVolumeClaims.default.content" (dict "postfix" $postfix "ctx" $ctx) }}
*/}}
{{ define "base.persistentVolumeClaims.default.content" -}}
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
{{ range $postfix, $content := $persistentVolumeClaims -}}
{{ $defaultContent := include "base.persistentVolumeClaims.default.content" (dict "postfix" $postfix "ctx" $ctx) | fromYaml -}}
{{ $content = mustMergeOverwrite $defaultContent $content -}}
{{ if and $content.enabled $content.spec -}}
{{ $volumes = append $volumes (include "base.persistentVolumeClaims.volume" (dict "postfix" $postfix "ctx" $ctx) | fromYaml) -}}
{{- end }}
{{- end }}
volumes: {{ $volumes | toYaml | nindent 2 }}
{{- end }}

{{/*
Usage: {{ include "base.persistentVolumeClaims.volumeMounts" (dict "persistentVolumeClaims" $persistentVolumeClaims "ctx" $ctx) }}
*/}}
{{ define "base.persistentVolumeClaims.volumeMounts" -}}
{{ $ctx := .ctx -}}
{{ $persistentVolumeClaims := .persistentVolumeClaims }}
{{ $mounts := list -}}
{{ range $postfix, $content := $persistentVolumeClaims -}}
{{ $defaultContent := include "base.persistentVolumeClaims.default.content" (dict "postfix" $postfix "ctx" $ctx) | fromYaml -}}
{{ $content = mustMergeOverwrite $defaultContent $content -}}
{{ if and $content.enabled $content.spec -}}
{{ $name := include "base.persistentVolumeClaims.volume.name" (dict "postfix" $postfix "ctx" $ctx) -}}
{{ $defaultMount := include "base.persistentVolumeClaims.volumeMount.default" (dict "name" $name "ctx" $ctx) | fromYaml -}}
{{ $mount := mustMergeOverwrite $defaultMount $content.mount -}}
{{ $mounts = append $mounts $mount -}}
{{- end }}
{{- end }}
volumeMounts: {{ $mounts | toYaml | nindent 2 }}
{{- end }}

{{/*
Usage: {{ include "base.persistentVolumeClaims.volumeMount.default" (dict "name" $name "ctx" $ctx) }}
*/}}
{{ define "base.persistentVolumeClaims.volumeMount.default" -}}
{{ $name := .name -}}
{{ $ctx := .ctx -}}
name: {{ $name }}
{{- end }}
