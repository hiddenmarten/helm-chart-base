{{/*
Usage: {{ include "base.pod" (dict "pod" $pod "ctx" $ctx) }}
*/}}
{{ define "base.pod" -}}
{{ $ctx := .ctx -}}
{{ $pod := include "base.pod.merged" (dict "pod" .pod "ctx" $ctx) | fromYaml -}}
{{ $override := include "base.pod.override" (dict "pod" $pod "ctx" $ctx) | fromYaml -}}
{{ $pod = mustMergeOverwrite $pod $override -}}
{{ $pod | toYaml }}
{{- end }}

{{/*
Usage: {{ include "base.pod.override" (dict "pod" $pod "ctx" $ctx) }}
*/}}
{{ define "base.pod.override" -}}
{{ $ctx := .ctx -}}
{{ $pod := .pod -}}
{{ $spec := dict -}}
{{ $volumes := include "base.volumes" (dict "ctx" $ctx) | fromYaml -}}
{{ if $volumes -}}
{{ $spec := mustMergeOverwrite $spec $volumes -}}
{{- end }}
{{ $containerList := list -}}
{{ range $k, $v := $pod.spec.containers -}}
{{ $container := include "base.container" (dict "name" $k "container" $v "ctx" $ctx) | fromYaml -}}
{{ $containerList = append $containerList $container -}}
{{ end -}}
{{ if not (len $containerList) }}
{{ fail "at least one container is required" }}
{{ end -}}
{{ $allContainers := dict "containers" $containerList -}}
{{ $initContainersList := list -}}
{{ range $k, $v := $pod.spec.initContainers -}}
{{ $initContainer := include "base.container" (dict "name" $k "container" $v "ctx" $ctx) | fromYaml -}}
{{ $initContainersList = append $initContainersList $initContainer -}}
{{ end -}}
{{ if len $initContainersList -}}
{{ $_ := set $allContainers "initContainers" $initContainersList -}}
{{ end -}}
{{ $serviceAccountName := dict "serviceAccountName" (include "base.serviceAccount.name" (dict "ctx" $ctx)) -}}
{{ $spec = mustMergeOverwrite $spec $allContainers $serviceAccountName -}}
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
