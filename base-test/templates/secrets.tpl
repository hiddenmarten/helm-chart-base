{{ include "base.secrets" (dict "secrets" .Values.secrets "ctx" (dict "val" .Values "abs" $)) }}
