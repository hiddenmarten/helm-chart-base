# helm-chart-base

TODO list:
- Provide entities at the top of root functions for resources merged with default values in one line.
- Review agreement with service, keep the port definable by developer, but service name should be inherited from $val
  - The same for statefulset
- Update all the resources to follow: `default`, `{resource}`, `override` -> `content` structure
- Write chart examples:
  - mono chart with vault uses postgres as a backend
  - umbrella chart with vault uses postgres as a backend
- Improve visibility of conditions and loops better within templates (the issue basically in indents)


# Agreements:
 - no lists of dictionaries are allowed in helm chart, helm lists flow breaks the merge flow in chart inheritance
 - loose coupling, dependencies between resources made only via default names
   - e.g., if a developer wants to rename Service, they have to update the service reference name in Ingress and ServiceMonitor

