# helm-chart-base

TODO list:
- Add optional hashes from `secrets` and `configMaps`, both of them have to go through tpl before calculating hash itself
- Add Job and CronJob implementations
- Resolve case with empty dir usage in 2 containers within a pod (volumes as a map and concatenate it?)
- Doublecheck tpl rendering in all resources
- Update all the resources to follow: `default`, `{resource}`, `override` -> `content` structure
- Make more atomic decomposition of handlers, refine naming
- Improve visibility of conditions and loops better within templates (the issue basically in indents)

# Agreements:
  - no lists of dictionaries are allowed in helm chart, helm lists flow breaks the merge flow in chart inheritance
  - content of resources should go through tpl
  - `$ctx` variable should be provided as-is:
    - it provides an easy way to get any path for .Values by "val" key
    - it provides an absolute context by "abs" key
    - updated values should be provided separately
