{{/*
Usage: {{ include "base.allInOne.deployment" (dict "val" .Values "abs" $) }}
*/}}
{{ define "base.allInOne.deployment" -}}
{{ $ctx := dict "val" .val "abs" .abs -}}
{{ include "base.configMaps" (dict "ctx" $ctx) }}
{{ include "base.deployment" (dict "deployment" $ctx.val.deployment "configMaps" $ctx.val.configMaps "secrets" $ctx.val.secrets "persistentVolumeClaims" $ctx.val.persistentVolumeClaims "service" $ctx.val.service "serviceAccount" $ctx.val.serviceAccount "ctx" $ctx) }}
{{ include "base.ingress" (dict "ingress" $ctx.val.ingress "service" $ctx.val.service "ctx" $ctx) }}
{{ include "base.persistentVolumeClaims" (dict "ctx" $ctx) }}
{{ include "base.secrets" (dict "ctx" $ctx) }}
{{ include "base.service" (dict "ctx" $ctx) }}
{{ include "base.serviceAccount" (dict "ctx" $ctx) }}
{{ include "base.serviceMonitor" (dict "ctx" $ctx) }}
{{- end }}


{{/*
Usage: {{ include "base.allInOne.statefulset" (dict "val" .Values "abs" $) }}
*/}}
{{ define "base.allInOne.statefulset" -}}
{{ $val := include "base.allInOne.statefulset.val.merged" (dict "val" .val) | fromYaml -}}
{{ $ctx := dict "val" $val "abs" .abs -}}
{{ include "base.configMaps" (dict "ctx" $ctx) }}
{{ include "base.statefulset" (dict "statefulset" $ctx.val.statefulset "configMaps" $ctx.val.configMaps "secrets" $ctx.val.secrets "persistentVolumeClaims" $ctx.val.persistentVolumeClaims "service" $ctx.val.service "serviceAccount" $ctx.val.serviceAccount "ctx" $ctx) }}
{{ include "base.ingress" (dict "ingress" $ctx.val.ingress "service" $ctx.val.service "ctx" $ctx) }}
{{ include "base.persistentVolumeClaims" (dict "ctx" $ctx) }}
{{ include "base.secrets" (dict "ctx" $ctx) }}
{{ include "base.service" (dict "ctx" $ctx) }}
{{ include "base.serviceAccount" (dict "ctx" $ctx) }}
{{ include "base.serviceMonitor" (dict "ctx" $ctx) }}
{{- end }}

{{/*
Usage: {{ include "base.allInOne.statefulset.default" (dict) }}
*/}}
{{ define "base.allInOne.statefulset.val.default" -}}
service:
  spec:
    clusterIP: None
{{- end }}

{{/*
Usage: {{ $val = include "base.allInOne.statefulset.val.merged" (dict "val" $val) | fromYaml }}
*/}}
{{ define "base.allInOne.statefulset.val.merged" -}}
{{ $val := .val -}}
{{ $default := include "base.allInOne.statefulset.val.default" (dict) | fromYaml -}}
{{ mustMergeOverwrite $default $val | toYaml }}
{{- end }}
