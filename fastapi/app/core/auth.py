from datetime import datetime, timedelta
from typing import Any, Optional, Union

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from passlib.context import CryptContext
from sqlalchemy.ext.asyncio import AsyncSession

from app.settings import settings
from app.crud.crud_user import get_user_by_email, get_user_by_username
from app.db.database import get_db
from app.schemas.user import TokenPayload, User
from app.core.security import verify_password
from uuid import UUID

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/users/token")


async def authenticate_user(
    db: AsyncSession, username_or_email: str, password: str
) -> Optional[User]:
    """Authenticate a user with email or username."""
    # Check if it looks like an email
    if "@" in username_or_email and "." in username_or_email:
        user = await get_user_by_email(db, username_or_email)
    else:
        # Try username first, then email as fallback
        user = await get_user_by_username(db, username_or_email)
        if not user:
            user = await get_user_by_email(db, username_or_email)

    if not user:
        return None
    if not verify_password(password, user.password_hash):
        return None
    return user


def create_access_token(
    subject: Union[str, Any], expires_delta: Optional[timedelta] = None
) -> str:
    """Create a JWT access token."""
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(
            minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES
        )
    to_encode = {"exp": expire, "sub": str(subject)}
    encoded_jwt = jwt.encode(
        to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM
    )
    return encoded_jwt


async def get_current_user(
    db: AsyncSession = Depends(get_db), token: str = Depends(oauth2_scheme)
) -> User:
    """Get the current authenticated user."""
    if settings.APP_ENV == "development":
        # In development mode, return a mock user
        return User(
            user_id=UUID("123e4567-e89b-12d3-a456-426614174000"),
            email="dev@example.com",
            username=None,
            created_at=datetime.now(),
            updated_at=datetime.now(),
        )
    
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(
            token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM]
        )
        user_id: str = payload.get("sub")
        if user_id is None:
            raise credentials_exception
        token_data = TokenPayload(sub=user_id)
    except JWTError:
        raise credentials_exception

    from app.crud.crud_user import get_user_by_id
    user = await get_user_by_id(db, UUID(token_data.sub))
    if user is None:
        raise credentials_exception
    return user
