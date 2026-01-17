# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TierNerd is a cross-platform mobile app for creating ranked tier lists (S-F) through 1v1 comparisons. Monorepo with React Native/Expo frontend and FastAPI backend.

## Development Commands

### Backend (fastapi/)

**Always use `make` commands instead of raw `docker` commands.**

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
uv run black app/                 # Format code
uv run isort app/                 # Sort imports
uv run ruff check app/            # Lint
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
- **Items**: Linked list structure via `prev_item_id`/`next_item_id` for sorted order
- **Ranking**: Binary search algorithm in `app/core/algorithm.py`

### Database
- PostgreSQL with async (asyncpg)
- UUID primary keys throughout
- Migrations via Alembic

## Development Notes

- Be mindful to check for TypeScript errors in frontend
- Frontend uses mock Google OAuth in development (not connected to backend yet)
- Comparison sessions are stored in-memory (not persistent)
- API endpoints prefixed with `/api/`
- Do not run `npm run ios`, `npm run android`, or `npx expo start` - user runs these in a separate terminal
- Do not run git commit/push - user handles staging, committing, and pushing themselves
