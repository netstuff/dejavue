SHELL := /bin/bash
# =============================================================================
# Variables
# =============================================================================

.DEFAULT_GOAL:=help
.ONESHELL:
.EXPORT_ALL_VARIABLES:
MAKEFLAGS += --no-print-directory

# Define colors and formatting
BLUE := $(shell printf "\033[1;34m")
GREEN := $(shell printf "\033[1;32m")
RED := $(shell printf "\033[1;31m")
YELLOW := $(shell printf "\033[1;33m")
NC := $(shell printf "\033[0m")
INFO := $(shell printf "$(BLUE)\342\204\271$(NC)")
OK := $(shell printf "$(GREEN)\342\234\223$(NC)")
WARN := $(shell printf "$(YELLOW)\342\232\240$(NC)")
ERROR := $(shell printf "$(RED)\342\234\226$(NC)")

.PHONY: help
help:                                               ## Display this help text for Makefile
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


# =============================================================================
# Python Environment
# =============================================================================
.PHONY: install-uv
install-uv:                                         ## Install latest version of uv
	@echo "$(INFO) Installing uv..."
	@curl -LsSf https://astral.sh/uv/install.sh | sh >/dev/null 2>&1
	@echo "$(OK) UV installed successfully"

.PHONY: install-python
install-python: install-uv                          ## Setup Python virtual environment and install dependencies
	@echo "$(INFO) Setting up Python environment..."
	@uv python pin 3.14 >/dev/null 2>&1
	@uv venv >/dev/null 2>&1
	@uv sync --all-extras --dev
	@echo "$(OK) Python environment ready"


# =============================================================================
# Backend
# =============================================================================
.PHONY: install-backend
install-backend: install-python                     ## Install backend environment (Python deps + Django setup)
	@echo "$(INFO) Setting up backend..."
	@uv run ./manage.py migrate --run-syncdb >/dev/null 2>&1
	@echo "$(OK) Backend ready"

.PHONY: dev-backend
dev-backend:                                        ## Run backend in dev mode (Django development server)
	@echo "$(INFO) Starting backend dev server on :8000..."
	@uv run ./manage.py runserver 0.0.0.0:8000


# =============================================================================
# Frontend
# =============================================================================
.PHONY: install-frontend
install-frontend:                                   ## Install frontend environment (npm dependencies)
	@echo "$(INFO) Setting up frontend..."
	@if ! command -v node >/dev/null 2>&1; then \
		echo "$(INFO) Installing Node environment..."; \
		uvx nodeenv .venv --force --quiet; \
	fi
	@NODE_OPTIONS="--no-deprecation --disable-warning=ExperimentalWarning" npm install --no-fund
	@echo "$(OK) Frontend ready"

.PHONY: dev-frontend
dev-frontend:                                       ## Run frontend in dev mode (Vite HMR on :5173)
	@echo "$(INFO) Starting frontend dev server on :5173..."
	@NODE_OPTIONS="--no-deprecation --disable-warning=ExperimentalWarning" npm run dev


# =============================================================================
# Install All
# =============================================================================
.PHONY: install
install: destroy clean install-backend install-frontend  ## Install all environments for local development
	@echo "$(OK) Full installation complete"


# =============================================================================
# Cleanup
# =============================================================================
.PHONY: clean
clean:                                              ## Clean temporary build artifacts and caches
	@echo "$(INFO) Cleaning working directory..."
	@rm -rf .pytest_cache .ruff_cache .hypothesis build dist .eggs .coverage coverage.xml coverage.json htmlcov .mypy_cache .unasyncd_cache .auto_pytabs_cache >/dev/null 2>&1
	@find . -name '*.egg-info' -exec rm -rf {} + >/dev/null 2>&1
	@find . -type f -name '*.egg' -exec rm -f {} + >/dev/null 2>&1
	@find . -name '*.pyc' -exec rm -f {} + >/dev/null 2>&1
	@find . -name '*.pyo' -exec rm -f {} + >/dev/null 2>&1
	@find . -name '*~' -exec rm -f {} + >/dev/null 2>&1
	@find . -name '__pycache__' -exec rm -rf {} + >/dev/null 2>&1
	@find . -name '.ipynb_checkpoints' -exec rm -rf {} + >/dev/null 2>&1
	@echo "$(OK) Working directory cleaned"

.PHONY: destroy
destroy:                                            ## Destroy Python virtual environment
	@echo "$(INFO) Destroying virtual environment..."
	@rm -rf .venv
	@echo "$(OK) Virtual environment destroyed"

.PHONY: destroy-all
destroy-all:                                        ## Destroy all environments (venv, node_modules, caches)
	@echo "$(INFO) Destroying all environments..."
	@rm -rf .venv node_modules >/dev/null 2>&1
	@rm -rf staticfiles/dist >/dev/null 2>&1
	@$(MAKE) clean
	@echo "$(OK) All environments destroyed"


# =============================================================================
# Tests
# =============================================================================
.PHONY: test-backend
test-backend:                                       ## Run backend tests (pytest)
	@echo "$(INFO) Running backend tests..."
	@if [ -d tests ]; then \
		uv run pytest tests -n 2 --quiet; \
		echo "$(OK) Backend tests passed"; \
	else \
		echo "$(WARN) No backend tests found"; \
	fi

