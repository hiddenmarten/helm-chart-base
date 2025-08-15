{{/*
Service template for base-library chart
Usage: {{ include "base-lib.service" (dict "service" .Values.service "ctx" $) }}
*/}}
{{ define "base-lib.service" -}}
{{ $service := .service -}}
{{ $ctx := .ctx -}}
{{ $defaults := include "base-lib.defaults" (dict "ctx" $ctx) | fromYaml -}}
{{ $service = mustMergeOverwrite $defaults.service $service -}}
{{ $ports := include "base-lib.service.ports" (dict "ports" $service.spec.ports "ctx" $ctx) | fromYaml -}}
{{ $service = mustMergeOverwrite $service (dict "spec" $ports) -}}
{{ if $service.spec.ports -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "base-lib.fullname" (dict "ctx" $ctx) }}
  labels: {{ include "base-lib.labels" (dict "ctx" $ctx) | nindent 4 }}
  {{- with $service.annotations }}
  annotations: {{ tpl (toYaml .) $ctx | nindent 4 }}
  {{- end }}
spec: {{ tpl (toYaml $service.spec) $ctx | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Tempate rewriting ports as a map to ports as a list
Usage: {{ include "base-lib.service" (dict "ports" $ports "ctx" $ctx) }}
*/}}
{{ define "base-lib.service.ports" -}}
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
