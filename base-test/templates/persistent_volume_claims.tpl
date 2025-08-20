{{ include "base.persistentVolumeClaims" (dict "persistentVolumeClaims" .Values.persistentVolumeClaims "ctx" $) }}
