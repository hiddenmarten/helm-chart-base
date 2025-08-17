{{/*
ServiceAccount template for baserary chart
Usage: {{ include "base.serviceAccount" (dict "sa" .Values.serviceAccount "ctx" $) }}
*/}}
{{ define "base.serviceAccount" -}}
{{ $sa := .sa -}}
{{ $ctx := .ctx -}}
{{ $defaults := include "base.defaults" (dict "ctx" $ctx) | fromYaml -}}
{{ $sa = mustMergeOverwrite $defaults.serviceAccount $sa -}}
{{- if $sa.create }}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "base.serviceAccountName" (dict "sa" $sa "ctx" $ctx) }}
  labels: {{ include "base.labels" (dict "ctx" $ctx) | nindent 4 }}
  {{- with $sa.annotations }}
  annotations: {{ tpl (toYaml .) $ctx | nindent 4 }}
  {{- end }}
{{- with $sa.imagePullSecrets }}
imagePullSecrets: {{ tpl (toYaml .) $ctx | nindent 2 }}
{{- end }}
{{- with $sa.automountServiceAccountToken }}
automountServiceAccountToken: {{ tpl (toYaml .) $ctx }}
{{- end }}
{{- end }}
{{- end }}

{{/*
ServiceAccount template rendering the name of service account
Usage: {{ include "base.serviceAccount" (dict "sa" .Values.serviceAccount "ctx" $) }}
*/}}
{{ define "base.serviceAccountName" -}}
{{ $sa := .sa -}}
{{ $ctx := .ctx -}}
{{ default (include "base.fullname" (dict "ctx" $ctx)) $sa.name }}
{{- end }}
