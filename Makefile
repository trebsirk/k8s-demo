# =========================
# Configuration
# =========================

SHELL := /usr/bin/env bash
.SHELLFLAGS := -euo pipefail -c

MAKEFLAGS += --output-sync=target

.DEFAULT_GOAL := help

# =========================
# Helpers
# =========================

.PHONY: help
help:
	@echo ""
	@echo "Available targets:"
	@echo ""
	@echo "  setup             Verify tools are installed"
	@echo "  validate-env      Validate required environment variables"
	@echo "  build             Build Docker image"
	@echo "  deploy            Deploy app to Kubernetes"
	@echo "  stop              Stop Kubernetes resources"
	@echo "  reset             Delete and recreate deployment"
	@echo ""
	@echo "  smoke-test        Run smoke tests (K8s)"
	@echo "  contract-test     Run contract tests (K8s)"
	@echo "  integration-test  Run integration tests (K8s)"
	@echo "  test              Run all tests (serial)"
	@echo "  test-parallel     Run tests in parallel"
	@echo ""
	@echo "  status            Show deployment status"
	@echo "  logs              Tail app logs"
	@echo ""

# =========================
# Environment & setup
# =========================

.PHONY: setup
setup:
	@command -v kubectl >/dev/null || (echo "kubectl not found" && exit 1)
	@command -v docker >/dev/null || (echo "docker not found" && exit 1)
	@command -v minikube >/dev/null || (echo "minikube not found" && exit 1)
	@command -v envsubst >/dev/null || (echo "envsubst not found" && exit 1)
	@command -v jq >/dev/null || (echo "jq not found" && exit 1)
	@command -v pytest >/dev/null || (echo "pytest not found" && exit 1)
	@echo "✅ All required tools installed"

.PHONY: validate-env
validate-env:
	./scripts/validate-env.sh

# =========================
# Build & deploy
# =========================

.PHONY: build
build: validate-env
	./build.sh

.PHONY: deploy
deploy: validate-env
	./deploy.sh

.PHONY: stop
stop:
	./stop.sh

.PHONY: reset
reset:
	./reset.sh

# =========================
# Tests
# =========================

.PHONY: smoke-test
smoke-test:
	./scripts/smoke-test.sh

.PHONY: contract-test
contract-test:
	./scripts/contract-test.sh

.PHONY: integration-test
integration-test:
	./scripts/integration-test.sh

.PHONY: test
test: smoke-test contract-test integration-test
	@echo "✅ All tests passed"

.PHONY: test-parallel
test-parallel:
	@echo "🚀 Running tests in parallel"
	@$(MAKE) -j 3 smoke-test contract-test integration-test

# =========================
# Observability
# =========================

.PHONY: status
status:
	kubectl get pods,svc -l app=$$(grep APP_NAME .env | cut -d= -f2)

.PHONY: logs
logs:
	kubectl logs -l app=$$(grep APP_NAME .env | cut -d= -f2) --tail=100 -f


# =========================
# Release configuration
# =========================

VERSION ?=
GIT_TAG_PREFIX ?= v
# this allows make release VERSION=1.0.0

# =========================
# Release
# =========================

.PHONY: release
release:
	@if [ -z "$(VERSION)" ]; then \
		echo "❌ VERSION is required (e.g. make release VERSION=1.2.3)"; \
		exit 1; \
	fi
	@echo "🚀 Releasing version $(VERSION)"

	@echo "🔢 Updating .env APP_VERSION"
	@sed -i.bak "s/^APP_VERSION=.*/APP_VERSION=$(VERSION)/" .env
	@rm -f .env.bak

	@echo "🔍 Validating environment"
	@$(MAKE) validate-env

	@echo "🏗️  Building image"
	@$(MAKE) build

	@echo "📦 Deploying to Kubernetes"
	@$(MAKE) deploy

	@echo "🧪 Running tests"
	@$(MAKE) test

	@echo "🏷️  Creating git tag $(GIT_TAG_PREFIX)$(VERSION)"
	@git tag "$(GIT_TAG_PREFIX)$(VERSION)" || true

	@echo "✅ Release $(VERSION) complete"
