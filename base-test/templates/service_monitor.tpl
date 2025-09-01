{{ include "base.serviceMonitor" (dict "ctx" (dict "val" .Values "abs" $)) }}
