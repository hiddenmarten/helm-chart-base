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
  {{ $containers := list -}}
  {{ range $k, $v := (index $val.deployment.spec "template").spec.container -}}
  {{ $container := include "base.container" (dict "container" $v "service" $val.service "configMaps" $val.configMaps "secrets" $val.secrets "persistentVolumeClaims" $val.persistentVolumeClaims "ctx" $ctx) | fromYaml -}}
  {{ $container = mustMergeOverwrite (dict "name" $k) $container -}}
  {{ $containers = append $containers $container -}}
  {{ end -}}
  containers: {{ $containers | toYaml | nindent 4 }}
{{- end }}
