from datetime import timedelta
from typing import Any, List

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.auth import (
    authenticate_user,
    create_access_token,
    get_current_user,
)
from app.db.database import get_db
from app.db.models import User as UserModel
from app.schemas.user import Token, User, UserCreate, UserPublic

router = APIRouter()

create_user = None


@router.post("/", response_model=User, status_code=status.HTTP_201_CREATED)
async def create_user(user_in: UserCreate, db: AsyncSession = Depends(get_db)) -> Any:
    """
    Create a new user.
    """
    # Check if user exists
    from app.crud.crud_user import get_user_by_email, create_user

    user = await get_user_by_email(db, email=user_in.email)
    if user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="A user with this email already exists",
        )

    # Create new user
    user = await create_user(db, obj_in=user_in)
    return user


@router.post("/token", response_model=Token)
async def login_for_access_token(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: AsyncSession = Depends(get_db),
) -> Any:
    """
    OAuth2 compatible token login, get an access token for future requests.
    """
    from app.settings import settings

    user = await authenticate_user(db, form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    return {
        "access_token": create_access_token(
            user.user_id, expires_delta=access_token_expires
        ),
        "token_type": "bearer",
    }


@router.get("/", response_model=List[UserPublic])
async def read_users(
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Any:
    """
    Retrieve users. Requires authentication.
    """
    query = select(UserModel).offset(skip).limit(limit)
    result = await db.execute(query)
    users = result.scalars().all()

    return [
        {
            "user_id": user.user_id,
            "email": user.email,
            "username": user.username,
            "created_at": user.created_at,
        }
        for user in users
    ]


@router.get("/me", response_model=User)
async def read_users_me(current_user: User = Depends(get_current_user)) -> Any:
    """
    Get current user.
    """
    return current_user
