{{/*
Usage: {{ include "base.deployment" (dict "val" .Values "ctx" $) }}
*/}}
{{ define "base.deployment" -}}
{{ $ctx := .ctx -}}
{{ $val := .val -}}
{{ $defaults := include "base.defaults" (dict "ctx" $ctx) | fromYaml -}}
{{ $val = mustMergeOverwrite $defaults $val -}}
{{ $content := include "base.deployment.content" (dict "val" $val "ctx" $ctx) | fromYaml -}}
apiVersion: apps/v1
kind: Deployment
{{ $content | toYaml }}
---
{{- end }}

{{/*
Usage: {{ include "base.deployment" (dict "val" $val "ctx" $ctx) }}
*/}}
{{ define "base.deployment.content" -}}
{{ $ctx := .ctx -}}
{{ $val := .val -}}
metadata:
  name: {{ include "base.fullname" (dict "ctx" $ctx) }}
  labels: {{ include "base.labels" (dict "ctx" $ctx) | nindent 4 }}
spec:
  {{- if not $val.autoscaling }}
  replicas: {{ tpl (toYaml $val.replicaCount) $ctx }}
  {{- end }}
  selector:
    matchLabels: {{ include "base.selectorLabels" (dict "ctx" $ctx) | nindent 6 }}
  template:
    metadata:
      {{- with $val.pod.annotations }}
      annotations:
        {{ tpl (toYaml .) $ctx | nindent 8 }}
      {{- end }}
      labels: {{ include "base.labels" (dict "ctx" $ctx) | nindent 8 }}
        {{- with $val.pod.labels }}
        {{ tpl (toYaml .) $ctx | nindent 8 }}
        {{- end }}
    spec:
      {{- with $val.imagePullSecrets }}
      imagePullSecrets: {{ tpl (toYaml .) $ctx | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "base.serviceAccount.name" (dict "serviceAccount" $val.serviceAccount "ctx" $ctx) }}
      {{- with $val.pod.securityContext }}
      securityContext: {{ tpl (toYaml .) $ctx | nindent 8 }}
      {{- end }}
      containers:
        - name: {{ include "base.name" (dict "ctx" $ctx) }}
          {{- with $val.securityContext }}
          securityContext: {{ tpl (toYaml .) $ctx | nindent 12 }}
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
          livenessProbe: {{ tpl (toYaml .) $ctx | nindent 12 }}
          {{- end }}
          {{- with $val.readinessProbe }}
          readinessProbe: {{ tpl (toYaml .) $ctx | nindent 12 }}
          {{- end }}
          {{- with $val.resources }}
          resources: {{ tpl (toYaml .) $ctx | nindent 12 }}
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
{{ include "base.volumeMounts" (dict "val" $val "ctx" $ctx) }}
{{ include "base.volumes" (dict "val" $val "ctx" $ctx) }}
      {{- with $val.nodeSelector }}
      nodeSelector: {{ tpl (toYaml .) $ctx | nindent 8 }}
      {{- end }}
      {{- with $val.affinity }}
      affinity: {{ tpl (toYaml .) $ctx | nindent 8 }}
      {{- end }}
      {{- with $val.tolerations }}
      tolerations: {{ tpl (toYaml .) $ctx | nindent 8 }}
      {{- end }}
{{- end }}
