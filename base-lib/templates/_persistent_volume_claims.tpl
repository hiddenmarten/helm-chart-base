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
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ include "base-lib.persistentVolumeClaims.name" (dict "postfix" $k "ctx" $ctx) }}
  labels: {{ include "base-lib.labels" (dict "ctx" $ctx) | nindent 4 }}
  {{- with $v.annotations }}
  annotations: {{ tpl (toYaml .) $ctx | nindent 4 }}
  {{- end }}
spec: {{ include "base-lib.persistentVolumeClaims.spec" (dict "v" $v "ctx" $ctx) | nindent 2 }}
---
{{- end }}
{{- end }}

{{/*
PersistentVolumeClaim spec helper
Usage: {{ include "base-lib.persistentVolumeClaims.spec" (dict "pvc" $pvc "ctx" $ctx) }}
*/}}
{{ define "base-lib.persistentVolumeClaims.spec" -}}
{{ $pvc := .pvc -}}
{{ $ctx := .ctx -}}
{{ with $pvc.spec -}}
{{ tpl (toYaml .) $ctx }}
{{- end }}
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
