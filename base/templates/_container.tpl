{{/*
Usage: {{ include "base.container" (dict "container" $container "ctx" $ctx) }}
*/}}
{{ define "base.container" -}}
{{ $ctx := .ctx -}}
{{ $container := .container -}}
{{ $name := .name -}}
{{ $containerOverride := include "base.container.override" (dict "container" $container "ctx" $ctx) | fromYaml -}}
{{ $container = mustMergeOverwrite $container $containerOverride (dict "name" $name) -}}
{{ $container | toYaml }}
{{- end }}

{{/*
Usage: {{ include "base.container.override" (dict "container" $container "ctx" $ctx) }}
*/}}
{{ define "base.container.override" -}}
{{ $ctx := .ctx -}}
{{ $container := .container -}}
{{ include "base.container.image" (dict "image" $container.image "ctx" $ctx) }}
{{ $ports := include "base.container.ports" (dict "ctx" $ctx) | fromYaml -}}
{{ if len $ports.ports -}}
{{ $ports | toYaml }}
{{- end }}
{{ $envFrom := include "base.container.envFrom" (dict "ctx" $ctx) | fromYaml -}}
{{ if len $envFrom.envFrom -}}
{{ $envFrom | toYaml }}
{{- end }}
{{ $volumeMounts := include "base.container.volumeMounts" (dict "ctx" $ctx) | fromYaml -}}
{{ if len $volumeMounts.volumeMounts -}}
{{ $volumeMounts | toYaml }}
{{- end }}
{{- end }}

{{/*
Usage: {{ include "base.container.image" (dict "image" $image "ctx" $ctx) }}
*/}}
{{ define "base.container.image" -}}
{{ $ctx := .ctx -}}
{{ $image := .image -}}
{{ $default := include "base.container.image.default" (dict "ctx" $ctx) | fromYaml -}}
{{ $image = mustMergeOverwrite $default $image -}}
{{ $value := "" -}}
{{ if $image.registry -}}
{{ $value = printf "%s/%s:%s" $image.registry $image.repository $image.tag -}}
{{ else -}}
{{ $value = printf "%s:%s" $image.repository $image.tag -}}
{{- end }}
{{ dict "image" $value | toYaml }}
{{- end }}

{{/*
Usage: {{ include "base.container.image.default" (dict "ctx" $ctx) }}
*/}}
{{ define "base.container.image.default" -}}
{{ $ctx := .ctx -}}
registry: ""
repository: ""
tag: latest
{{- end }}

{{/*
Usage: {{ include "base.container.ports" (dict "service" $service "ctx" $ctx) }}
*/}}
{{ define "base.container.ports" -}}
{{ $ctx := .ctx -}}
{{ $service := include "base.service.merged" (dict "ctx" $ctx) | fromYaml -}}
{{ $items := list -}}
{{ $defaultService := include "base.service.default" (dict "ctx" $ctx) | fromYaml -}}
{{ $service = mustMergeOverwrite $defaultService $service -}}
{{- range $k, $v := $service.spec.ports }}
{{ $item := dict "name" $k "containerPort" $v.port -}}
{{ $items = append $items $item -}}
{{- end }}
{{ dict "ports" $items | toYaml }}
{{- end }}

{{/*
Usage: {{ include "base.container.envFrom" (dict "ctx" $ctx) }}
*/}}
{{ define "base.container.envFrom" -}}
{{ $ctx := .ctx -}}
{{ $configMaps := include "base.configMaps.merged" (dict "ctx" $ctx) | fromYaml -}}
{{ $secrets := include "base.secrets.merged" (dict "ctx" $ctx) | fromYaml -}}
{{ $configMapRefs := include "base.configMaps.envFrom" (dict "envVars" $configMaps.envVars "ctx" $ctx) | fromYaml -}}
{{ $secretRefs := include "base.secrets.envFrom" (dict "envVars" $secrets.envVars "ctx" $ctx) | fromYaml -}}
{{ $items := concat $configMapRefs.envFrom $secretRefs.envFrom | default list -}}
{{ dict "envFrom" $items | toYaml }}
{{- end }}

{{/*
Usage: {{ include "base.container.volumeMounts" (dict "ctx" $ctx) }}
*/}}
{{ define "base.container.volumeMounts" -}}
{{ $ctx := .ctx -}}
{{ $configMaps := include "base.configMaps.merged" (dict "ctx" $ctx) | fromYaml -}}
{{ $secrets := include "base.secrets.merged" (dict "ctx" $ctx) | fromYaml -}}
{{ $persistentVolumeClaims := include "base.persistentVolumeClaims.merged" (dict "ctx" $ctx) | fromYaml -}}
{{ $cmVolumeMounts := include "base.configMaps.files.volumeMounts" (dict "unit" $configMaps.files "ctx" $ctx) | fromYaml -}}
{{ $secretVolumeMounts := include "base.secrets.files.volumeMounts" (dict "unit" $secrets.files "ctx" $ctx) | fromYaml -}}
{{ $pvcVolumeMounts := include "base.persistentVolumeClaims.volumeMounts" (dict "persistentVolumeClaims" $persistentVolumeClaims "ctx" $ctx) | fromYaml -}}
{{ $items := concat $cmVolumeMounts.volumeMounts $secretVolumeMounts.volumeMounts $pvcVolumeMounts.volumeMounts | default list -}}
{{ dict "volumeMounts" $items | toYaml }}
{{- end }}
