{{/*
PersistentVolumeClaim template for base-library chart
Usage: {{ include "base-lib.persistentVolumeClaims" (dict "pvcs" .Values.persistentVolumeClaims "ctx" $) }}
*/}}
{{ define "base-lib.persistentVolumeClaims" -}}
{{ $pvcs := .pvcs -}}
{{ $ctx := .ctx -}}
{{ $defaults := include "base-lib.defaults" (dict "ctx" $ctx) | fromYaml -}}
{{ $pvcs = mustMergeOverwrite $defaults.persistentVolumeClaims $pvcs -}}
{{- range $k, $v := $pvcs }}
{{ $pvcSpec := include "base-lib.persistentVolumeClaims.spec" (dict "spec" $v.spec "ctx" $ctx) | fromYaml -}}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ include "base-lib.persistentVolumeClaims.name" (dict "postfix" $k "ctx" $ctx) }}
  labels: {{ include "base-lib.labels" (dict "ctx" $ctx) | nindent 4 }}
  {{- with $v.annotations }}
  annotations: {{ tpl (toYaml .) $ctx | nindent 4 }}
  {{- end }}
spec: {{ tpl (toYaml $pvcSpec) $ctx | nindent 2 }}
---
{{- end }}
{{- end }}

{{/*
PersistentVolumeClaim spec helper
Usage: {{ include "base-lib.persistentVolumeClaims.spec" (dict "pvc" $pvc "ctx" $ctx) }}
*/}}
{{ define "base-lib.persistentVolumeClaims.spec" -}}
{{ $spec := .spec -}}
{{ $ctx := .ctx -}}
{{ $defaultSpec := include "base-lib.persistentVolumeClaims.spec.default" (dict "ctx" $ctx) | fromYaml -}}
{{ $spec = mustMergeOverwrite $defaultSpec $spec -}}
{{ $spec | toYaml }}
{{- end }}

{{/*
PersistentVolumeClaim name helper
Usage: {{ include "base-lib.persistentVolumeClaims.name" (dict "postfix" $postfix "ctx" $) }}
*/}}
{{ define "base-lib.persistentVolumeClaims.name" -}}
{{ $postfix := .postfix -}}
{{ $ctx := .ctx -}}
{{ printf "%s-%s" (include "base-lib.fullname" (dict "ctx" $ctx)) ($postfix | kebabcase) }}
{{- end }}

{{/*
PersistentVolumeClaim spec helper
Usage: {{ include "base-lib.persistentVolumeClaims.spec.default" (dict "ctx" $ctx) }}
*/}}
{{ define "base-lib.persistentVolumeClaims.spec.default" -}}
{{ $ctx := .ctx -}}
accessModes:
- ReadWriteOnce
resources:
  requests:
    storage: null
{{- end }}

{{/*
Usage: {{ include "base-lib.volumes.persistentVolumeClaims.name" (dict "postfix" $postfix "ctx" $ctx) }}
*/}}
{{ define "base-lib.persistentVolumeClaims.volume.name" -}}
{{ $ctx := .ctx -}}
{{ $postfix := .postfix -}}
{{ printf "%s-%s" ("persistentVolumeClaim" | kebabcase) $postfix }}
{{- end }}

{{/*
Usage: {{ include "base-lib.volumes.persistentVolumeClaims.volume" (dict "postfix" $postfix "ctx" $ctx) }}
*/}}
{{ define "base-lib.persistentVolumeClaims.volume" -}}
{{ $ctx := .ctx -}}
{{ $postfix := .postfix }}
name: {{ include "base-lib.persistentVolumeClaims.volume.name" (dict "postfix" $postfix "ctx" $ctx) }}
persistentVolumeClaim:
  claimName: {{ include "base-lib.persistentVolumeClaims.name" (dict "postfix" $postfix "ctx" $ctx) }}
{{- end }}

{{/*
Usage: {{ include "base-lib.volumes.persistentVolumeClaims.volumeMounts" (dict "persistentVolumeClaims" $persistentVolumeClaims "ctx" $ctx) }}
*/}}
{{ define "base-lib.persistentVolumeClaims.volumeMounts" -}}
{{ $ctx := .ctx -}}
{{ $persistentVolumeClaims := .persistentVolumeClaims }}
{{ $mounts := list -}}
{{ range $postfix, $content := $persistentVolumeClaims -}}
{{ $name := include "base-lib.persistentVolumeClaims.volume.name" (dict "postfix" $postfix "ctx" $ctx) -}}
{{ $defaultMount := include "base-lib.persistentVolumeClaims.volumeMount.default" (dict "name" $name "ctx" $ctx) | fromYaml -}}
{{ $mount := mustMergeOverwrite $defaultMount $content.mount -}}
{{ $mounts = append $mounts $mount -}}
{{- end }}
volumeMounts: {{ $mounts | toYaml | nindent 2 }}
{{- end }}

{{/*
Usage: {{ include "base-lib.volumes.persistentVolumeClaims.volumeMount" (dict "ctx" $ctx) }}
*/}}
{{ define "base-lib.persistentVolumeClaims.volumeMount.default" -}}
{{ $path := .path -}}
{{ $name := .name -}}
{{ $ctx := .ctx -}}
name: {{ $name }}
{{- end }}
