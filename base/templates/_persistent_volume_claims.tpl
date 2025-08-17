{{/*
PersistentVolumeClaim template for baserary chart
Usage: {{ include "base.persistentVolumeClaims" (dict "pvcs" .Values.persistentVolumeClaims "ctx" $) }}
*/}}
{{ define "base.persistentVolumeClaims" -}}
{{ $pvcs := .pvcs -}}
{{ $ctx := .ctx -}}
{{ $defaults := include "base.defaults" (dict "ctx" $ctx) | fromYaml -}}
{{ $pvcs = mustMergeOverwrite $defaults.persistentVolumeClaims $pvcs -}}
{{- range $k, $v := $pvcs }}
{{ $pvcSpec := include "base.persistentVolumeClaims.spec" (dict "spec" $v.spec "ctx" $ctx) | fromYaml -}}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ include "base.persistentVolumeClaims.name" (dict "postfix" $k "ctx" $ctx) }}
  labels: {{ include "base.labels" (dict "ctx" $ctx) | nindent 4 }}
  {{- with $v.annotations }}
  annotations: {{ tpl (toYaml .) $ctx | nindent 4 }}
  {{- end }}
spec: {{ tpl (toYaml $pvcSpec) $ctx | nindent 2 }}
---
{{- end }}
{{- end }}

{{/*
PersistentVolumeClaim spec helper
Usage: {{ include "base.persistentVolumeClaims.spec" (dict "pvc" $pvc "ctx" $ctx) }}
*/}}
{{ define "base.persistentVolumeClaims.spec" -}}
{{ $spec := .spec -}}
{{ $ctx := .ctx -}}
{{ $defaultSpec := include "base.persistentVolumeClaims.spec.default" (dict "ctx" $ctx) | fromYaml -}}
{{ $spec = mustMergeOverwrite $defaultSpec $spec -}}
{{ $spec | toYaml }}
{{- end }}

{{/*
PersistentVolumeClaim name helper
Usage: {{ include "base.persistentVolumeClaims.name" (dict "postfix" $postfix "ctx" $) }}
*/}}
{{ define "base.persistentVolumeClaims.name" -}}
{{ $postfix := .postfix -}}
{{ $ctx := .ctx -}}
{{ printf "%s-%s" (include "base.fullname" (dict "ctx" $ctx)) ($postfix | kebabcase) }}
{{- end }}

{{/*
PersistentVolumeClaim spec helper
Usage: {{ include "base.persistentVolumeClaims.spec.default" (dict "ctx" $ctx) }}
*/}}
{{ define "base.persistentVolumeClaims.spec.default" -}}
{{ $ctx := .ctx -}}
accessModes:
- ReadWriteOnce
resources:
  requests:
    storage: null
{{- end }}

{{/*
Usage: {{ include "base.volumes.persistentVolumeClaims.name" (dict "postfix" $postfix "ctx" $ctx) }}
*/}}
{{ define "base.persistentVolumeClaims.volume.name" -}}
{{ $ctx := .ctx -}}
{{ $postfix := .postfix -}}
{{ printf "%s-%s" ("persistentVolumeClaim" | kebabcase) $postfix }}
{{- end }}

{{/*
Usage: {{ include "base.volumes.persistentVolumeClaims.volume" (dict "postfix" $postfix "ctx" $ctx) }}
*/}}
{{ define "base.persistentVolumeClaims.volume" -}}
{{ $ctx := .ctx -}}
{{ $postfix := .postfix }}
name: {{ include "base.persistentVolumeClaims.volume.name" (dict "postfix" $postfix "ctx" $ctx) }}
persistentVolumeClaim:
  claimName: {{ include "base.persistentVolumeClaims.name" (dict "postfix" $postfix "ctx" $ctx) }}
{{- end }}

{{/*
Usage: {{ include "base.volumes.persistentVolumeClaims.volumeMounts" (dict "persistentVolumeClaims" $persistentVolumeClaims "ctx" $ctx) }}
*/}}
{{ define "base.persistentVolumeClaims.volumeMounts" -}}
{{ $ctx := .ctx -}}
{{ $persistentVolumeClaims := .persistentVolumeClaims }}
{{ $mounts := list -}}
{{ range $postfix, $content := $persistentVolumeClaims -}}
{{ $name := include "base.persistentVolumeClaims.volume.name" (dict "postfix" $postfix "ctx" $ctx) -}}
{{ $defaultMount := include "base.persistentVolumeClaims.volumeMount.default" (dict "name" $name "ctx" $ctx) | fromYaml -}}
{{ $mount := mustMergeOverwrite $defaultMount $content.mount -}}
{{ $mounts = append $mounts $mount -}}
{{- end }}
volumeMounts: {{ $mounts | toYaml | nindent 2 }}
{{- end }}

{{/*
Usage: {{ include "base.volumes.persistentVolumeClaims.volumeMount" (dict "ctx" $ctx) }}
*/}}
{{ define "base.persistentVolumeClaims.volumeMount.default" -}}
{{ $path := .path -}}
{{ $name := .name -}}
{{ $ctx := .ctx -}}
name: {{ $name }}
{{- end }}
