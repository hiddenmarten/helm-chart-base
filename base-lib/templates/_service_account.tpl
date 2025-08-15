{{/*
ServiceAccount template for base-library chart
Usage: {{ include "base-lib.serviceAccount" (dict "sa" .Values.serviceAccount "ctx" $) }}
*/}}
{{ define "base-lib.serviceAccount" -}}
{{ $sa := .sa -}}
{{ $ctx := .ctx -}}
{{ $defaults := include "base-lib.defaults" (dict "ctx" $ctx) | fromYaml -}}
{{ $sa = mustMergeOverwrite $defaults.serviceAccount $sa -}}
{{- if $sa.create }}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "base-lib.serviceAccountName" (dict "sa" $sa "ctx" $ctx) }}
  labels: {{ include "base-lib.labels" (dict "ctx" $ctx) | nindent 4 }}
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
Usage: {{ include "base-lib.serviceAccount" (dict "sa" .Values.serviceAccount "ctx" $) }}
*/}}
{{ define "base-lib.serviceAccountName" -}}
{{ $sa := .sa -}}
{{ $ctx := .ctx -}}
{{ default (include "base-lib.fullname" (dict "ctx" $ctx)) $sa.name }}
{{- end }}
