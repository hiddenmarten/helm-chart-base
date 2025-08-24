{{ include "base.allInOne.statefulset" (dict "val" .Values.postgres "abs" $) }}
