# helm-chart-base

TODO list:
- Rework from merge approarch to nested replace or unset for clearness, basically, flow should go like that:
    - get merged dictionary on the top level
    - pass it to main override function
    - inside there are functions like `base.<resourse>.override.<fieldToOverride>` have to rewrite a certain field and return resource back
      - `<resource>` can be a `Secret`
      - `<fieldToOverride>` can be spec
    - resource should be returned to the root function
    - if high-level resource is plural, like `Secrets` then each `unit` has to be processed separately.
- Improve visibility of conditions and loops better within templates (the issue basically in indents)

# Agreements:
  - no lists of dictionaries are allowed in helm chart, helm lists flow breaks the merge flow in chart inheritance
  - content of resources should go through tpl
  - `$ctx` variable should be provided as-is:
    - it provides an easy way to get any path for .Values by "val" key
    - it provides an absolute context by "abs" key
    - updated values should be provided separately
