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
