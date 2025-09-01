# helm-chart-base

TODO list:
- Rework $ctx flow following agreement
- Add optional hashes from `secrets` and `configMaps`, both of them have to go through tpl before calculating hash itself
- Make init and ephemeral containers as a maps
- Resolve case with empty dir usage in 2 containers within a pod (volumes as a map and concatenate it?)
- Doublecheck tpl rendering in all resources
- Provide entities at the top of root functions for resources merged with default values in one line.
- Update all the resources to follow: `default`, `{resource}`, `override` -> `content` structure
- Make more atomic decomposition of handlers, refine naming
- Improve visibility of conditions and loops better within templates (the issue basically in indents)

# Agreements:
 - no lists of dictionaries are allowed in helm chart, helm lists flow breaks the merge flow in chart inheritance
 - content of resources should go through tpl
 - `$ctx` variable should be provided as-is, updated values should be provided separately
