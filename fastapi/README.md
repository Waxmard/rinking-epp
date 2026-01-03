# TierNerd Backend

FastAPI backend for the TierNerd ranking app.

## Quick Start

```bash
# Start the backend (builds and runs Docker containers)
make dev-up

# In another terminal, seed the database with dev users
make seed
```

The API is now running at http://localhost:8000

## Dev Credentials

After running `make seed`, you can login with:

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
make dev-up      # Build and run containers
make restart     # Rebuild and restart
make fresh       # Rebuild, restart, and show logs
make logs        # View container logs
make stop        # Stop containers
make health      # Check health endpoint
```

### Database
```bash
make seed        # Add dev users to database
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
