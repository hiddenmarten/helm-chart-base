{{/*
Service template for baserary chart
Usage: {{ include "base.service" (dict "service" .Values.service "ctx" $) }}
*/}}
{{ define "base.service" -}}
{{ $service := .service -}}
{{ $ctx := .ctx -}}
{{ $defaults := include "base.defaults" (dict "ctx" $ctx) | fromYaml -}}
{{ $service = mustMergeOverwrite $defaults.service $service -}}
{{ $ports := include "base.service.ports" (dict "ports" $service.spec.ports "ctx" $ctx) | fromYaml -}}
{{ $service = mustMergeOverwrite $service (dict "spec" $ports) -}}
{{ if and $service.enabled $service.spec.ports -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "base.fullname" (dict "ctx" $ctx) }}
  labels: {{ include "base.labels" (dict "ctx" $ctx) | nindent 4 }}
  {{- with $service.annotations }}
  annotations: {{ tpl (toYaml .) $ctx | nindent 4 }}
  {{- end }}
spec: {{ tpl (toYaml $service.spec) $ctx | nindent 2 }}
---
{{- end }}
{{- end }}

{{/*
Tempate rewriting ports as a map to ports as a list
Usage: {{ include "base.service" (dict "ports" $ports "ctx" $ctx) }}
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
{{ if $portsList -}}
ports: {{ $portsList | toYaml | nindent 2 }}
{{- end }}
{{- end }}
