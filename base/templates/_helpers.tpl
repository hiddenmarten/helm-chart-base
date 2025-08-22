{{/*
Expand the name of the chart.
Usage: {{ include "base.name" (dict "ctx" $ctx) }}
*/}}
{{ define "base.name" -}}
{{ $ctx := .ctx -}}
{{ default $ctx.Chart.Name $ctx.Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified val name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
Usage: {{ include "base.fullname" (dict "ctx" $ctx) }}
*/}}
{{- define "base.fullname" -}}
{{- $ctx := .ctx -}}
{{- if $ctx.Values.fullnameOverride -}}
{{ $ctx.Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else -}}
{{ $name := default $ctx.Chart.Name $ctx.Values.nameOverride -}}
{{- if contains $name $ctx.Release.Name -}}
{{ $ctx.Release.Name | trunc 63 | trimSuffix "-" }}
{{- else -}}
{{ printf "%s-%s" $ctx.Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end -}}
{{- end -}}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
Usage: {{ include "base.chart" (dict "ctx" $ctx) }}
*/}}
{{ define "base.chart" -}}
{{ $ctx := .ctx -}}
{{ printf "%s-%s" $ctx.Chart.Name $ctx.Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Selector labels
Usage: {{ include "base.selectorLabels" (dict "ctx" $ctx) }}
*/}}
{{ define "base.selectorLabels" -}}
{{ $ctx := .ctx -}}
app.kubernetes.io/name: {{ include "base.name" (dict "ctx" $ctx) }}
app.kubernetes.io/instance: {{ $ctx.Release.Name }}
{{- end }}

{{/*
Common labels
Usage: {{ include "base.labels" (dict "ctx" $ctx) }}
*/}}
{{ define "base.labels" -}}
{{ $ctx := .ctx -}}
{{ include "base.selectorLabels" (dict "ctx" $ctx) }}
helm.sh/chart: {{ include "base.chart" (dict "ctx" $ctx) }}
app.kubernetes.io/managed-by: {{ $ctx.Release.Service }}
{{- end }}
