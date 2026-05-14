<!-- Generated from docs/src. Run `make docs-build` to update. Do not edit directly. -->

# TierNerd Backend

FastAPI backend for the TierNerd ranking app.

## Quick Start

```bash
# Start the backend (builds and runs Docker containers, auto-seeds dev user)
make dev

# Or run in background
make dev DETACHED=1
```

The API is now running at <http://localhost:8000>.

## Dev Credentials

The dev user is auto-created on startup:

| Email | Password |
|-------|----------|
| dev@tiernerd.com | devpassword |

## API Documentation

- **Swagger UI**: <http://localhost:8000/docs>
- **ReDoc**: <http://localhost:8000/redoc>

## API Structure

The API is structured around the following resources:

- `/api/users` — User management and authentication
- `/api/lists` — List creation and management
- `/api/items` — Item management and ranking

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
uv run ruff check app/            # Lint (rules: E, F, I, B, UP, SIM)
uv run ruff check app/ --fix      # Lint + autofix
uv run ruff format app/           # Format
uv run mypy app/                  # Type check

# Testing
uv run pytest                                       # Run all tests
uv run pytest tests/test_items.py                   # Run single test file
uv run pytest -k "test_name"                        # Run specific test
uv run pytest --cov=app --cov-report=term-missing   # Run with coverage
```

## Testing

- **Framework**: `pytest` with `pytest-asyncio` for async support
- **Test Database**: SQLite in-memory for fast, isolated tests
- **HTTP Client**: `httpx.AsyncClient` for endpoint testing
- **Test Files**:
  - `tests/conftest.py` — Test configuration and fixtures
  - `tests/test_users.py` — User endpoint tests
  - `tests/test_lists.py` — List endpoint tests
  - `tests/test_items.py` — Item endpoint tests
  - `tests/app/utils/test_algorithm.py` — Algorithm tests

```bash
uv sync --group dev                                 # Install dev deps
uv run pytest                                       # All tests
uv run pytest tests/test_users.py -v                # Single file
uv run pytest tests/test_users.py::TestUserCreation # Single class
uv run pytest --cov=app --cov-report=html           # Coverage report
```

### Coverage Areas

- **Users**: registration, login (email + username), tokens, current user, invalid tokens
- **Lists**: CRUD, pagination, authorization (cross-user access denied)
- **Items**: CRUD, comparison workflow (better/worse), session management, authorization
- **Algorithm**: binary search ranking, winner/loser logic, range narrowing, edge cases

## Project Structure

```
app/
├── api/endpoints/   # Route handlers
├── core/            # Auth, security, algorithms
├── crud/            # Database operations
├── db/              # Models and database setup
├── schemas/         # Pydantic request/response models
└── settings.py      # Configuration
```

## Tech Stack

- **FastAPI** — Web framework
- **PostgreSQL** — Database (via asyncpg)
- **SQLAlchemy 2.0** — Async ORM
- **JWT** — Authentication
- **Docker** — Containerization

## Ranking Algorithm

The ranking algorithm is implemented in `app/core/algorithm.py` and uses binary search to efficiently determine item positions through pairwise comparisons.

## Documentation Automation

`README.md`, `CLAUDE.md`, `AGENTS.md`, `fastapi/README.md`, and `frontend/README.md` are **generated** from templates in `docs/src/` by `scripts/build_docs.py`. Do not edit the generated files directly — edit the template or partial and re-render.

```bash
make docs-build    # render templates → generated files
make docs-check    # CI check: fail if generated docs are stale
```

Partials live in `docs/src/partials/` and are included with double-brace `include:partials/<name>.md` directives. `CLAUDE.md` and `AGENTS.md` share a single template (`docs/src/CLAUDE.md`) and are rendered to both paths.
