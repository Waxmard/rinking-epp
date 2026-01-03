# TierNerd Backend (FastAPI)

This directory contains the FastAPI backend for TierNerd.

## Project Overview

The backend provides a RESTful API for:
- User authentication and management
- Creating and managing ranking lists
- Adding items to lists
- Ranking items through 1v1 comparisons
- Calculating item positions and ratings

## Tech Stack

- **FastAPI**: Modern, high-performance web framework
- **SQLAlchemy**: SQL toolkit and ORM
- **Pydantic**: Data validation and settings management
- **JWT**: Authentication using JSON Web Tokens
- **PostgreSQL**: Database
- **Uvicorn**: ASGI server
- **uv**: Fast Python package installer and resolver

## Setup

- Install uv (if not already installed): `pip install uv`

- Create and activate a virtual environment:
  ```bash
  uv venv
  source .venv/bin/activate  # On Windows: .venv\Scripts\activate
  ```

- Install dependencies: `uv pip install -e .`

- Create a PostgreSQL database named `tiernerd`

## Running the Application

Start the development server:

```bash
uvicorn app.main:app --reload
```

The API will be available at http://localhost:8000

## API Documentation

Once the application is running, you can access:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

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
uv sync --extra dev

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

The ranking algorithm is implemented in `app/utils/algorithm.py` and works by:
1. Presenting users with binary comparisons between items
2. Using the results to determine each item's position
3. Converting positions to ratings (10.0 for top item, 0.1 for bottom)
4. Mapping numeric ratings to tier rankings (S, A, B, C, D, F)

### Tier Classification System

Numeric ratings are mapped to tiers using the following ranges:

| Tier | Rating Range |
|------|-------------|
| S    | 9.0 - 10.0   |
| A    | 7.5 - 8.9    |
| B    | 6.0 - 7.4    |
| C    | 4.5 - 5.9    |
| D    | 3.0 - 4.4    |
| F    | 0.1 - 2.9    |


# Start Postgres db locally
psql -U postgres -h localhost -d ranking_app

# Sample Test Requests

Post Lists Request
```bash
curl -X POST "http://localhost:8000/api/lists/?name=faggot&description=for%20gays"   -H "Authorization: Bearer <your-token>"
```

Create User Request
```bash
curl -X POST "http://localhost:8000/api/users/" -H "Content-Type: application/json" -H "Authorization: Bearer <your-token>" -d '{"username": "testuser", "email": "testuser@example.com", "password": "testpassword"}'
```

Create Item Request
```bash
curl -X POST "http://localhost:8000/api/items/?list_title=faggot" -H "Content-Type: application/json" -H "Authorization: Bearer <your-token>" -d '{"name": "testitem", "description": "still gay", "image_url": "https://example.com/"}'
```
