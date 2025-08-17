# helm-chart-base

TODO list:
- Add custom labels support
- Add tests for base via base chart
- Implement statefulset support
- Write chart examples:
  - single postgres
  - single vault
  - mono chart with vault uses postgres as a backend
  - umbrella chart with vault uses postgres as a backend
- Add sidecar support
- Implement reusable podSpec section
- Add RBAC support
- Improve visibility of conditions and loops better within templates (the issue basically in indents)


# Agreements:
 - no lists allowed in helm chart values, lists break the merge flow in chart inheritance

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