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

### Development
```bash
make dev              # Build and run containers (auto-seeds dev user)
make dev DETACHED=1   # Run in background
make restart          # Rebuild and restart
make fresh            # Rebuild, restart, and show logs
make logs             # View container logs
make stop             # Stop containers
make health           # Check health endpoint
```

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
