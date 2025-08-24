{{/*
Usage: {{ include "base.allInOne.deployment" (dict "val" $val "ctx" $ctx) }}
*/}}
{{ define "base.allInOne.deployment" -}}
{{ $val := .val -}}
{{ $ctx := .ctx -}}
{{ include "base.configMaps" (dict "configMaps" $val.configMaps "ctx" $ctx) }}
{{ include "base.deployment" (dict "deployment" $val.deployment "configMaps" $val.configMaps "secrets" $val.secrets "persistentVolumeClaims" $val.persistentVolumeClaims "service" $val.service "serviceAccount" $val.serviceAccount "ctx" $ctx) }}
{{ include "base.ingress" (dict "ingress" $val.ingress "service" $val.service "ctx" $ctx) }}
{{ include "base.persistentVolumeClaims" (dict "persistentVolumeClaims" $val.persistentVolumeClaims "ctx" $ctx) }}
{{ include "base.secrets" (dict "secrets" $val.secrets "ctx" $ctx) }}
{{ include "base.service" (dict "service" $val.service "ctx" $ctx) }}
{{ include "base.serviceAccount" (dict "serviceAccount" $val.serviceAccount "ctx" $ctx) }}
{{ include "base.serviceMonitor" (dict "serviceMonitor" $val.serviceMonitor "ctx" $ctx) }}
{{- end }}


{{/*
Usage: {{ include "base.allInOne.statefulset" (dict "val" $val "ctx" $ctx) }}
*/}}
{{ define "base.allInOne.statefulset" -}}
{{ $val := .val -}}
{{ $ctx := .ctx -}}
{{ $default := include "base.allInOne.statefulset.default" (dict "ctx" $ctx) | fromYaml -}}
{{ $val = mustMergeOverwrite $default $val -}}
{{ include "base.configMaps" (dict "configMaps" $val.configMaps "ctx" $ctx) }}
{{ include "base.statefulset" (dict "statefulset" $val.statefulset "configMaps" $val.configMaps "secrets" $val.secrets "persistentVolumeClaims" $val.persistentVolumeClaims "service" $val.service "serviceAccount" $val.serviceAccount "ctx" $ctx) }}
{{ include "base.ingress" (dict "ingress" $val.ingress "service" $val.service "ctx" $ctx) }}
{{ include "base.persistentVolumeClaims" (dict "persistentVolumeClaims" $val.persistentVolumeClaims "ctx" $ctx) }}
{{ include "base.secrets" (dict "secrets" $val.secrets "ctx" $ctx) }}
{{ include "base.service" (dict "service" $val.service "ctx" $ctx) }}
{{ include "base.serviceAccount" (dict "serviceAccount" $val.serviceAccount "ctx" $ctx) }}
{{ include "base.serviceMonitor" (dict "serviceMonitor" $val.serviceMonitor "ctx" $ctx) }}
{{- end }}

{{/*
Usage: {{ include "base.allInOne.statefulset.default" (dict "ctx" $ctx) }}
*/}}
{{ define "base.allInOne.statefulset.default" -}}
{{ $ctx := .ctx -}}
service:
  spec:
    clusterIP: None
{{- end }}
