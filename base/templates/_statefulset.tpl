{{/*
Usage: {{ include "base.statefulset" (dict "ctx" $ctx) }}
*/}}
{{ define "base.statefulset" -}}
{{ $ctx := .ctx -}}
{{ $statefulset := include "base.statefulset.merged" (dict "ctx" $ctx) | fromYaml -}}
{{ $persistentVolumeClaims := include "base.persistentVolumeClaims.merged" (dict "ctx" $ctx) | fromYaml -}}
{{ $service := include "base.service.merged" (dict "ctx" $ctx) | fromYaml -}}
{{ $content := include "base.statefulset.content" (dict "statefulset" $statefulset "persistentVolumeClaims" $persistentVolumeClaims "service" $service "ctx" $ctx) | fromYaml -}}
{{ if $content.enabled -}}
apiVersion: apps/v1
kind: StatefulSet
{{ $_ := unset $content "enabled" -}}
{{ $content | toYaml }}
---
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base.statefulset.content" (dict "statefulset" $statefulset "persistentVolumeClaims" $persistentVolumeClaims "service" $service "ctx" $ctx) }}
*/}}
{{ define "base.statefulset.content" -}}
{{ $ctx := .ctx -}}
{{ $statefulset := .statefulset -}}
{{ $persistentVolumeClaims := .persistentVolumeClaims -}}
{{ $service := .service -}}
{{ $default := include "base.statefulset.default" (dict "ctx" $ctx) | fromYaml -}}
{{ $sourceVolumeClaimTemplates := include "base.statefulset.volumeClaimTemplates.default.merge" (dict "volumeClaimTemplates" $statefulset.spec.volumeClaimTemplates "ctx" $ctx) | fromYaml -}}
{{ $volumeClaimTemplates := include "base.statefulset.volumeClaimTemplates" (dict "volumeClaimTemplates" $sourceVolumeClaimTemplates "ctx" $ctx) | fromYaml -}}
{{ $volumeMounts := include "base.persistentVolumeClaims.volumeMounts" (dict "persistentVolumeClaims" $sourceVolumeClaimTemplates "ctx" $ctx) | fromYaml }}
{{ $statefulset = mustMergeOverwrite $default $statefulset -}}
{{ $pod := include "base.pod" (dict "pod" (index $statefulset.spec "template") "persistentVolumeClaims" $persistentVolumeClaims "service" $service "ctx" $ctx) | fromYaml -}}
{{ $containers := include "base.statefulset.containers.override" (dict "containers" $pod.spec.containers "volumeMounts" $volumeMounts "ctx" $ctx) | fromYaml -}}
{{ $podSpec := mustMergeOverwrite $pod.spec $containers -}}
{{ $_ := set $pod "spec" $podSpec -}}
{{ $spec := dict "spec" (dict "template" $pod "volumeClaimTemplates" $volumeClaimTemplates.volumeClaimTemplates "serviceName" $service.metadata.name) -}}
{{ mustMergeOverwrite $default $spec | toYaml }}
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
{{ $content := mustMergeOverwrite $default $v -}}
{{ $_ := set $dict $k $content -}}
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
{{- range $postfix, $persistentVolumeClaim := $volumeClaimTemplates }}
{{ $content := include "base.persistentVolumeClaims.content" (dict "postfix" $postfix "persistentVolumeClaim" $persistentVolumeClaim "ctx" $ctx) | fromYaml -}}
{{ if and $content.enabled $content.spec.resources.requests.storage -}}
{{ $_ := unset $content "enabled" -}}
{{ $_ = unset $content "mount" -}}
{{ $list = append $list $content }}
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
