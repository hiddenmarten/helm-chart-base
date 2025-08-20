{{/*
Ingress template for baserary chart
Usage: {{ include "base.ingress" (dict "ingress" .Values.ingress "ctx" $) }}
*/}}
{{ define "base.ingress" -}}
{{ $ingress := .ingress -}}
{{ $ctx := .ctx -}}
{{ $content := include "base.ingress.content" (dict "content" $ingress "ctx" $ctx) | fromYaml -}}
{{ if and $content.enabled $content.spec.rules -}}
apiVersion: networking.k8s.io/v1
kind: Ingress
{{ $_ := unset $content "enabled" -}}
{{ $content | toYaml }}
---
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base.ingress.content" (dict "content" $content "ctx" $ctx) }}
*/}}
{{ define "base.ingress.content" -}}
{{ $content := .content -}}
{{ $ctx := .ctx -}}
{{ $defaultContent := include "base.ingress.default.content" (dict "ctx" $ctx) | fromYaml -}}
{{ $payload := include "base.ingress.payload" (dict "content" $content "ctx" $ctx) | fromYaml -}}
{{ $content = mustMergeOverwrite $defaultContent $content $payload -}}
{{ if not $content.metadata.annotations -}}
{{ $_ := unset $content.metadata "annotations" -}}
{{- end }}
{{ tpl ($content | toYaml) $ctx }}
{{- end }}

{{/*
Usage: {{ include "base.ingress.payload" (dict "content" $content "ctx" $ctx) }}
*/}}
{{ define "base.ingress.payload" -}}
{{ $content := .content -}}
{{ $ctx := .ctx -}}
{{ $spec := include "base.ingress.spec" (dict "spec" $content.spec "ctx" $ctx) | fromYaml -}}
{{ $payload := dict "spec" $spec -}}
{{ $payload | toYaml }}
{{- end }}

{{/*
Usage: {{ include "base.ingress.spec" (dict "spec" $spec "ctx" $ctx) }}
*/}}
{{ define "base.ingress.spec" -}}
{{ $spec := .spec -}}
{{ $ctx := .ctx -}}
{{ $spec = mustMergeOverwrite $spec (include "base.ingress.tls" (dict "rules" $spec.rules "ctx" $ctx) | fromYaml) }}
{{ $spec = mustMergeOverwrite $spec (include "base.ingress.rules" (dict "rules" $spec.rules "ctx" $ctx) | fromYaml) }}
{{ $spec | toYaml }}
{{- end }}

{{/*
TLS sections template for ingress
Usage: {{ include "base.ingress.tls" (dict "rules" .Values.ingress.spec.rules "ctx" $ctx) }}
*/}}
{{ define "base.ingress.tls" -}}
  {{ $rules := .rules -}}
  {{ $ctx := .ctx -}}
  {{ $tlsDict := dict -}}
  {{ range $k, $v := $rules -}}
      {{ if and $v $v.tls $v.tls.secretName -}}
      {{ $existingHosts := index $tlsDict $v.tls.secretName | default list -}}
      {{ $hostsList := append $existingHosts $k -}}
      {{ $_ := set $tlsDict $v.tls.secretName $hostsList }}
      {{- end }}
  {{- end }}
  {{- if $tlsDict }}
  {{ $tlsList := list -}}
      {{- range $secretName, $hostsList := $tlsDict }}
      {{ $tlsEntry := dict "secretName" $secretName "hosts" $hostsList -}}
      {{ $tlsList = append $tlsList $tlsEntry -}}
      {{- end }}
  tls: {{ tpl (toYaml $tlsList) $ctx | nindent 4 }}
  {{- end }}
{{- end }}

{{/*
Rules sections template for ingress
Usage: {{ include "base.ingress.rules" (dict "rules" .Values.ingress.spec.rules "ctx" $ctx) }}
*/}}
{{ define "base.ingress.rules" -}}
  {{ $rules := .rules -}}
  {{ $ctx := .ctx -}}
  {{ $rulesList := list -}}
  {{ range $k, $v := $rules -}}
    {{ $rule := include "base.ingress.rule.default" (dict "ctx" $ctx) | fromYaml -}}
    {{ if $v -}}
    {{ $rule = mustMergeOverwrite $rule $v -}}
    {{ end -}}
    {{ if $rule.tls -}}
    {{ $_ := unset $rule "tls" -}}
    {{ end -}}
    {{ if not $rule.host -}}
    {{ $_ := set $rule "host" $k -}}
    {{ end -}}
    {{ $pathsList := list -}}
    {{ range $kk, $vv := $rule.http.paths -}}
      {{ $defaultPath := include "base.ingress.path.default" (dict "ctx" $ctx) | fromYaml -}}
      {{ $path := mustMergeOverwrite $defaultPath $vv -}}
      {{ $_ := set $path "path" $kk -}}
      {{ if not $path.backend.service -}}
      {{ $backend := $path.backend -}}
      {{ $_ := unset $backend "service" -}}
      {{ $_ = set $path "backend" $backend -}}
      {{ end -}}
      {{ $pathsList = append $pathsList $path -}}
    {{ end -}}
    {{ $_ := set $rule.http "paths" $pathsList -}}
    {{ $rulesList = append $rulesList $rule -}}
  {{ end -}}
  rules: {{ tpl ($rulesList | toYaml) $ctx | nindent 4 }}
{{- end }}

{{/*
Path section sctracture
Usage: {{ include "base.ingress.path.default" (dict "ctx" $ctx) }}
*/}}
{{ define "base.ingress.path.default" -}}
{{ $ctx := .ctx -}}
pathType: Prefix
backend:
  service:
    name: {{ include "base.fullname" (dict "ctx" $ctx) }}
{{- end }}

{{/*
Rule section sctracture
Usage: {{ include "base.ingress.path.default" (dict "ctx" $ctx) }}
*/}}
{{ define "base.ingress.rule.default" -}}
{{ $ctx := .ctx -}}
host: ""
http:
  paths: {}
{{- end }}

{{/*
Usage: {{ include "base.ingress.default.content" (dict "ctx" $ctx) }}
*/}}
{{ define "base.ingress.default.content" -}}
{{ $ctx := .ctx -}}
enabled: true
metadata:
  name: {{ include "base.fullname" (dict "ctx" $ctx) }}
  labels: {{ include "base.labels" (dict "ctx" $ctx) | nindent 4 }}
  annotations: {}
spec:
  rules: {}
{{- end }}
