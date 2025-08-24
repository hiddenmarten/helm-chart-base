{{ include "base.serviceMonitor" (dict "serviceMonitor" .Values.serviceMonitor "ctx" (dict "val" .Values "abs" $)) }}
