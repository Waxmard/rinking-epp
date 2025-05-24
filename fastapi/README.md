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
