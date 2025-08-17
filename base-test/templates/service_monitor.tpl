{{ include "base.serviceMonitor" (dict "serviceMonitor" .Values.serviceMonitor "ctx" $) }}
