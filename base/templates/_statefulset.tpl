{{/*
Usage: {{ include "base.statefulset" (dict "statefulset" $statefulset "configMaps" $configMaps "secrets" $secrets "persistentVolumeClaims" $persistentVolumeClaims "service" $service "serviceAccount" $serviceAccount "ctx" $ctx) }}
*/}}
{{ define "base.statefulset" -}}
{{ $ctx := .ctx -}}
{{ $statefulset := .statefulset -}}
{{ $configMaps := .configMaps -}}
{{ $secrets := .secrets -}}
{{ $persistentVolumeClaims := .persistentVolumeClaims -}}
{{ $service := .service -}}
{{ $serviceAccount := .serviceAccount -}}
{{ $defaultConfigMaps := include "base.configMaps.default" (dict "ctx" $ctx) | fromYaml -}}
{{ $configMaps = mustMergeOverwrite $configMaps $defaultConfigMaps -}}
{{ $defaultSecrets := include "base.secrets.default" (dict "ctx" $ctx) | fromYaml -}}
{{ $secrets = mustMergeOverwrite $secrets $defaultSecrets -}}
{{ $content := include "base.statefulset.content" (dict "statefulset" $statefulset "configMaps" $configMaps "secrets" $secrets "persistentVolumeClaims" $persistentVolumeClaims "service" $service "serviceAccount" $serviceAccount "ctx" $ctx) | fromYaml -}}
{{ if $content.enabled -}}
apiVersion: apps/v1
kind: StatefulSet
{{ $_ := unset $content "enabled" -}}
{{ $content | toYaml }}
---
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base.statefulset.content" (dict "statefulset" $statefulset "configMaps" $configMaps "secrets" $secrets "persistentVolumeClaims" $persistentVolumeClaims "service" $service "serviceAccount" $serviceAccount "ctx" $ctx) }}
*/}}
{{ define "base.statefulset.content" -}}
{{ $ctx := .ctx -}}
{{ $statefulset := .statefulset -}}
{{ $configMaps := .configMaps -}}
{{ $secrets := .secrets -}}
{{ $persistentVolumeClaims := .persistentVolumeClaims -}}
{{ $service := .service -}}
{{ $serviceAccount := .serviceAccount -}}
{{ $default := include "base.statefulset.default" (dict "ctx" $ctx) | fromYaml -}}
{{ $statefulset = mustMergeOverwrite $default $statefulset -}}
{{ $pod := include "base.pod" (dict "pod" (index $statefulset.spec "template") "configMaps" $configMaps "secrets" $secrets "persistentVolumeClaims" $persistentVolumeClaims "service" $service "serviceAccount" $serviceAccount "ctx" $ctx) | fromYaml -}}
{{ $volumeClaimTemplates := include "base.statefulset.volumeClaimTemplates" (dict "volumeClaimTemplates" $statefulset.spec.volumeClaimTemplates "ctx" $ctx) | fromYaml -}}
{{ $spec := dict "spec" (dict "template" $pod "volumeClaimTemplates" $volumeClaimTemplates.volumeClaimTemplates) -}}
{{ mustMergeOverwrite $default $spec | toYaml }}
{{- end }}

{{/*
Usage: {{ include "base.statefulset.volumeClaimTemplates" (dict "volumeClaimTemplates" $volumeClaimTemplates "ctx" $ctx) }}
*/}}
{{ define "base.statefulset.volumeClaimTemplates" -}}
{{ $ctx := .ctx -}}
{{ $volumeClaimTemplates := .volumeClaimTemplates -}}
{{ $list := list -}}
{{ $default := include "base.statefulset.volumeClaimTemplates.default" (dict "ctx" $ctx) | fromYaml -}}
{{ range $name, $content := $volumeClaimTemplates -}}
{{ $item := mustMergeOverwrite $default $content (dict "metadata" (dict "name" $name)) -}}
{{ if not $item.metadata.annotations -}}
{{ $_ := unset $item.metadata "annotations" -}}
{{- end }}
{{ $list = append $list $item -}}
{{- end }}
{{ dict "volumeClaimTemplates" $list | toYaml }}
{{- end }}

{{/*
Usage: {{ include "base.statefulset.default" (dict "ctx" $ctx) }}
*/}}
{{ define "base.statefulset.volumeClaimTemplates.default" -}}
{{ $ctx := .ctx -}}
metadata:
  labels: {{ include "base.labels" (dict "ctx" $ctx) | nindent 4 }}
  annotations: {}
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: ""
{{- end }}

{{/*
Usage: {{ include "base.statefulset.default" (dict "ctx" $ctx) }}
*/}}
{{ define "base.statefulset.default" -}}
{{ $ctx := .ctx -}}
enabled: true
metadata:
  name: {{ include "base.fullname" (dict "ctx" $ctx) }}
  labels: {{ include "base.labels" (dict "ctx" $ctx) | nindent 4 }}
spec:
  template: {}
  selector:
    matchLabels: {{ include "base.selectorLabels" (dict "ctx" $ctx) | nindent 6 }}
{{/*  Service should take name from $service variable merged with default*/}}
  serviceName: {{ include "base.fullname" (dict "ctx" $ctx) }}
  volumeClaimTemplates: {}
{{- end }}
