{{ include "base.persistentVolumeClaims" (dict "pvcs" .Values.persistentVolumeClaims "ctx" $) }}
