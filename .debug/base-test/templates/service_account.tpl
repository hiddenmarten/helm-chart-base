
apiVersion: v1
kind: ServiceAccount
metadata:
  name: RELEASE-NAME-base-test
  labels:
    app.kubernetes.io/name: base-test
    app.kubernetes.io/instance: RELEASE-NAME
    helm.sh/chart: base-test-0.0.1
    app.kubernetes.io/managed-by: Helm
automountServiceAccountToken: true
---
