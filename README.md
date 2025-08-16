# helm-chart-base

TODO list:
- Add enablers for each resource
- Add tests for base-lib via base chart
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
cd base && helm dependency update
cd ../examples/vault && helm dependency update
cd ../.. && helm template ./examples/vault
```

Install to vault namespace
```shell
cd base && helm dependency update
cd ../examples/vault && helm dependency update
cd ../.. && helm upgrade vault ./examples/vault -i -n vault --create-namespace
```