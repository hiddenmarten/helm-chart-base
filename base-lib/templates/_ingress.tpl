{{/*
Ingress template for base-library chart
Usage: {{ include "base-lib.ingress" (dict "val" .Values "ctx" $) }}
*/}}
{{ define "base-lib.ingress" -}}
{{ $val := .val -}}
{{ $ctx := .ctx -}}
{{ $defaults := include "base-lib.defaults" (dict "ctx" $ctx) | fromYaml -}}
{{ $val = mustMergeOverwrite $defaults $val -}}
{{- if $val.ingress.hosts }}
apiVersion: "networking.k8s.io/v1"
kind: Ingress
metadata:
  name: {{ include "base-lib.fullname" (dict "ctx" $ctx) }}
  labels: {{ include "base-lib.labels" (dict "ctx" $ctx) | nindent 4 }}
  {{- with $val.ingress.annotations }}
  annotations: {{ tpl (toYaml .) $ctx | nindent 4 }}
  {{- end }}
spec:
  {{- with $val.ingress.ingressClassName }}
  ingressClassName: {{ tpl (toYaml .) $ctx }}
  {{- end }}
  {{ include "base-lib.ingress.tls" (dict "hosts" $val.ingress.hosts "ctx" $) }}
  {{ include "base-lib.ingress.rules" (dict "hosts" $val.ingress.hosts "ctx" $) }}
{{- end }}
{{- end }}

{{/*
TLS sections template for ingress
Usage: {{ include "base-lib.ingress.tls" (dict "hosts" .Values.ingress.hosts "ctx" $) }}
*/}}
{{ define "base-lib.ingress.tls" -}}
  {{ $hosts := .hosts -}}
  {{ $ctx := .ctx -}}
  {{ $tlsDict := dict -}}
  {{ range $k, $v := $hosts -}}
      {{ if and $v.tls $v.tls.secretName -}}
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
Usage: {{ include "base-lib.ingress.rules" (dict "hosts" .Values.ingress.hosts "ctx" $) }}
*/}}
{{ define "base-lib.ingress.rules" -}}
  {{ $hosts := .hosts -}}
  {{ $ctx := .ctx -}}
  {{ $rulesList := list -}}
  {{ range $k, $v := $hosts -}}
    {{ $rule := (include "base-lib.ingress.rule.default" (dict "ctx" $ctx)) | fromYaml -}}
    {{ $_ := set $rule "host" $k -}}
    {{ $paths := $v.paths | default (dict "/" dict) -}}
    {{ $pathsList := list -}}
    {{ range $pathKey, $pathVal := $paths -}}
      {{ $path := mustMergeOverwrite ((include "base-lib.ingress.path.default" (dict "ctx" $ctx)) | fromYaml) $pathVal -}}
      {{ $_ := set $path "path" $pathKey -}}
      {{ $pathsList = append $pathsList $path -}}
    {{ end -}}
    {{ $_ = set $rule.http "paths" $pathsList -}}
    {{ $rulesList = append $rulesList $rule -}}
  {{ end -}}
  rules: {{ tpl ($rulesList | toYaml) $ctx | nindent 4 }}
{{- end }}

{{/*
Path section sctracture
Usage: {{ include "base-lib.ingress.path.default" (dict "ctx" $) }}
*/}}
{{ define "base-lib.ingress.path.default" -}}
{{ $ctx := .ctx -}}
pathType: Prefix
backend:
  service:
    name: ""
    port:
      number: 0
{{- end }}

{{/*
Rule section sctracture
Usage: {{ include "base-lib.ingress.path.default" (dict "ctx" $) }}
*/}}
{{ define "base-lib.ingress.rule.default" -}}
{{ $ctx := .ctx -}}
host: ""
http:
  paths: {}
{{- end }}
