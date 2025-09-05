{{/*
Service template for baserary chart
Usage: {{ include "base.service" (dict "ctx" $ctx) }}
*/}}
{{ define "base.service" -}}
{{ $ctx := .ctx -}}
{{ $service := include "base.service.merged" (dict "ctx" $ctx) | fromYaml -}}
{{ $unit := include "base.service.unit" (dict "service" $service "ctx" $ctx) | fromYaml -}}
{{ if and $unit.enabled $unit.spec.ports -}}
apiVersion: v1
kind: Service
{{ $_ := unset $unit "enabled" -}}
{{ $unit | toYaml }}
---
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base.service.unit" (dict "service" $service "ctx" $ctx) }}
*/}}
{{ define "base.service.unit" -}}
{{ $service := .service -}}
{{ $ctx := .ctx -}}
{{ $override := include "base.service.override" (dict "service" $service "ctx" $ctx) | fromYaml -}}
{{ $unit := mustMergeOverwrite $service $override -}}
{{ if not $unit.metadata.annotations -}}
{{ $_ := unset $unit.metadata "annotations" -}}
{{- end }}
{{ tpl ($unit | toYaml) $ctx.abs }}
{{- end }}

{{/*
Usage: {{ include "base.service.payload" (dict "unit" $unit "ctx" $ctx) }}
*/}}
{{ define "base.service.override" -}}
{{ $service := .service -}}
{{ $ctx := .ctx -}}
{{ $ports := include "base.service.ports" (dict "ports" $service.spec.ports "ctx" $ctx) | fromYaml -}}
{{ $payload := dict "spec" $ports -}}
{{ $payload | toYaml | nindent 2 }}
{{- end }}

{{/*
Usage: {{ include "base.service.ports" (dict "ports" $ports "ctx" $ctx) }}
*/}}
{{ define "base.service.ports" -}}
{{ $ports := .ports -}}
{{ $ctx := .ctx -}}
{{ $portsList := list -}}
{{- range $k, $v := $ports }}
{{ $port := $v -}}
{{ if not $port.name -}}
{{ $_ := set $port "name" $k -}}
{{ end -}}
{{ $portsList = append $portsList $port -}}
{{- end }}
{{ if len $portsList -}}
{{ dict "ports" $portsList | toYaml }}
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base.service.default" (dict "ctx" $ctx) }}
*/}}
{{ define "base.service.default" -}}
{{ $ctx := .ctx -}}
enabled: true
metadata:
  name: {{ include "base.fullname" (dict "ctx" $ctx) }}
  labels: {{ include "base.labels" (dict "ctx" $ctx) | nindent 4 }}
  annotations: {}
spec:
  ports: {}
  selector: {{ include "base.selectorLabels" (dict "ctx" $ctx) | nindent 4 }}
{{- end }}

{{/*
Usage: {{ $service := include "base.service.merged" (dict "ctx" $ctx) | fromYaml -}}
*/}}
{{ define "base.service.merged" -}}
{{ $ctx := .ctx -}}
{{ $default := include "base.service.default" (dict "ctx" $ctx) | fromYaml -}}
{{ $service := $ctx.val.service | default dict }}
{{ mustMergeOverwrite $default $service | toYaml }}
{{- end }}
