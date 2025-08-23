{{ include "base.ingress" (dict "ingress" .Values.ingress "service" .Values.service "ctx" $) }}
