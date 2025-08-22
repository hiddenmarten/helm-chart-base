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
{{ include "base.pod.container.image" (dict "image" $val.image "ctx" $ctx) }}
{{ $ports := include "base.pod.container.ports" (dict "val" $val.service "ctx" $ctx) | fromYaml -}}
{{ if len $ports.ports -}}
{{ $ports | toYaml }}
{{- end }}
{{ $envFrom := include "base.pod.container.envFrom" (dict "configMaps" $val.configMaps "secrets" $val.secrets "ctx" $ctx) | fromYaml -}}
{{ if len $envFrom.envFrom -}}
{{ $envFrom | toYaml }}
{{- end }}
{{ $volumeMounts := include "base.pod.container.volumeMounts" (dict "configMaps" $val.configMaps "secrets" $val.secrets "persistentVolumeClaims" $val.persistentVolumeClaims "ctx" $ctx) | fromYaml -}}
{{ if len $volumeMounts.volumeMounts -}}
{{ $volumeMounts | toYaml }}
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base.pod.container.image" (dict "image" $image "ctx" $ctx) }}
*/}}
{{ define "base.pod.container.image" -}}
{{ $ctx := .ctx -}}
{{ $image := .image -}}
{{ $default := include "base.pod.container.image.default" (dict "ctx" $ctx) | fromYaml -}}
{{ $image = mustMergeOverwrite $default $image -}}
{{ $value := "" -}}
{{ if $image.registry -}}
{{ $value = printf "%s/%s:%s" $image.registry $image.repository $image.tag -}}
{{ else -}}
{{ $value = printf "%s:%s" $image.repository $image.tag -}}
{{- end }}
{{ dict "image" $value | toYaml }}
{{- end }}

{{/*
Usage: {{ include "base.pod.container.image.default" (dict "ctx" $ctx) }}
*/}}
{{ define "base.pod.container.image.default" -}}
{{ $ctx := .ctx -}}
registry: ""
repository: ""
tag: latest
{{- end }}

{{/*
Usage: {{ include "base.pod.container.ports" (dict "service" $service "ctx" $ctx) }}
*/}}
{{ define "base.pod.container.ports" -}}
{{ $ctx := .ctx -}}
{{ $service := .service -}}
{{ $items := list -}}
{{ $defaultService := include "base.service.default.content" (dict "ctx" $ctx) | fromYaml -}}
{{ $service = mustMergeOverwrite $defaultService $service -}}
{{- range $k, $v := $service.spec.ports }}
{{ $item := dict "name" $k "containerPort" $v.port -}}
{{ $items = append $items $item -}}
{{- end }}
{{ dict "ports" $items | toYaml }}
{{- end }}

{{/*
Usage: {{ include "base.pod.container.envFrom" (dict "configMaps" $configMaps "secrets" $secrets "ctx" $ctx) }}
*/}}
{{ define "base.pod.container.envFrom" -}}
{{ $ctx := .ctx -}}
{{ $configMaps := .configMaps -}}
{{ $secrets := .secrets -}}
{{ $configMapRefs := include "base.configMaps.envFrom" (dict "envVars" $configMaps.envVars "ctx" $ctx) | fromYaml -}}
{{ $secretRefs := include "base.secrets.envFrom" (dict "envVars" $secrets.envVars "ctx" $ctx) | fromYaml -}}
{{ $items := concat $configMapRefs.envFrom $secretRefs.envFrom | default list -}}
{{ dict "envFrom" $items | toYaml }}
{{- end }}

{{/*
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