.PHONY: test-frontend
test-frontend:                                      ## Run frontend tests (vitest)
	@echo "$(INFO) Running frontend tests..."
	@if grep -q '"test"' package.json 2>/dev/null; then \
		NODE_OPTIONS="--no-deprecation --disable-warning=ExperimentalWarning" npm run test; \
		echo "$(OK) Frontend tests passed"; \
	else \
		echo "$(WARN) No frontend test script configured"; \
	fi

.PHONY: test-all
test-all: test-backend test-frontend                 ## Run all tests (backend + frontend)

.PHONY: coverage
coverage:                                           ## Run backend tests with coverage report
	@echo "$(INFO) Running tests with coverage..."
	@if [ -d tests ]; then \
		uv run pytest tests --cov -n auto --quiet; \
		uv run coverage html >/dev/null 2>&1; \
		uv run coverage xml >/dev/null 2>&1; \
		echo "$(OK) Coverage report generated"; \
	else \
		echo "$(WARN) No tests found"; \
	fi


# =============================================================================
# Linting
# =============================================================================
.PHONY: lint-backend
lint-backend:                                       ## Run backend linters (ruff, mypy, pyright)
	@echo "$(INFO) Running backend linters..."
	@uv run ruff check --quiet
	@echo "$(OK) Ruff passed"
	@if uv run mypy dejavue --quiet 2>/dev/null; then \
		echo "$(OK) Mypy passed"; \
	else \
		echo "$(WARN) Mypy issues found (see above)"; \
	fi
	@if uv run pyright --quiet 2>/dev/null; then \
		echo "$(OK) Pyright passed"; \
	else \
		echo "$(WARN) Pyright issues found (see above)"; \
	fi

.PHONY: lint-frontend
lint-frontend:                                      ## Run frontend linters
	@echo "$(INFO) Running frontend linters..."
	@if grep -q '"lint"' package.json 2>/dev/null; then \
		NODE_OPTIONS="--no-deprecation --disable-warning=ExperimentalWarning" npm run lint; \
		echo "$(OK) Frontend linting passed"; \
	elif command -v npx >/dev/null 2>&1 && npx --yes eslint --version >/dev/null 2>&1; then \
		npx eslint frontend/ --ext .ts,.vue; \
		echo "$(OK) Frontend linting passed"; \
	else \
		echo "$(WARN) No frontend linter configured"; \
	fi

.PHONY: fix
fix:                                                ## Auto-fix backend lint issues (ruff)
	@echo "$(INFO) Running auto-fix..."
	@uv run ruff check --fix --unsafe-fixes
	@echo "$(OK) Auto-fix complete"

.PHONY: pre-commit
pre-commit:                                         ## Run all pre-commit hooks (ruff, codespell, etc.)
	@echo "$(INFO) Running pre-commit checks..."
	@if [ -f .pre-commit-config.yaml ]; then \
		uv run pre-commit run --color=always --all-files; \
		echo "$(OK) Pre-commit checks passed"; \
	else \
		echo "$(WARN) No pre-commit config found, running ruff directly..."; \
		uv run ruff check --quiet; \
		echo "$(OK) Ruff passed"; \
	fi


# =============================================================================
# Build & Release
# =============================================================================
.PHONY: build-frontend
build-frontend: install-frontend                    ## Build frontend for production (Vite)
	@echo "$(INFO) Building frontend..."
	@NODE_OPTIONS="--no-deprecation --disable-warning=ExperimentalWarning" npm run build
	@echo "$(OK) Frontend built"

.PHONY: build-backend
build-backend: install-backend                      ## Build backend artifacts (collectstatic)
	@echo "$(INFO) Building backend..."
	@uv run ./manage.py collectstatic --noinput --clear >/dev/null 2>&1
	@echo "$(OK) Backend built"

.PHONY: release
release: build-frontend build-backend               ## Release application (bump version, build frontend + backend)
	@echo "$(INFO) Preparing release..."
	@uv run bump-my-version bump $(or $(bump),patch)
	@echo "$(OK) Release complete"


# =============================================================================
# Dev Mode (both backend + frontend)
# =============================================================================
.PHONY: dev
dev:               									## Run full application in dev mode (backend + frontend concurrently)
	@echo "$(INFO) Starting dev mode (backend :8000 + frontend :5173)..."
	@trap 'kill 0' EXIT; \
		uv run ./manage.py runserver 0.0.0.0:8000 & \
		NODE_OPTIONS="--no-deprecation --disable-warning=ExperimentalWarning" npm run dev; \
		wait


# =============================================================================
# Upgrade & Lock
# =============================================================================
.PHONY: upgrade
upgrade:                                            ## Upgrade all dependencies to latest stable versions
	@echo "$(INFO) Upgrading all dependencies..."
	@uv lock --upgrade
	@NODE_OPTIONS="--no-deprecation --disable-warning=ExperimentalWarning" npm upgrade --latest
	@if [ -f .pre-commit-config.yaml ]; then \
		uv run pre-commit autoupdate; \
	fi
	@echo "$(OK) All dependencies upgraded"

.PHONY: lock
lock:                                               ## Rebuild lockfiles from scratch
	@echo "$(INFO) Rebuilding lockfiles..."
	@uv lock --upgrade >/dev/null 2>&1
	@echo "$(OK) Lockfiles updated"
