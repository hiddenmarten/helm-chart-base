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
{{ $envFrom := include "base.pod.container.envFrom" (dict "val" $val "ctx" $ctx) | fromYaml -}}
{{ if len $envFrom.envFrom -}}
{{ $envFrom | toYaml }}
{{- end }}
{{ $volumeMounts := include "base.pod.container.volumeMounts" (dict "configMaps" $val.configMaps "secrets" $val.secrets "persistentVolumeClaims" $val.persistentVolumeClaims "ctx" $ctx) | fromYaml -}}
{{ if len $volumeMounts.volumeMounts -}}
{{ $volumeMounts | toYaml }}
{{- end }}
{{- end }}


{{/*
Usage: {{ include "base.pod.container.envFrom" (dict "val" $val "ctx" $ctx) }}
*/}}
{{ define "base.pod.container.envFrom" -}}
{{ $ctx := .ctx -}}
{{ $val := .val -}}
{{ $configMapRefs := include "base.configMaps.envFrom" (dict "envVars" $val.configMaps.envVars "ctx" $ctx) | fromYaml -}}
{{ $secretRefs := include "base.secrets.envFrom" (dict "envVars" $val.secrets.envVars "ctx" $ctx) | fromYaml -}}
{{ $items := concat $configMapRefs.envFrom $secretRefs.envFrom | default list -}}
{{ dict "envFrom" $items | toYaml }}
{{- end }}

{{/*
Template for volume mounts
Usage: {{ include "base.pod.container.volumeMounts" (dict "configMaps" $configMaps "secrets" $secrets "persistentVolumeClaims" $persistentVolumeClaims "ctx" $ctx) }}
*/}}
{{ define "base.pod.container.volumeMounts" -}}
{{ $ctx := .ctx -}}
{{ $configMaps := .configMaps -}}
{{ $secrets := .secrets -}}
{{ $persistentVolumeClaims := .persistentVolumeClaims -}}
{{ $cmVolumeMounts := include "base.configMaps.files.volumeMounts" (dict "content" $configMaps.files "ctx" $ctx) | fromYaml -}}
{{ $secretVolumeMounts := include "base.secrets.files.volumeMounts" (dict "content" $secrets.files "ctx" $ctx) | fromYaml -}}
{{ $pvcVolumeMounts := include "base.persistentVolumeClaims.volumeMounts" (dict "persistentVolumeClaims" $persistentVolumeClaims "ctx" $ctx) | fromYaml -}}
{{ $items := concat $cmVolumeMounts.volumeMounts $secretVolumeMounts.volumeMounts $pvcVolumeMounts.volumeMounts | default list -}}
{{ dict "volumeMounts" $items | toYaml }}
{{- end }}
