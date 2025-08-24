# helm-chart-base

TODO list:
- Doublecheck tpl rendering in all resources
- Provide entities at the top of root functions for resources merged with default values in one line.
- Update all the resources to follow: `default`, `{resource}`, `override` -> `content` structure
- Make more atomic decomposition of handlers, refine naming
- Improve visibility of conditions and loops better within templates (the issue basically in indents)

# Agreements:
 - no lists of dictionaries are allowed in helm chart, helm lists flow breaks the merge flow in chart inheritance
 - content of resources should go through tpl
