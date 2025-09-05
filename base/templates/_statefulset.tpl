{{/*
Usage: {{ include "base.statefulset" (dict "ctx" $ctx) }}
*/}}
{{ define "base.statefulset" -}}
{{ $ctx := .ctx -}}
{{ $statefulset := include "base.statefulset.merged" (dict "ctx" $ctx) | fromYaml -}}
{{ $unit := include "base.statefulset.unit" (dict "statefulset" $statefulset "ctx" $ctx) | fromYaml -}}
{{ if $unit.enabled -}}
apiVersion: apps/v1
kind: StatefulSet
{{ $_ := unset $unit "enabled" -}}
{{ $unit | toYaml }}
---
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base.statefulset.unit" (dict "statefulset" $statefulset "service" $service "ctx" $ctx) }}
*/}}
{{ define "base.statefulset.unit" -}}
{{ $ctx := .ctx -}}
{{ $statefulset := .statefulset -}}
{{ $spec := $statefulset.spec -}}
{{ $service := include "base.service.merged" (dict "ctx" $ctx) | fromYaml -}}
{{ $_ := set $spec "serviceName" $service.metadata.name -}}
{{ $sourceVolumeClaimTemplates := include "base.statefulset.volumeClaimTemplates.default.merge" (dict "volumeClaimTemplates" $spec.volumeClaimTemplates "ctx" $ctx) | fromYaml -}}
{{ $volumeClaimTemplates := include "base.statefulset.volumeClaimTemplates" (dict "volumeClaimTemplates" $sourceVolumeClaimTemplates "ctx" $ctx) | fromYaml -}}
{{ $_ = set $spec "volumeClaimTemplates" $volumeClaimTemplates.volumeClaimTemplates -}}
{{ $volumeMounts := include "base.persistentVolumeClaims.volumeMounts" (dict "persistentVolumeClaims" $sourceVolumeClaimTemplates "ctx" $ctx) | fromYaml }}
{{ $pod := include "base.pod" (dict "pod" (index $spec "template") "ctx" $ctx) | fromYaml -}}
{{ $containers := include "base.statefulset.containers.override" (dict "containers" $pod.spec.containers "volumeMounts" $volumeMounts "ctx" $ctx) | fromYaml -}}
{{ $podSpec := mustMergeOverwrite $pod.spec $containers -}}
{{ $_ = set $pod "spec" $podSpec -}}
{{ $_ = set $spec "template" $pod -}}
{{ $_ = set $statefulset "spec" $spec -}}
{{ tpl ($statefulset | toYaml) $ctx.abs }}
{{- end }}

{{/*
Usage: {{ include "base.statefulset.containers.override" (dict "containers" $containers "volumeMounts" $volumeMounts "ctx" $ctx) }}
*/}}
{{ define "base.statefulset.containers.override" -}}
{{ $ctx := .ctx -}}
{{ $containers := .containers -}}
{{ $volumeMounts := .volumeMounts -}}
{{ $list := list -}}
{{ range $containers -}}
{{ $item := mustMergeOverwrite (dict "volumeMounts" list) . -}}
{{ $_ := set $item "volumeMounts" (concat $item.volumeMounts $volumeMounts.volumeMounts) -}}
{{ if not (len $item.volumeMounts) }}
{{ $_ := unset $item "volumeMounts" -}}
{{- end }}
{{ $list = append $list $item -}}
{{- end }}
{{ dict "containers" $list | toYaml }}
{{- end }}

{{/*
Usage: {{ include "base.statefulset.volumeClaimTemplates.default.merge" (dict "volumeClaimTemplates" $volumeClaimTemplates "ctx" $ctx) }}
*/}}
{{ define "base.statefulset.volumeClaimTemplates.default.merge" -}}
{{ $ctx := .ctx -}}
{{ $volumeClaimTemplates := .volumeClaimTemplates -}}
{{ $dict := dict -}}
{{ range $k, $v := $volumeClaimTemplates -}}
{{ $default := dict "metadata" (dict "name" $k) "mount" (dict "name" $k) -}}
{{ $unit := mustMergeOverwrite $default $v -}}
{{ $_ := set $dict $k $unit -}}
{{ end -}}
{{ $dict | toYaml }}
{{- end }}

{{/*
Usage: {{ include "base.statefulset.volumeClaimTemplates" (dict "volumeClaimTemplates" $volumeClaimTemplates "ctx" $ctx) }}
*/}}
{{ define "base.statefulset.volumeClaimTemplates" -}}
{{ $ctx := .ctx -}}
{{ $volumeClaimTemplates := .volumeClaimTemplates -}}
{{ $list := list -}}
{{- range $postfix, $unit := $volumeClaimTemplates }}
{{ $unit := include "base.persistentVolumeClaims.unit" (dict "postfix" $postfix "unit" $unit "ctx" $ctx) | fromYaml -}}
{{ if and $unit.enabled $unit.spec.resources.requests.storage -}}
{{ $_ := unset $unit "enabled" -}}
{{ $_ = unset $unit "mount" -}}
{{ $list = append $list $unit }}
{{- end }}
{{- end }}
{{ dict "volumeClaimTemplates" $list | toYaml }}
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
  volumeClaimTemplates: {}
{{- end }}

{{/*
Usage: {{ $statefulset := include "base.statefulset.merged" (dict "ctx" $ctx) | fromYaml -}}
*/}}
{{ define "base.statefulset.merged" -}}
{{ $ctx := .ctx -}}
{{ $default := include "base.statefulset.default" (dict "ctx" $ctx) | fromYaml -}}
{{ $statefulset := $ctx.val.statefulset | default dict }}
{{ mustMergeOverwrite $default $statefulset | toYaml }}
{{- end }}
