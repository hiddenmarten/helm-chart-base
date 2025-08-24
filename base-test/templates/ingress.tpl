{{ include "base.ingress" (dict "ingress" .Values.ingress "service" .Values.service "ctx" (dict "val" .Values "abs" $)) }}
