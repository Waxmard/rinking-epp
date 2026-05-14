# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TierNerd is a cross-platform mobile app for creating ranked tier lists (S-F) through 1v1 comparisons. Monorepo with React Native/Expo frontend and FastAPI backend.

## Repo Layout

- `fastapi/` — Python backend (uv, pyproject.toml, Dockerfile, Makefile)
- `frontend/` — React Native/Expo app (package.json, eslint, prettier)
- `/package.json` — root dev-tooling only (husky). Not a JS project.
- `.husky/` — git hooks (pre-commit → `cd frontend && npx lint-staged`)
- `.pre-commit-config.yaml` — Python hooks (ruff, black) for `fastapi/`

## First-Time Setup

```bash
npm install        # at repo root — installs husky, activates git hooks
cd frontend && npm install
cd ../fastapi && uv sync --group dev
pre-commit install # activates Python hooks
```

Skipping root `npm install` means frontend pre-commit hooks won't run.

## Development Commands

### Backend (fastapi/)

**Always use `make` commands instead of raw `docker` commands.** Claude may run read-only ones (`make logs`, `make stop`, `make health`); the user runs build/dev/reset commands (`make dev`, `make fresh`, `make restart`, `make reset`, `make clean`).

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

# Dev credentials (auto-created on startup): dev@tiernerd.com / devpassword

# Package management (use uv, not pip)
uv sync                           # Install dependencies
uv sync --group dev               # Install with dev dependencies

# Code quality
uv run ruff check app/            # Lint (rules: E, F, I, B, UP, SIM)
uv run ruff check app/ --fix      # Lint + autofix
uv run ruff format app/           # Format (replaces black)
uv run mypy app/                  # Type check

# Testing
uv run pytest                     # Run all tests
uv run pytest tests/test_items.py # Run single test file
uv run pytest -k "test_name"      # Run specific test
uv run pytest --cov=app --cov-report=term-missing  # Run with coverage
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

### Git Hooks (root)

Husky runs `lint-staged` on staged frontend files (`eslint --fix` + `prettier --write` on `*.{ts,tsx}`; prettier on `*.{js,jsx,json}`). Config in `frontend/package.json` under `lint-staged`. Hook script in `.husky/pre-commit`.

Python files use `pre-commit` framework (`.pre-commit-config.yaml`) — independent of husky.

## Architecture

### Backend Structure (fastapi/app/)
- `api/endpoints/` - Route handlers (users, lists, items)
- `core/` - Auth (JWT), security (argon2), constants, ranking algorithm
- `crud/` - Database operations
- `db/` - SQLAlchemy models and async database setup
- `schemas/` - Pydantic request/response models
- `settings.py` - Configuration via pydantic-settings

### Frontend Structure (frontend/src/)
- `screens/` - Screen components (Login, Home, Lists, Profile)
- `navigation/` - React Navigation stack setup
- `providers/` - Context providers (AuthContext)
- `design-system/` - Reusable components and design tokens

### Key Patterns
- **Backend**: Async SQLAlchemy 2.0+, FastAPI dependency injection, JWT auth
- **Frontend**: Context API for state, token-based design system, TypeScript strict mode
- **Items**: Ordered via Base-62 fractional index `position` column (`app/core/fractional_index.py`)
- **Ranking**: Binary search algorithm in `app/core/algorithm.py`

### Database
- PostgreSQL with async (asyncpg)
- UUID primary keys throughout
- Schema managed via `Base.metadata.create_all` (`app/db/database.py`, `scripts/seed.py`) — no Alembic. Column type/constraint changes require a volume wipe (`make clean` + `make dev`).

## Development Notes

- Be mindful to check for TypeScript errors in frontend
- Frontend uses mock Google OAuth in development (not connected to backend yet)
- Comparison sessions are stored in-memory (not persistent)
- API endpoints prefixed with `/api/`
- Do not run `npm run ios`, `npm run android`, or `npx expo start` - user runs these in a separate terminal
- Do not run git commit/push - user handles staging, committing, and pushing themselves
- Do not run `make clean`, `make dev`, `make fresh`, `make restart`, or `make reset` - user runs these themselves
