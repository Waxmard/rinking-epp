from app.api.endpoints import items, lists, users
from fastapi import APIRouter

api_router = APIRouter()

# Include routers from endpoints
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(lists.router, prefix="/lists", tags=["lists"])
api_router.include_router(items.router, prefix="/items", tags=["items"])
