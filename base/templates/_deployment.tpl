{{/*
Usage: {{ include "base.deployment" (dict "ctx" $ctx) }}
*/}}
{{ define "base.deployment" -}}
{{ $ctx := .ctx -}}
{{ $deployment := .deployment -}}
{{ $configMaps := .configMaps -}}
{{ $secrets := .secrets -}}
{{ $persistentVolumeClaims := .persistentVolumeClaims -}}
{{ $service := .service -}}
{{ $serviceAccount := .serviceAccount -}}
{{ $defaultConfigMaps := include "base.configMaps.default" (dict "ctx" $ctx) | fromYaml -}}
{{ $configMaps = mustMergeOverwrite $configMaps $defaultConfigMaps -}}
{{ $defaultSecrets := include "base.secrets.default" (dict "ctx" $ctx) | fromYaml -}}
{{ $secrets = mustMergeOverwrite $secrets $defaultSecrets -}}
{{ $content := include "base.deployment.content" (dict "deployment" $deployment "configMaps" $configMaps "secrets" $secrets "persistentVolumeClaims" $persistentVolumeClaims "service" $service "serviceAccount" $serviceAccount "ctx" $ctx) | fromYaml -}}
{{ if $content.enabled -}}
apiVersion: apps/v1
kind: Deployment
{{ $_ := unset $content "enabled" -}}
{{ $content | toYaml }}
---
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base.deployment.content" (dict "deployment" $deployment "configMaps" $configMaps "secrets" $secrets "persistentVolumeClaims" $persistentVolumeClaims "service" $service "serviceAccount" $serviceAccount "ctx" $ctx) }}
*/}}
{{ define "base.deployment.content" -}}
{{ $ctx := .ctx -}}
{{ $deployment := .deployment -}}
{{ $configMaps := .configMaps -}}
{{ $secrets := .secrets -}}
{{ $persistentVolumeClaims := .persistentVolumeClaims -}}
{{ $service := .service -}}
{{ $serviceAccount := .serviceAccount -}}
{{ $default := include "base.deployment.default" (dict "ctx" $ctx) | fromYaml -}}
{{ $deployment = mustMergeOverwrite $default $deployment -}}
{{ $pod := include "base.pod" (dict "pod" (index $deployment.spec "template") "configMaps" $configMaps "secrets" $secrets "persistentVolumeClaims" $persistentVolumeClaims "service" $service "serviceAccount" $serviceAccount "ctx" $ctx) | fromYaml -}}
{{ $spec := dict "spec" (dict "template" $pod) -}}
{{ $content := mustMergeOverwrite $default $spec -}}
{{ $content | toYaml }}
{{- end }}

{{/*
Usage: {{ include "base.deployment.default" (dict "ctx" $ctx) }}
*/}}
{{ define "base.deployment.default" -}}
{{ $ctx := .ctx -}}
enabled: true
metadata:
  name: {{ include "base.fullname" (dict "ctx" $ctx) }}
  labels: {{ include "base.labels" (dict "ctx" $ctx) | nindent 4 }}
spec:
  template: {}
  selector:
    matchLabels: {{ include "base.selectorLabels" (dict "ctx" $ctx) | nindent 6 }}
{{- end }}

{{/*
Usage: {{ $deployment := include "base.deployment.merged" (dict "ctx" $ctx) | fromYaml -}}
*/}}
{{ define "base.deployment.merged" -}}
{{ $ctx := .ctx -}}
{{ $default := include "base.deployment.default" (dict "ctx" $ctx) | fromYaml -}}
{{ $deployment := $ctx.val.deployment | default dict }}
{{ mustMergeOverwrite $default $deployment | toYaml }}
{{- end }}
