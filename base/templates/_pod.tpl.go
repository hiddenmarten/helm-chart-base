{{/*
Usage: {{ include "base.pod" (dict "val" $val "ctx" $ctx) }}
*/}}
{{ define "base.pod" -}}
{{ $ctx := .ctx -}}
{{ $val := .val -}}
{{ $defaults := include "base.pod.default" (dict "ctx" $ctx) | fromYaml -}}
{{ $override := include "base.pod.override" (dict "val" $val "ctx" $ctx) | fromYaml -}}
{{ mustMergeOverwrite $defaults $override | toYaml }}
{{- end }}

{{/*
Usage: {{ include "base.pod.override" (dict "val" $val "ctx" $ctx) }}
*/}}
{{ define "base.pod.override" -}}
{{ $ctx := .ctx -}}
{{ $val := .val -}}
{{ $spec := dict -}}
{{ $volumes := include "base.volumes" (dict "configMaps" $val.configMaps "secrets" $val.secrets "persistentVolumeClaims" $val.persistentVolumeClaims "ctx" $ctx) | fromYaml -}}
{{ if $volumes -}}
{{ $spec := mustMergeOverwrite $spec $volumes -}}
{{- end }}
{{ $containerList := list -}}
{{ range $k, $v := (index $val.deployment.spec "template").spec.container -}}
{{ $container := include "base.container" (dict "container" $v "service" $val.service "configMaps" $val.configMaps "secrets" $val.secrets "persistentVolumeClaims" $val.persistentVolumeClaims "ctx" $ctx) | fromYaml -}}
{{ $container = mustMergeOverwrite (dict "name" $k) $container -}}
{{ $containerList = append $containerList $container -}}
{{ end -}}
{{ $containers := dict "containers" $containerList -}}
{{ $serviceAccountName := dict "serviceAccountName" (include "base.serviceAccount.name" (dict "serviceAccount" $val.serviceAccount "ctx" $ctx)) -}}
{{ $spec = mustMergeOverwrite $spec $containers $serviceAccountName -}}
{{ dict "spec" $spec | toYaml }}
{{- end }}

{{/*
Usage: {{ include "base.pod.default" (dict "ctx" $ctx) }}
*/}}
{{ define "base.pod.default" -}}
{{ $ctx := .ctx -}}
metadata:
  labels: {{ include "base.labels" (dict "ctx" $ctx) | nindent 4 }}
spec: {}
{{- end }}
