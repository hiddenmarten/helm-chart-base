{{/*
Usage: {{ include "base.pod" (dict "pod" $pod "ctx" $ctx) }}
*/}}
{{ define "base.pod" -}}
{{ $ctx := .ctx -}}
{{ $pod := include "base.pod.merged" (dict "pod" .pod "ctx" $ctx) | fromYaml -}}
{{ $pod = include "base.pod.override" (dict "pod" $pod "ctx" $ctx) | fromYaml -}}
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
{{ $pod = include "base.pod.override.annotations" (dict "pod" $pod "ctx" $ctx) | fromYaml }}
{{ $_ := set $pod "spec" $spec -}}
{{ $pod | toYaml }}
{{- end }}

{{/*
Usage: {{ $pod = include "base.pod.override.annotations" (dict "pod" $pod "ctx" $ctx) | fromYaml }}
*/}}
{{ define "base.pod.override.annotations" -}}
{{ $ctx := .ctx -}}
{{ $pod := .pod -}}
{{ $annotations := $pod.metadata.annotations | default dict -}}
{{ $configMaps := include "base.configMaps.merged" (dict "ctx" $ctx) | fromYaml -}}
{{ $configMapsHash := tpl ($configMaps | toYaml) $ctx.abs | sha256sum -}}
{{ $annotations = include "base.util.replaceOrUnset" (dict "dict" $annotations "key" "base.chart.hiddenmarten.me/config-maps-hash" "value" $configMapsHash) | fromYaml }}
{{ $secrets := include "base.secrets.merged" (dict "ctx" $ctx) | fromYaml -}}
{{ $secretsHash := tpl ($secrets | toYaml) $ctx.abs | sha256sum -}}
{{ $secretsHashKey := "base.chart.hiddenmarten.me/secrets-hash" -}}
{{ $annotations = include "base.util.replaceOrUnset" (dict "dict" $annotations "key" $secretsHashKey "value" $secretsHash) | fromYaml }}
{{ $metadata := include "base.util.replaceOrUnset" (dict "dict" $pod.metadata "key" "annotations" "value" $annotations) | fromYaml }}
{{ $_ := set $pod "metadata" $metadata -}}
{{ $pod | toYaml }}
{{- end }}

{{/*
Usage: {{ include "base.pod.default" (dict "ctx" $ctx) }}
*/}}
{{ define "base.pod.default" -}}
{{ $ctx := .ctx -}}
metadata:
  labels: {{ include "base.labels" (dict "ctx" $ctx) | nindent 4 }}
  annotations:
    # True as a strings as an expected value for annotation, basically we need non-empty string and that's it
    base.chart.hiddenmarten.me/config-maps-hash: "true"
    base.chart.hiddenmarten.me/secrets-hash: "true"
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
