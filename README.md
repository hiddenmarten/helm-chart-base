# helm-chart-base

TODO list:
- Add Job and CronJob implementations
- Resolve case with empty dir usage in 2 containers within a pod (volumes as a map and concatenate it?)
- Doublecheck tpl rendering in all resources
- Rework from merge approarch to nested replace or unset for clearness, basically, flow should go like that:
    - get merged dictionary on the top level
    - pass it to content
    - in content level separate functions like `base.resouse.override.thingToOverride` have to rewrite a certian part and return resource back
    - content should be returned to the root function
- Improve visibility of conditions and loops better within templates (the issue basically in indents)

# Agreements:
  - no lists of dictionaries are allowed in helm chart, helm lists flow breaks the merge flow in chart inheritance
  - content of resources should go through tpl
  - `$ctx` variable should be provided as-is:
    - it provides an easy way to get any path for .Values by "val" key
    - it provides an absolute context by "abs" key
    - updated values should be provided separately
