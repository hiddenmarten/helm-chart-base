{{ include "base.persistentVolumeClaims" (dict "persistentVolumeClaims" .Values.persistentVolumeClaims "ctx" (dict "val" .Values "abs" $)) }}
