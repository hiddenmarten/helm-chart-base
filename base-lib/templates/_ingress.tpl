{{/*
Ingress template for base-library chart
Usage: {{ include "base-lib.ingress" (dict "val" .Values "ctx" $ctx) }}
*/}}
{{ define "base-lib.ingress" -}}
{{ $val := .val -}}
{{ $ctx := .ctx -}}
{{ $defaults := include "base-lib.defaults" (dict "ctx" $ctx) | fromYaml -}}
{{ $val = mustMergeOverwrite $defaults $val -}}
{{ $spec := include "base-lib.ingress.spec" (dict "spec" $val.ingress.spec "ctx" $ctx) | fromYaml -}}
{{ $val = mustMergeOverwrite $val.ingress.spec (dict "ingress" (dict "spec" $spec)) -}}
{{- if $val.ingress.spec.rules }}
apiVersion: "networking.k8s.io/v1"
kind: Ingress
metadata:
  name: {{ include "base-lib.fullname" (dict "ctx" $ctx) }}
  labels: {{ include "base-lib.labels" (dict "ctx" $ctx) | nindent 4 }}
  {{- with $val.ingress.annotations }}
  annotations: {{ tpl (toYaml .) $ctx | nindent 4 }}
  {{- end }}
spec: {{ tpl (toYaml $val.ingress.spec) $ctx | nindent 2 }}
{{- end }}
{{- end }}

{{/*
TLS sections template for ingress
Usage: {{ include "base-lib.ingress.spec" (dict "spec" .Values.ingress.spec "ctx" $ctx) }}
*/}}
{{ define "base-lib.ingress.spec" -}}
{{ $spec := .spec -}}
{{ $ctx := .ctx -}}
{{ $spec = mustMergeOverwrite $spec (include "base-lib.ingress.tls" (dict "rules" $spec.rules "ctx" $ctx) | fromYaml) }}
{{ $spec = mustMergeOverwrite $spec (include "base-lib.ingress.rules" (dict "rules" $spec.rules "ctx" $ctx) | fromYaml) }}
{{ $spec | toYaml }}
{{- end }}

{{/*
TLS sections template for ingress
Usage: {{ include "base-lib.ingress.tls" (dict "rules" .Values.ingress.spec.rules "ctx" $ctx) }}
*/}}
{{ define "base-lib.ingress.tls" -}}
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
Usage: {{ include "base-lib.ingress.rules" (dict "rules" .Values.ingress.spec.rules "ctx" $ctx) }}
*/}}
{{ define "base-lib.ingress.rules" -}}
  {{ $rules := .rules -}}
  {{ $ctx := .ctx -}}
  {{ $rulesList := list -}}
  {{ range $k, $v := $rules -}}
    {{ $rule := include "base-lib.ingress.rule.default" (dict "ctx" $ctx) | fromYaml -}}
    {{ if $v -}}
    {{ $rule = mustMergeOverwrite $rule $v -}}
    {{ end -}}
    {{ if $rule.tls -}}
    {{ $_ := unset $rule "tls" -}}
    {{ end -}}
    {{ if not $rule.host -}}
    {{ $_ := set $rule "host" $k -}}
    {{ end -}}
    {{ if not $rule.http.paths }}
    {{ $_ := set $rule.http "paths" (dict "/" dict) -}}
    {{ end -}}
    {{ $pathsList := list -}}
    {{ range $kk, $vv := $rule.http.paths -}}
      {{ $defaultPath := include "base-lib.ingress.path.default" (dict "ctx" $ctx) | fromYaml -}}
      {{ $path := mustMergeOverwrite $defaultPath $vv -}}
      {{ $_ := set $path "path" $kk -}}
      {{ $pathsList = append $pathsList $path -}}
    {{ end -}}
    {{ $_ := set $rule.http "paths" $pathsList -}}
    {{ $rulesList = append $rulesList $rule -}}
  {{ end -}}
  rules: {{ tpl ($rulesList | toYaml) $ctx | nindent 4 }}
{{- end }}

{{/*
Path section sctracture
Usage: {{ include "base-lib.ingress.path.default" (dict "ctx" $ctx) }}
*/}}
{{ define "base-lib.ingress.path.default" -}}
{{ $ctx := .ctx -}}
{{ $portName := include "base-lib.ingress.service.http.portName" (dict "ctx" $ctx) | fromYaml -}}
pathType: Prefix
backend:
  service:
    name: {{ include "base-lib.fullname" (dict "ctx" $ctx) }}
    port: {{ $portName | toYaml | nindent 6 }}
{{- end }}

{{/*
Rule section sctracture
Usage: {{ include "base-lib.ingress.path.default" (dict "ctx" $ctx) }}
*/}}
{{ define "base-lib.ingress.rule.default" -}}
{{ $ctx := .ctx -}}
host: ""
http:
  paths: {}
{{- end }}

{{/*
Rule section sctracture
Usage: {{ include "base-lib.ingress.service.http.portName" (dict "ctx" $ctx) }}
*/}}
{{ define "base-lib.ingress.service.http.portName" -}}
{{ $ctx := .ctx -}}
{{ if not $ctx.Values.service.spec.ports.http -}}
{{ fail "couldn't find http port in service" }}
{{- end }}
name: http
{{- end }}
