{{/*
Usage: {{ include "base.pod" (dict "val" $val "ctx" $ctx) }}
*/}}
{{ define "base.pod" -}}
{{ $ctx := .ctx -}}
{{ $val := .val -}}
{{ $defaults := include "base.pod.default" (dict "val" $val "ctx" $ctx) | fromYaml -}}
{{ $defaults | toYaml }}
{{- end }}

{{/*
Usage: {{ include "base.pod.default" (dict "val" $val "ctx" $ctx) }}
*/}}
{{ define "base.pod.default" -}}
{{ $ctx := .ctx -}}
{{ $val := .val -}}
metadata:
  labels: {{ include "base.labels" (dict "ctx" $ctx) | nindent 4 }}
spec:
  serviceAccountName: {{ include "base.serviceAccount.name" (dict "serviceAccount" $val.serviceAccount "ctx" $ctx) }}
  {{ $volumes := include "base.volumes" (dict "configMaps" $val.configMaps "secrets" $val.secrets "persistentVolumeClaims" $val.persistentVolumeClaims "ctx" $ctx) | fromYaml -}}
  {{ if $volumes -}}
  volumes: {{ $volumes.volumes | toYaml | nindent 4 }}
  {{- end }}
  {{ $container := include "base.pod.container" (dict "val" $val "ctx" $ctx) | fromYaml -}}
  {{ $containers := list $container -}}
  containers: {{ $containers | toYaml | nindent 4 }}
{{- end }}

{{/*
Usage: {{ include "base.pod.container" (dict "val" $val "ctx" $ctx) }}
*/}}
{{ define "base.pod.container" -}}
{{ $ctx := .ctx -}}
{{ $val := .val -}}
name: {{ include "base.name" (dict "ctx" $ctx) }}
image: "{{ $val.image.repository }}:{{ $val.image.tag }}"
{{- if $val.service.ports }}
ports:
{{- range $k, $v := $val.service.ports }}
  - name: {{ $k }}
    containerPort: {{ $v.port }}
    protocol: {{ $v.protocol | default "TCP" }}
{{- end }}
{{- end }}
{{- if or $val.configMaps.envVars.data $val.secrets.envVars.data }}
envFrom:
{{- if $val.configMaps.envVars.data }}
  - configMapRef:
      name: {{ include "base.configMaps.name" (dict "postfix" "envVars" "ctx" $ctx) }}
{{- end }}
{{- if $val.secrets.envVars.data }}
  - secretRef:
      name: {{ include "base.secrets.name" (dict "postfix" "envVars" "ctx" $ctx) }}
{{- end }}
{{- end }}
{{ $volumeMounts := include "base.volumeMounts" (dict "configMaps" $val.configMaps "secrets" $val.secrets "persistentVolumeClaims" $val.persistentVolumeClaims "ctx" $ctx) | fromYaml -}}
{{ if $volumeMounts -}}
volumeMounts: {{ $volumeMounts.volumeMounts | toYaml | nindent 8 }}
{{- end }}
{{- end }}
