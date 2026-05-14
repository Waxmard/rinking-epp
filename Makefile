# Root Makefile — monorepo orchestrator.
# Backend targets delegate to fastapi/Makefile. Frontend targets call npm scripts.

.DEFAULT_GOAL := help

.PHONY: help
help:
	@echo "Setup:"
	@echo "  setup            - First-time install (root, frontend, backend, hooks)"
	@echo ""
	@echo "Quality (both projects):"
	@echo "  lint             - Lint backend + frontend"
	@echo "  fix              - Lint + autofix backend + frontend"
	@echo "  typecheck        - Typecheck backend + frontend"
	@echo "  test             - Run backend tests with coverage"
	@echo "  ci               - lint + typecheck + test"
	@echo ""
	@echo "Backend (delegates to fastapi/Makefile):"
	@echo "  backend-<target> - any fastapi/Makefile target (e.g. backend-lint, backend-logs)"
	@echo ""
	@echo "Frontend (delegates to frontend/package.json scripts):"
	@echo "  frontend-lint frontend-fix frontend-typecheck"

# ----- Setup -----

.PHONY: setup
setup:
	npm install
	cd frontend && npm install
	cd fastapi && uv sync --extra dev --group dev
	cd fastapi && uv run pre-commit install

# ----- Aggregate -----

.PHONY: lint fix typecheck test ci
lint:      backend-lint frontend-lint
fix:       backend-fix frontend-fix
typecheck: backend-typecheck frontend-typecheck
test:      backend-test
ci:        backend-ci frontend-lint frontend-typecheck

# ----- Backend: delegate any backend-* to fastapi/Makefile -----

backend-%:
	$(MAKE) -C fastapi $*

# ----- Frontend -----

.PHONY: frontend-lint frontend-fix frontend-typecheck
frontend-lint:
	cd frontend && npm run lint && npm run format:check

frontend-fix:
	cd frontend && npm run lint:fix && npm run format

frontend-typecheck:
	cd frontend && npm run typecheck
