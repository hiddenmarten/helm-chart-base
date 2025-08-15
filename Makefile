# Setting SHELL to bash allows bash commands to be executed by recipes.
# Options are set to exit when a recipe line exits non-zero or a piped command fails.
SHELL = /usr/bin/env bash -o pipefail
.SHELLFLAGS = -ec

##@ General

# The help target prints out all targets with their descriptions organized
# beneath their categories. The categories are represented by '##@' and the
# target descriptions by '##'. The awk command is responsible for reading the
# entire set of makefiles included in this invocation, looking for lines of the
# file as xyz: ## something, and then pretty-format the target and help. Then,
# if there's a line with ##@ something, that gets pretty-printed as a category.
# More info on the usage of ANSI control characters for terminal formatting:
# https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_parameters
# More info on the awk command:
# http://linuxcommand.org/lc3_adv_awk.php

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Dependencies

## Location to install dependencies to
LOCALBIN ?= $(shell pwd)/bin
$(LOCALBIN):
	mkdir -p $(LOCALBIN)

HELM_PLUGINS ?= $(LOCALBIN)/helm-plugins
export HELM_PLUGINS
$(HELM_PLUGINS):
	mkdir -p $(HELM_PLUGINS)

## Tool Binaries
HELM ?= $(LOCALBIN)/helm
HELM_DOCS ?= $(LOCALBIN)/helm-docs

## Tool Versions
# renovate: datasource=github-tags depName=helm/helm
HELM_VERSION ?= v3.17.4
# renovate: datasource=github-tags depName=losisin/helm-values-schema-json
HELM_SCHEMA_VERSION ?= 2.2.1
# renovate: datasource=github-tags depName=norwoodj/helm-docs
HELM_DOCS_VERSION ?= v1.14.2
# renovate: datasource=github-tags depName=helm-unittest/helm-unittest
HELM_UNITTEST_VERSION ?= v1.0.0

## Tool install scripts
HELM_INSTALL_SCRIPT ?= "https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3"

.PHONY: helm
helm: $(LOCALBIN)
	@if test -x $(HELM) && ! $(HELM) version | grep -q $(HELM_VERSION); then \
		rm -f $(HELM); \
	fi
	@test -x $(HELM) || { curl -Ss $(HELM_INSTALL_SCRIPT) | sed "s|/usr/local/bin|$(LOCALBIN)|" | PATH="$(LOCALBIN):$(PATH)" bash -s -- --no-sudo --version $(HELM_VERSION); }

.PHONY: helm-schema
helm-schema: helm $(HELM_PLUGINS)
	@if ! $(HELM) plugin list | grep schema | grep -q $(subst v,,$(HELM_SCHEMA_VERSION)); then \
		if $(HELM) plugin list | grep -q schema ; then \
			$(HELM) plugin uninstall schema; \
		fi; \
		$(HELM) plugin install https://github.com/losisin/helm-values-schema-json --version=$(HELM_SCHEMA_VERSION); \
	fi

.PHONY: helm-docs
helm-docs: $(LOCALBIN)
	@test -x $(HELM_DOCS) && $(HELM_DOCS) version | grep -q $(HELM_DOCS_VERSION) || \
	GOBIN=$(LOCALBIN) go install github.com/norwoodj/helm-docs/cmd/helm-docs@$(HELM_DOCS_VERSION)

.PHONY: helm-unittest
helm-unittest: helm $(HELM_PLUGINS)
	@if ! $(HELM) plugin list | grep unittest | grep -q $(subst v,,$(HELM_UNITTEST_VERSION)); then \
		if $(HELM) plugin list | grep -q unittest ; then \
			$(HELM) plugin uninstall unittest; \
		fi; \
		$(HELM) plugin install https://github.com/helm-unittest/helm-unittest --version=$(HELM_UNITTEST_VERSION); \
	fi

##@ Development

.PHONY: lint
lint: helm ## Run helm lint over chart
	$(HELM) lint base

.PHONY: schema
schema: helm-schema ## Run helm schema over chart
	cd base && $(HELM) schema

.PHONY: docs
docs: helm-docs ## Run helm schema over chart
	$(HELM_DOCS)

.PHONY: unittest
unittest: helm-unittest ## Run helm unittests over chart
	$(HELM) unittest base
