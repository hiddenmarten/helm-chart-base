{{/*
Default template for base-library chart
Usage: {{ include "base-lib.defaults" (dict "ctx" $ctx) }}
*/}}
{{ define "base-lib.defaults" -}}
{{ $ctx := .ctx }}
# Default values for base-lib.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

# This is to override the chart name. Put them to global?
nameOverride: ""
fullnameOverride: ""

# This will set the replicaset count more information can be found here: https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/
replicaCount: 1

# This sets the container image more information can be found here: https://kubernetes.io/docs/concepts/containers/images/
image: {}

securityContext: {}
  # capabilities:
  #   drop:
  #   - ALL
  # readOnlyRootFilesystem: true
  # runAsNonRoot: true
  # runAsUser: 1000

resources: {}
  # We usually recommend not to specify default resources and to leave this as a conscious
  # choice for the user. This also increases chances charts run on environments with little
  # resources, such as Minikube. If you do want to specify resources, uncomment the following
  # lines, adjust them as necessary, and remove the curly braces after 'resources:'.
  # limits:
  #   cpu: 100m
  #   memory: 128Mi
  # requests:
  #   cpu: 100m
  #   memory: 128Mi

# This is to setup the liveness and readiness probes more information can be found here: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
livenessProbe: {}
readinessProbe: {}

# This is for the secrets for pulling an image from a private repository more information can be found here: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
imagePullSecrets: []

# This section builds out the service account more information can be found here: https://kubernetes.io/docs/concepts/security/service-accounts/
serviceAccount:
  create: true
  # Automatically mount a ServiceAccount's API credentials?
  automountServiceAccountToken: true
  # Annotations to add to the service account
  annotations: {}
  # Name of ServiceAccount
  # name: ""

pod:
  # This is for setting Kubernetes Annotations to a Pod.
  # For more information checkout: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/
  annotations: {}
  # This is for setting Kubernetes Labels to a Pod.
  # For more information checkout: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/
  labels: {}

  securityContext: {}
  # fsGroup: 2000

# This is for setting up a service more information can be found here: https://kubernetes.io/docs/concepts/services-networking/service/
service:
  annotations: {}
  spec:
    # This sets the ports more information can be found here: https://kubernetes.io/docs/concepts/services-networking/service/#field-spec-ports
    ports: {}

# This is for setting up ingress more information can be found here: https://kubernetes.io/docs/concepts/services-networking/ingress/
ingress:
  # ingressClassName: ""
  annotations: {}
  spec:
    rules: {}
  #    "chart-example.local":
  #      tls:
  #        secretName: chart-example-tls
  #      http:
  #        paths:
  #          "/":
  #            backend:
  #              service:
  #                name: chart-example
  #                port:
  #                  number: 8080

serviceMonitor:
  annotations: {}
  spec:
    selector:
      matchLabels: {}
    endpoints: {}
#      http:
#        path: /metrics
#        interval: 30s
#        scrapeTimeout: 10s
#        honorLabels: false

# ConfigMaps to render
configMaps:
  envVars:
    enabled: true
    annotations: {}
    data: {}
#      ENV_VAR_KEY: "ENV_VAR_VALUE"
  files:
    enabled: true
    annotations: {}
    mount: {}
    data: {}
#      "/app/data.json":
#        key: value
#      "/app/data.yaml":
#        key: value
#      "/app/data.toml":
#        key: value
#      "/app/data.txt": |
#        any text

# Secrets to render
secrets:
  envVars:
    enabled: true
    annotations: {}
    data: {}
#      SECRET_ENV_VAR_KEY: "SECRET_ENV_VAR_VALUE"
  files:
    enabled: true
    annotations: {}
    mount: {}
    data: {}
#      "/app/secret.json":
#        key: value
#      "/app/secret.yaml":
#        key: value
#      "/app/secret.toml":
#        key: value
#      "/app/secret.txt": |
#        any text

# persistentVolumeClaims to add
persistentVolumeClaims: {}
#  data:  # Postfix of pvc name
#    annotations: {}
#    spec: {}
#    mount: {}

nodeSelector: {}

tolerations: []

affinity: {}

{{- end }}
