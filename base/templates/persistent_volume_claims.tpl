{{ include "base-lib.persistentVolumeClaims" (dict "pvcs" .Values.persistentVolumeClaims "ctx" $) }}
