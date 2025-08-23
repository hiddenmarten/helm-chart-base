# helm-chart-base

TODO list:
- Implement statefulset support
- Write chart examples:
  - single postgres
  - single vault
  - mono chart with vault uses postgres as a backend
  - umbrella chart with vault uses postgres as a backend
- Improve visibility of conditions and loops better within templates (the issue basically in indents)


# Agreements:
 - no lists of dictionaries are allowed in helm chart, helm lists flow breaks the merge flow in chart inheritance
 - loose coupling, dependencies between resources made only via default names
   - e.g., if a developer wants to rename Service, they have to update the service reference name in Ingress and ServiceMonitor


# Commands:

Render template
```shell
make dependency-update
helm template vault ./examples/vault -n vault --debug > ./examples/vault/manifest.yaml
```

Install to vault namespace
```shell
make dependency-update
helm upgrade vault ./examples/vault -i -n vault --create-namespace --debug
```