### Backend (fastapi/)

**Always use `make` commands instead of raw `docker` commands.** Agents may run read-only ones (`make logs`, `make stop`, `make health`); the user runs build/dev/reset commands (`make dev`, `make fresh`, `make restart`, `make reset`, `make clean`).

```bash
cd fastapi

# Docker (use these, not raw docker commands)
make dev                          # Build and run containers (auto-seeds dev user)
make dev DETACHED=1               # Run in background
make restart                      # Rebuild and restart
make fresh                        # Rebuild, restart, and show logs
make logs                         # View container logs
make stop                         # Stop containers
make health                       # Check health endpoint

# Database
make reset                        # Clear database and re-seed
make clean                        # Stop, remove volumes, clean up (use after schema changes)

# Package management (use uv, not pip)
uv sync                           # Install dependencies
uv sync --group dev               # Install with dev dependencies

# Code quality
uv run ruff check app/ tests/     # Lint (rules: E, F, I, B, UP, SIM, RUF, PL, S)
uv run ruff check app/ --fix      # Lint + autofix
uv run ruff format app/           # Format
uv run mypy app/                  # Type check
uv run tach check                 # Enforce module boundaries (see tach.toml)

# Testing
uv run pytest                                       # Run all tests
uv run pytest tests/test_items.py                   # Run single test file
uv run pytest -k "test_name"                        # Run specific test
uv run pytest --cov=app --cov-report=term-missing   # Run with coverage
```
