{{/*
Ingress template for baserary chart
Usage: {{ include "base.ingress" (dict "ctx" $ctx) }}
*/}}
{{ define "base.ingress" -}}
{{ $ctx := .ctx -}}
{{ $ingress := include "base.ingress.merged" (dict "ctx" $ctx) | fromYaml -}}
{{ $content := include "base.ingress.content" (dict "ingress" $ingress "ctx" $ctx) | fromYaml -}}
{{ if and $content.enabled $content.spec.rules -}}
apiVersion: networking.k8s.io/v1
kind: Ingress
{{ $_ := unset $content "enabled" -}}
{{ $content | toYaml }}
---
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base.ingress.content" (dict "ingress" $ingress "ctx" $ctx) }}
*/}}
{{ define "base.ingress.content" -}}
{{ $ingress := .ingress -}}
{{ $ctx := .ctx -}}
{{ $default := include "base.ingress.default" (dict "ctx" $ctx) | fromYaml -}}
{{ $override := include "base.ingress.override" (dict "ingress" $ingress "ctx" $ctx) | fromYaml -}}
{{ $content := mustMergeOverwrite $default $ingress $override -}}
{{ if not $content.metadata.annotations -}}
{{ $_ := unset $content.metadata "annotations" -}}
{{- end }}
{{ tpl ($content | toYaml) $ctx.abs }}
{{- end }}

{{/*
Usage: {{ include "base.ingress.override" (dict ingress" $ingress "ctx" $ctx) }}
*/}}
{{ define "base.ingress.override" -}}
{{ $ingress := .ingress -}}
{{ $ctx := .ctx -}}
{{ $spec := include "base.ingress.spec" (dict "spec" $ingress.spec "ctx" $ctx) | fromYaml -}}
{{ dict "spec" $spec | toYaml }}
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
  tls: {{ tpl (toYaml $tlsList) $ctx.abs | nindent 4 }}
  {{- end }}
{{- end }}

{{/*
Rules sections template for ingress
Usage: {{ include "base.ingress.rules" (dict "rules" $rules "ctx" $ctx) }}
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
  rules: {{ tpl ($rulesList | toYaml) $ctx.abs | nindent 4 }}
{{- end }}

{{/*
Usage: {{ include "base.ingress.path" (dict "path" $path "content" $content "ctx" $ctx) }}
*/}}
{{ define "base.ingress.path" -}}
{{ $ctx := .ctx -}}
{{ $path := .path -}}
{{ $content := .content -}}
{{ $service := include "base.service.merged" (dict "ctx" $ctx) | fromYaml -}}
{{ $default := include "base.ingress.path.default" (dict "ctx" $ctx) | fromYaml -}}
{{ $contentWithServceName := (dict "backend" (dict "service" (dict "name" $service.metadata.name))) -}}
{{ $content = mustMergeOverwrite $default $contentWithServceName $content -}}
{{ $_ := set $content "path" $path -}}
{{ if and (not $content.backend.service.port.name) (not $content.backend.service.port.number) -}}
{{ fail "backend service port name or port number is required" }}
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
    port: {}
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

{{/*
Usage: {{ $ingress := include "base.service.merged" (dict "ctx" $ctx) | fromYaml -}}
*/}}
{{ define "base.ingress.merged" -}}
{{ $ctx := .ctx -}}
{{ $default := include "base.ingress.default" (dict "ctx" $ctx) | fromYaml -}}
{{ $ingress := $ctx.val.ingress | default dict }}
{{ mustMergeOverwrite $default $ingress | toYaml }}
{{- end }}
