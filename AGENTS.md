<!-- Generated from docs/src. Run `make docs-build` to update. Do not edit directly. -->

# Repository Guidelines

This file provides guidance to AI coding agents (Claude Code, Codex, Cursor, etc.) working in this repository. It is the source of truth for both `CLAUDE.md` and `AGENTS.md`.

## Project Overview

TierNerd is a cross-platform mobile app for creating ranked tier lists (S–F) through 1v1 comparisons. Rather than asking users to assign subjective numerical scores, the app presents pairs of items and asks which is better. Through a series of binary choices, each item finds its proper place and receives a numeric rating that is then mapped to an intuitive tier (S, A, B, C, D, F).

Monorepo with React Native/Expo frontend and FastAPI backend.

## Repo Layout

- `fastapi/` — Python backend (uv, pyproject.toml, Dockerfile, Makefile)
- `frontend/` — React Native/Expo app (package.json, eslint, prettier)
- `docs/src/` — documentation templates and partials (rendered by `scripts/build_docs.py`)
- `scripts/` — repo-wide tooling (e.g. `build_docs.py`)
- `/package.json` — root dev-tooling only (husky). Not a JS project.
- `.husky/` — git hooks (pre-commit → `cd frontend && npx lint-staged`)
- `.pre-commit-config.yaml` — Python hooks (ruff) for `fastapi/`

## First-Time Setup

```bash
make setup    # installs root deps, frontend deps, backend deps + pre-commit hooks
```

Or step-by-step:

1. `npm install` (root, activates husky)
2. `cd frontend && npm install`
3. `cd ../fastapi && uv sync --extra dev --group dev`
4. `uv run pre-commit install`

## Development Commands

### Root (cross-project)

```bash
make help          # list all targets
make lint          # backend + frontend lint
make fix           # autofix both
make typecheck     # mypy + tsc
make test          # backend pytest w/ coverage
make ci            # lint + typecheck + test + docs-check
make docs-build    # render docs/src → README.md, CLAUDE.md, AGENTS.md, sub-READMEs
make docs-check    # fail if generated docs are stale
make backend-<X>   # delegates to fastapi/Makefile target X (e.g. backend-logs, backend-health, backend-lint)
```

Backend quality targets (lint/fix/format/typecheck/test/ci) live in `fastapi/Makefile` and are reachable from root via the `backend-` prefix or directly when in `fastapi/`.

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

### Frontend (frontend/)

```bash
cd frontend
npm install                       # Install dependencies
npm run ios                       # Run on iOS simulator
npm run android                   # Run on Android emulator
npm run web                       # Run web version

# Code quality
npm run lint                      # Run ESLint
npm run lint:fix                  # Fix ESLint errors
npm run format                    # Format with Prettier
npm run format:check              # Check formatting
npm run typecheck                 # TypeScript check
```

### Git Hooks

Husky runs `lint-staged` on staged frontend files (`eslint --fix` + `prettier --write` on `*.{ts,tsx}`; prettier on `*.{js,jsx,json}`). Config in `frontend/package.json` under `lint-staged`. Hook script in `.husky/pre-commit`.

Python files use the `pre-commit` framework (`.pre-commit-config.yaml`, ruff hooks) — independent of husky.

## Architecture

### Backend Structure (`fastapi/app/`)

- `api/endpoints/` — Route handlers (users, lists, items)
- `core/` — Auth (JWT), security (argon2), constants, ranking algorithm
- `crud/` — Database operations
- `db/` — SQLAlchemy models and async database setup
- `schemas/` — Pydantic request/response models
- `settings.py` — Configuration via pydantic-settings

### Frontend Structure (`frontend/src/`)

- `screens/` — Screen components (Login, Home, Lists, Profile)
- `navigation/` — React Navigation stack setup
- `providers/` — Context providers (AuthContext)
- `design-system/` — Reusable components and design tokens

### Key Patterns

- **Backend**: Async SQLAlchemy 2.0+, FastAPI dependency injection, JWT auth
- **Frontend**: Context API for state, token-based design system, TypeScript strict mode
- **Items**: Ordered via Base-62 fractional index `position` column (`app/core/fractional_index.py`)
- **Ranking**: Binary search algorithm in `app/core/algorithm.py`

### Database

- PostgreSQL with async (asyncpg)
- UUID primary keys throughout
- Schema managed via `Base.metadata.create_all` (`app/db/database.py`, `scripts/seed.py`) — no Alembic. Column type/constraint changes require a volume wipe (`make clean` + `make dev`).

## Development Notes for AI Agents

- Check for TypeScript errors after frontend changes.
- Frontend uses mock Google OAuth in development (not connected to backend yet).
- Comparison sessions are stored in-memory (not persistent).
- API endpoints are prefixed with `/api/`.
- Do **not** run `npm run ios`, `npm run android`, or `npx expo start` — the user runs these in a separate terminal.
- Do **not** run `git commit`, `git add`, or `git push` — the user handles staging, committing, and pushing.
- Do **not** run `make clean`, `make dev`, `make fresh`, `make restart`, or `make reset` — the user runs these themselves.
- Backend package management: use `uv`, not `pip`.

## Documentation Automation

`README.md`, `CLAUDE.md`, `AGENTS.md`, `fastapi/README.md`, and `frontend/README.md` are **generated** from templates in `docs/src/` by `scripts/build_docs.py`. Do not edit the generated files directly — edit the template or partial and re-render.

```bash
make docs-build    # render templates → generated files
make docs-check    # CI check: fail if generated docs are stale
```

Partials live in `docs/src/partials/` and are included with double-brace `include:partials/<name>.md` directives. `CLAUDE.md` and `AGENTS.md` share a single template (`docs/src/CLAUDE.md`) and are rendered to both paths.
