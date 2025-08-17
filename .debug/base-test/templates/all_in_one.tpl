
apiVersion: v1
kind: ConfigMap
binaryData: {}
data:
  TEST_VAR: test_value
metadata:
  annotations: {}
  labels:
    app.kubernetes.io/instance: multi-component
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/name: base-test
    helm.sh/chart: base-test-0.0.1
  name: multi-component-base-test-env-vars
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: multi-component-base-test
  labels:
    app.kubernetes.io/name: base-test
    app.kubernetes.io/instance: multi-component
    helm.sh/chart: base-test-0.0.1
    app.kubernetes.io/managed-by: Helm
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: base-test
      app.kubernetes.io/instance: multi-component
  template:
    metadata:
      labels:
        app.kubernetes.io/name: base-test
        app.kubernetes.io/instance: multi-component
        helm.sh/chart: base-test-0.0.1
        app.kubernetes.io/managed-by: Helm
    spec:
      serviceAccountName: multi-component-base-test
      containers:
        - name: base-test
          image: "nginx:latest"
          envFrom:
            - configMapRef:
                name: multi-component-base-test-env-vars
            - secretRef:
                name: multi-component-base-test-env-vars


---



apiVersion: v1
kind: Secret
metadata:
  name: multi-component-base-test-env-vars
  labels:
    app.kubernetes.io/name: base-test
    app.kubernetes.io/instance: multi-component
    helm.sh/chart: base-test-0.0.1
    app.kubernetes.io/managed-by: Helm
data:
  SECRET_VAR: c2VjcmV0X3ZhbHVl
---

apiVersion: v1
kind: Service
metadata:
  name: multi-component-base-test
  labels:
    app.kubernetes.io/name: base-test
    app.kubernetes.io/instance: multi-component
    helm.sh/chart: base-test-0.0.1
    app.kubernetes.io/managed-by: Helm
spec:
  ports:
  - name: http
    port: 80
    targetPort: 8080
---

apiVersion: v1
kind: ServiceAccount
metadata:
  name: multi-component-base-test
  labels:
    app.kubernetes.io/name: base-test
    app.kubernetes.io/instance: multi-component
    helm.sh/chart: base-test-0.0.1
    app.kubernetes.io/managed-by: Helm
automountServiceAccountToken: true
---
