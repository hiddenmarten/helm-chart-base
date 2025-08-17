{{/*
Usage: {{ include "base.configMaps.others.content" (dict "val" .Values "ctx" $) }}
*/}}
{{ define "base.allInOne.deployment" -}}
{{ $val := .val -}}
{{ $ctx := .ctx -}}
{{ include "base.configMaps" (dict "configMaps" $val.configMaps "ctx" $ctx) }}
{{ include "base.deployment" (dict "val" $val "ctx" $ctx) }}
{{ include "base.ingress" (dict "val" $val "ctx" $ctx) }}
{{ include "base.persistentVolumeClaims" (dict "pvcs" $val.persistentVolumeClaims "ctx" $ctx) }}
{{ include "base.secrets" (dict "secrets" $val.secrets "ctx" $ctx) }}
{{ include "base.service" (dict "service" $val.service "ctx" $ctx) }}
{{ include "base.serviceAccount" (dict "serviceAccount" $val.serviceAccount "ctx" $ctx) }}
{{ include "base.servicemonitor" (dict "val" $val "ctx" $ctx) }}
{{- end }}
