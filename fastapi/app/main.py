from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.api import api_router
from app.settings import settings
from app.db.database import create_tables

app = FastAPI(
    title="Ranking App API",
    description="API for a ranking application that uses binary comparisons",
    version="0.1.0",
)

# Set up CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API router
app.include_router(api_router, prefix="/api")


@app.on_event("startup")
async def startup():
    """Initialize application on startup."""
    await create_tables()


@app.get("/")
async def root():
    """Root endpoint."""
    return {"message": "Welcome to the Ranking App API"}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
