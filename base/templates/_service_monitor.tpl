{{/*
ServiceMonitor template for baserary chart
Usage: {{ include "base.servicemonitor" (dict "val" .Values "ctx" $ctx) }}
*/}}
{{ define "base.servicemonitor" -}}
{{ $val := .val -}}
{{ $ctx := .ctx -}}
{{ $defaults := include "base.defaults" (dict "ctx" $ctx) | fromYaml -}}
{{ $val = mustMergeOverwrite $defaults $val -}}
{{ $spec := include "base.servicemonitor.spec" (dict "spec" $val.serviceMonitor.spec "ctx" $ctx) | fromYaml -}}
{{ $valSpec := dict "serviceMonitor" (dict "spec" $spec) -}}
{{ $val = mustMergeOverwrite $val $valSpec -}}
{{- if and $val.serviceMonitor.enabled $val.serviceMonitor.spec.endpoints }}
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: {{ include "base.fullname" (dict "ctx" $ctx) }}
  labels: {{ include "base.labels" (dict "ctx" $ctx) | nindent 4 }}
  {{- with $val.serviceMonitor.annotations }}
  annotations: {{ tpl (toYaml .) $ctx | nindent 4 }}
  {{- end }}
spec: {{ tpl (toYaml $val.serviceMonitor.spec) $ctx | nindent 2 }}
---
{{- end }}
{{- end }}


{{/*
ServiceMonitor http port name helper
Usage: {{ include "base.servicemonitor.spec" (dict "spec" $spec "ctx" $ctx) }}
*/}}
{{ define "base.servicemonitor.spec" -}}
{{ $ctx := .ctx -}}
{{ $spec := .spec -}}
{{ $listEndpoints := list -}}
{{ range $k, $v := $spec.endpoints -}}
{{ $endpoint := $v -}}
{{ if not $endpoint.port -}}
{{ $_ := set $endpoint "port" $k -}}
{{- end }}
{{ $listEndpoints = append $listEndpoints $endpoint -}}
{{- end }}
selector:
  matchLabels: {{ include "base.selectorLabels" (dict "ctx" $ctx) | nindent 6 }}
endpoints: {{ $listEndpoints | toYaml | nindent 2 }}
{{- end }}
