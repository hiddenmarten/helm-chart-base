{{/*
Usage: {{ include "base.pod" (dict "val" $val "ctx" $ctx) }}
*/}}
{{ define "base.pod" -}}
{{ $ctx := .ctx -}}
{{ $val := .val -}}
metadata:
  {{- with $val.pod.annotations }}
  annotations:
    {{ tpl (toYaml .) $ctx | nindent 4 }}
  {{- end }}
  labels: {{ include "base.labels" (dict "ctx" $ctx) | nindent 4 }}
    {{- with $val.pod.labels }}
    {{ tpl (toYaml .) $ctx | nindent 4 }}
    {{- end }}
spec:
  {{- with $val.imagePullSecrets }}
  imagePullSecrets: {{ tpl (toYaml .) $ctx | nindent 4 }}
  {{- end }}
  serviceAccountName: {{ include "base.serviceAccount.name" (dict "serviceAccount" $val.serviceAccount "ctx" $ctx) }}
  {{- with $val.pod.securityContext }}
  securityContext: {{ tpl (toYaml .) $ctx | nindent 4 }}
  {{- end }}
  containers:
    - name: {{ include "base.name" (dict "ctx" $ctx) }}
      {{- with $val.securityContext }}
      securityContext: {{ tpl (toYaml .) $ctx | nindent 8 }}
      {{- end }}
      image: "{{ $val.image.repository }}:{{ $val.image.tag }}"
      {{- with $val.image.pullPolicy }}
      imagePullPolicy: {{ tpl (toYaml .) $ctx }}
      {{- end }}
      {{- if $val.service.ports }}
      ports:
      {{- range $k, $v := $val.service.ports }}
        - name: {{ $k }}
          containerPort: {{ $v.port }}
          protocol: {{ $v.protocol | default "TCP" }}
      {{- end }}
      {{- end }}
      {{- with $val.livenessProbe }}
      livenessProbe: {{ tpl (toYaml .) $ctx | nindent 8 }}
      {{- end }}
      {{- with $val.readinessProbe }}
      readinessProbe: {{ tpl (toYaml .) $ctx | nindent 8 }}
      {{- end }}
      {{- with $val.resources }}
      resources: {{ tpl (toYaml .) $ctx | nindent 8 }}
      {{- end }}
      {{- if or $val.configMaps.envVars.data $val.secrets.envVars.data }}
      envFrom:
      {{- if $val.configMaps.envVars.data }}
        - configMapRef:
            name: {{ include "base.configMaps.name" (dict "postfix" "envVars" "ctx" $ctx) }}
      {{- end }}
      {{- if $val.secrets.envVars.data }}
        - secretRef:
            name: {{ include "base.secrets.name" (dict "postfix" "envVars" "ctx" $ctx) }}
      {{- end }}
      {{- end }}
      {{ $volumeMounts := include "base.volumeMounts" (dict "val" $val "ctx" $ctx) | fromYaml -}}
      {{ if $volumeMounts -}}
      volumeMounts: {{ $volumeMounts.volumeMounts | toYaml | nindent 8 }}
      {{- end }}
  {{ $volumes := include "base.volumes" (dict "val" $val "ctx" $ctx) | fromYaml -}}
  {{ if $volumes -}}
  volumes: {{ $volumes.volumes | toYaml | nindent 4 }}
  {{- end }}
  {{- with $val.nodeSelector }}
  nodeSelector: {{ tpl (toYaml .) $ctx | nindent 4 }}
  {{- end }}
  {{- with $val.affinity }}
  affinity: {{ tpl (toYaml .) $ctx | nindent 4 }}
  {{- end }}
  {{- with $val.tolerations }}
  tolerations: {{ tpl (toYaml .) $ctx | nindent 4 }}
  {{- end }}
{{- end }}
