# TierNerd Backend

FastAPI backend for the TierNerd ranking app.

## Quick Start

```bash
# Start the backend (builds and runs Docker containers, auto-seeds dev user)
make dev

# Or run in background
make dev DETACHED=1
```

The API is now running at http://localhost:8000

## Dev Credentials

The dev user is auto-created on startup:

| Email | Password |
|-------|----------|
| dev@tiernerd.com | devpassword |

## API Documentation

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

## Make Commands

Run `make help` for all available commands.

## Development

### API Structure

The API is structured around the following resources:
- `/api/users`: User management and authentication
- `/api/lists`: List creation and management
- `/api/items`: Item management and ranking

## Testing

### Test Suite Overview

The backend includes comprehensive unit tests for all API endpoints achieving full coverage of endpoint functionality.

### Test Infrastructure

- **Framework**: pytest with pytest-asyncio for async support
- **Test Database**: SQLite in-memory for fast, isolated tests
- **HTTP Client**: httpx AsyncClient for endpoint testing
- **Test Files**:
  - `tests/conftest.py` - Test configuration and fixtures
  - `tests/test_users.py` - User endpoint tests
  - `tests/test_lists.py` - List endpoint tests
  - `tests/test_items.py` - Item endpoint tests
  - `tests/app/utils/test_algorithm.py` - Algorithm tests

### Running Tests

```bash
# Install dev dependencies (includes testing packages)
uv sync --group dev

# Run all endpoint tests
uv run pytest tests/test_users.py tests/test_lists.py tests/test_items.py -v

# Run all tests
uv run pytest -v

# Run specific test file
uv run pytest tests/test_users.py -v

# Run specific test class
uv run pytest tests/test_users.py::TestUserCreation -v

# Run specific test
uv run pytest tests/test_users.py::TestUserCreation::test_create_user_success -v

# Run with coverage report
uv run pytest --cov=app --cov-report=html
```

### Test Coverage

#### Users Endpoints
- ✅ User registration (success, duplicates, validation errors)
- ✅ Login with email and username
- ✅ Authentication token generation
- ✅ Reading user lists (authenticated/unauthenticated)
- ✅ Current user retrieval
- ✅ Invalid token handling

#### Lists Endpoints
- ✅ Reading user's lists with item counts
- ✅ Creating lists (success, duplicates, validation)
- ✅ Reading specific lists
- ✅ Updating lists (full and partial updates)
- ✅ Deleting lists
- ✅ Authorization checks (wrong user access)
- ✅ Pagination support

#### Items Endpoints
- ✅ Creating items (first item, subsequent items with comparison)
- ✅ Comparison workflow (better/worse results)
- ✅ Comparison session management
- ✅ Reading specific items
- ✅ Updating items (full and partial updates)
- ✅ Deleting items
- ✅ Authorization checks

#### Algorithm
- ✅ Binary search ranking algorithm
- ✅ Winner/loser comparison logic
- ✅ Range narrowing behavior
- ✅ Edge cases

### Test Fixtures

The test suite includes reusable fixtures for:
- Test database sessions (SQLite in-memory)
- Authenticated HTTP clients
- Test users with authentication tokens
- Test lists and items
- Multiple users for authorization testing

### Code Quality Tools

```bash
# Format code
uv run black app/

# Sort imports
uv run isort app/

# Lint code
uv run ruff check app/

# Type check
uv run mypy app/
```

### Ranking Algorithm

The ranking algorithm is implemented in `app/core/algorithm.py` and uses binary search to efficiently determine item positions through pairwise comparisons.

### Database
```bash
make reset       # Clear database and re-seed
make clean       # Remove containers, volumes, and images
```

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

- **FastAPI** - Web framework
- **PostgreSQL** - Database (via asyncpg)
- **SQLAlchemy 2.0** - Async ORM
- **JWT** - Authentication
- **Docker** - Containerization
