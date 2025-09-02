{{/*
Usage: {{ include "base.pod" (dict "pod" $pod "configMaps" $configMaps "secrets" $secrets "persistentVolumeClaims" $persistentVolumeClaims "service" $service "serviceAccount" $serviceAccount "ctx" $ctx) }}
*/}}
{{ define "base.pod" -}}
{{ $ctx := .ctx -}}
{{ $pod := .pod -}}
{{ $configMaps := .configMaps -}}
{{ $secrets := .secrets -}}
{{ $persistentVolumeClaims := .persistentVolumeClaims -}}
{{ $service := .service -}}
{{ $serviceAccount := .serviceAccount -}}
{{ $default := include "base.pod.default" (dict "ctx" $ctx) | fromYaml -}}
{{ $pod = mustMergeOverwrite $default $pod -}}
{{ $override := include "base.pod.override" (dict "pod" $pod "configMaps" $configMaps "secrets" $secrets "persistentVolumeClaims" $persistentVolumeClaims "service" $service "serviceAccount" $serviceAccount "ctx" $ctx) | fromYaml -}}
{{ $pod = mustMergeOverwrite $pod $override -}}
{{ $pod | toYaml }}
{{- end }}

{{/*
Usage: {{ include "base.pod.override" (dict "pod" $pod "configMaps" $configMaps "secrets" $secrets "persistentVolumeClaims" $persistentVolumeClaims "service" $service "serviceAccount" $serviceAccount "ctx" $ctx) }}
*/}}
{{ define "base.pod.override" -}}
{{ $ctx := .ctx -}}
{{ $pod := .pod -}}
{{ $configMaps := .configMaps -}}
{{ $secrets := .secrets -}}
{{ $persistentVolumeClaims := .persistentVolumeClaims -}}
{{ $service := .service -}}
{{ $serviceAccount := .serviceAccount -}}
{{ $spec := dict -}}
{{ $volumes := include "base.volumes" (dict "configMaps" $configMaps "secrets" $secrets "persistentVolumeClaims" $persistentVolumeClaims "ctx" $ctx) | fromYaml -}}
{{ if $volumes -}}
{{ $spec := mustMergeOverwrite $spec $volumes -}}
{{- end }}
{{ $containerList := list -}}
{{ range $k, $v := $pod.spec.containers -}}
{{ $container := include "base.container" (dict "container" $v "service" $service "configMaps" $configMaps "secrets" $secrets "persistentVolumeClaims" $persistentVolumeClaims "ctx" $ctx) | fromYaml -}}
{{ $container = mustMergeOverwrite (dict "name" $k) $container -}}
{{ $containerList = append $containerList $container -}}
{{ end -}}
{{ if not (len $containerList) }}
{{ fail "at least one container is required" }}
{{ end -}}
{{ $containers := dict "containers" $containerList -}}
{{ $serviceAccountName := dict "serviceAccountName" (include "base.serviceAccount.name" (dict "serviceAccount" $serviceAccount "ctx" $ctx)) -}}
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
spec:
  containers: {}
{{- end }}

{{/*
Usage: {{ $pod := include "base.pod.merged" (dict "pod" $pod "ctx" $ctx) | fromYaml -}}
*/}}
{{ define "base.pod.merged" -}}
{{ $pod := .pod -}}
{{ $ctx := .ctx -}}
{{ $default := include "base.pod.default" (dict "ctx" $ctx) | fromYaml -}}
{{ mustMergeOverwrite $default $pod | toYaml }}
{{- end }}
