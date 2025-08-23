{{/*
Ingress template for baserary chart
Usage: {{ include "base.ingress" (dict "ingress" $ingress "service" $service "ctx" $ctx) }}
*/}}
{{ define "base.ingress" -}}
{{ $ingress := .ingress -}}
{{ $service := .service -}}
{{ $ctx := .ctx -}}
{{ $content := include "base.ingress.content" (dict "ingress" $ingress "service" $service "ctx" $ctx) | fromYaml -}}
{{ if and $content.enabled $content.spec.rules -}}
apiVersion: networking.k8s.io/v1
kind: Ingress
{{ $_ := unset $content "enabled" -}}
{{ $content | toYaml }}
---
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base.ingress.content" (dict "ingress" $ingress "service" $service "ctx" $ctx) }}
*/}}
{{ define "base.ingress.content" -}}
{{ $ingress := .ingress -}}
{{ $service := .service -}}
{{ $ctx := .ctx -}}
{{ $default := include "base.ingress.default" (dict "ctx" $ctx) | fromYaml -}}
{{ $override := include "base.ingress.override" (dict "ingress" $ingress "service" $service "ctx" $ctx) | fromYaml -}}
{{ $content := mustMergeOverwrite $default $ingress $override -}}
{{ if not $content.metadata.annotations -}}
{{ $_ := unset $content.metadata "annotations" -}}
{{- end }}
{{ tpl ($content | toYaml) $ctx }}
{{- end }}

{{/*
Usage: {{ include "base.ingress.override" (dict ingress" $ingress "service" $service "ctx" $ctx) }}
*/}}
{{ define "base.ingress.override" -}}
{{ $ingress := .ingress -}}
{{ $service := .service -}}
{{ $ctx := .ctx -}}
{{ $spec := include "base.ingress.spec" (dict "spec" $ingress.spec "service" $service "ctx" $ctx) | fromYaml -}}
{{ dict "spec" $spec | toYaml }}
{{- end }}

{{/*
Usage: {{ include "base.ingress.spec" (dict "spec" $spec "service" $service "ctx" $ctx) }}
*/}}
{{ define "base.ingress.spec" -}}
{{ $spec := .spec -}}
{{ $service := .service -}}
{{ $ctx := .ctx -}}
{{ $spec = mustMergeOverwrite $spec (include "base.ingress.tls" (dict "rules" $spec.rules "ctx" $ctx) | fromYaml) }}
{{ $spec = mustMergeOverwrite $spec (include "base.ingress.rules" (dict "rules" $spec.rules "service" $service "ctx" $ctx) | fromYaml) }}
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
Usage: {{ include "base.ingress.rules" (dict "rules" .Values.ingress.spec.rules "service" $service "ctx" $ctx) }}
*/}}
{{ define "base.ingress.rules" -}}
  {{ $rules := .rules -}}
  {{ $service := .service -}}
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
      {{ $path := include "base.ingress.path" (dict "path" $kk "content" $vv "ctx" $ctx) | fromYaml -}}
      {{ if $path.backend -}}
      {{ $pathsList = append $pathsList $path -}}
      {{ end -}}
    {{ end -}}
    {{ $_ := set $rule.http "paths" $pathsList -}}
    {{ if ne ($rule.http.paths | len) 0 -}}
    {{ $rulesList = append $rulesList $rule -}}
    {{ end -}}
  {{ end -}}
  rules: {{ tpl ($rulesList | toYaml) $ctx | nindent 4 }}
{{- end }}

{{/*
Path section sctracture
Usage: {{ include "base.ingress.path" (dict "path" $path "content" $content "ctx" $ctx) }}
*/}}
{{ define "base.ingress.path" -}}
{{ $ctx := .ctx -}}
{{ $path := .path -}}
{{ $content := .content -}}
{{ $default := include "base.ingress.path.default" (dict "ctx" $ctx) | fromYaml -}}
{{ $content = mustMergeOverwrite $default $content -}}
{{ $_ := set $content "path" $path -}}
{{ if not $content.backend.service -}}
{{ $backend := $content.backend -}}
{{ $_ := unset $backend "service" -}}
{{ $_ = set $content "backend" $backend -}}
{{ end -}}
{{ $content | toYaml }}
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
Usage: {{ include "base.ingress.default" (dict "ctx" $ctx) }}
*/}}
{{ define "base.ingress.default" -}}
{{ $ctx := .ctx -}}
enabled: true
metadata:
  name: {{ include "base.fullname" (dict "ctx" $ctx) }}
  labels: {{ include "base.labels" (dict "ctx" $ctx) | nindent 4 }}
  annotations: {}
spec:
  rules: {}
{{- end }}
