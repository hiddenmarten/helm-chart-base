{{/*
Service template for base-library chart
Usage: {{ include "base-lib.service" (dict "service" .Values.service "ctx" $) }}
*/}}
{{ define "base-lib.service" -}}
{{ $service := .svc -}}
{{ $ctx := .ctx -}}
{{ $defaults := include "base-lib.defaults" (dict "ctx" $ctx) | fromYaml -}}
{{ $service = mustMergeOverwrite $defaults.service $service -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "base-lib.fullname" (dict "ctx" $ctx) }}
  labels: {{ include "base-lib.labels" (dict "ctx" $ctx) | nindent 4 }}
  {{- with $service.annotations }}
  annotations: {{ tpl (toYaml .) $ctx | nindent 4 }}
  {{- end }}
spec:
  {{- with $service.type }}
  type: {{ tpl (toYaml .) $ctx }}
  {{- end }}
  {{- with $service.clusterIP }}
  clusterIP: {{ tpl (toYaml .) $ctx }}
  {{- end }}
  {{- with $service.externalTrafficPolicy }}
  externalTrafficPolicy: {{ tpl (toYaml .) $ctx }}
  {{- end }}
  {{- with $service.sessionAffinity }}
  sessionAffinity: {{ tpl (toYaml .) $ctx }}
  {{- end }}
  {{- with $service.loadBalancerIP }}
  loadBalancerIP: {{ tpl (toYaml .) $ctx }}
  {{- end }}
  {{- with $service.loadBalancerSourceRanges }}
  loadBalancerSourceRanges: {{ tpl (toYaml .) $ctx | nindent 2 }}
  {{- end }}
  selector: {{ include "base-lib.selectorLabels" (dict "ctx" $ctx) | nindent 4 }}
  {{- if $service.ports }}
  ports:
  {{- range $k, $v := $service.ports }}
    - name: {{ $k }}
      port: {{ $v.port }}
      targetPort: {{ $v.targetPort | default $v.port }}
      protocol: {{ $v.protocol | default "TCP" }}
      {{- with $v.nodePort }}
      nodePort: {{ tpl (toYaml .) $ctx }}
      {{- end }}
  {{- end }}
  {{- end }}
{{- end }}
