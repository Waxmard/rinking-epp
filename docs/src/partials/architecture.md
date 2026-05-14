## Architecture

### Backend Structure (`fastapi/app/`)

- `api/endpoints/` — Route handlers (users, lists, items)
- `services/` — Business logic (auth/JWT, comparison, list, ranking)
- `core/` — Pure utilities (security/argon2, constants, ranking algorithm, fractional index)
- `crud/` — Database operations
- `db/` — SQLAlchemy models and async database setup
- `schemas/` — Pydantic request/response models
- `settings.py` — Configuration via pydantic-settings

Module boundaries enforced by [tach](https://docs.gauge.sh/) (`fastapi/tach.toml`). Layering: `main → api → services → crud → db`. `api` may also call `crud` directly (endpoint handlers use `crud_*` helpers); this is intentional, not a violation. `core` is a pure leaf (constants, security, algorithm, fractional_index) reachable from `api`/`services`/`crud`. `schemas`/`settings`/`utils` are cross-cutting. Run `make backend-boundaries` (or `uv run tach check` in `fastapi/`) to verify.

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
