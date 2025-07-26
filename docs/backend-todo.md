# Backend TODO - FastAPI Tasks for TierNerd

This document outlines the required backend changes to support the frontend application.

## Current Status
- ❌ Frontend cannot connect to backend due to API mismatches
- ❌ Authentication expects Google OAuth but backend uses password auth
- ❌ Missing database fields causing errors
- ✅ Basic API structure exists
- ✅ CORS is configured

---

## Priority 1: Critical Fixes 🚨
**These are blocking frontend testing and must be fixed first**

### 1.1 Fix Item Model - Missing Position Field
**File**: `fastapi/app/db/models.py`

The Item model is missing the `position` field that's referenced in queries.

```python
# Add to Item class:
position: Mapped[int] = mapped_column(nullable=True)
```

### 1.2 Update User Model for Frontend Compatibility
**File**: `fastapi/app/db/models.py`

Add these fields to the User model:
```python
display_name: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
photo_url: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
google_id: Mapped[Optional[str]] = mapped_column(String(255), unique=True, nullable=True)
```

### 1.3 Create Mock Authentication Endpoint
**File**: `fastapi/app/api/endpoints/users.py`

Add a temporary endpoint for development without Google OAuth:
```python
@router.post("/auth/mock", response_model=Token)
async def mock_auth(
    email: str,
    display_name: Optional[str] = None,
    db: AsyncSession = Depends(get_db)
) -> Any:
    """
    Mock authentication for development.
    Creates user if doesn't exist, returns JWT token.
    """
    # Check if user exists
    user = await get_user_by_email(db, email=email)
    
    if not user:
        # Create new user
        user_in = UserCreate(
            email=email,
            username=email.split('@')[0],
            password="mock123",  # Not used but required by current model
            display_name=display_name or email.split('@')[0]
        )
        user = await create_user(db, obj_in=user_in)
    
    # Generate token
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    return {
        "access_token": create_access_token(
            user.user_id, expires_delta=access_token_expires
        ),
        "token_type": "bearer",
    }
```

### 1.4 Run Database Migrations
After making model changes:
```bash
cd fastapi
alembic revision --autogenerate -m "Add missing fields for frontend compatibility"
alembic upgrade head
```

---

## Priority 2: API Contract Fixes 📝
**Required for proper frontend-backend integration**

### 2.1 Fix Create List Endpoint
**File**: `fastapi/app/api/endpoints/lists.py`

Current implementation uses query parameters, but frontend sends request body.

```python
# Change the create_list endpoint to:
@router.post("/", response_model=List)
async def create_list(
    list_in: ListCreate,  # Use schema
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Any:
    """Create new list."""
    # Check if list exists
    query = select(ListModel).where(
        ListModel.title == list_in.title, 
        ListModel.user_id == current_user.user_id
    )
    result = await db.execute(query)
    if result.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="List already exists"
        )
    
    # Create list
    list_obj = ListModel(
        list_id=uuid.uuid4(),
        title=list_in.title,
        description=list_in.description,
        user_id=current_user.user_id,
        created_at=datetime.now(),
        updated_at=datetime.now(),
    )
    db.add(list_obj)
    await db.commit()
    await db.refresh(list_obj)
    
    return list_obj
```

### 2.2 Update User Schema
**File**: `fastapi/app/schemas/user.py`

Add missing fields to User schema:
```python
class User(BaseModel):
    user_id: UUID
    email: str
    username: str
    display_name: Optional[str] = None
    photo_url: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
```

### 2.3 Add User Stats Endpoint
**File**: `fastapi/app/api/endpoints/users.py`

```python
@router.get("/me/stats")
async def get_user_stats(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> Any:
    """Get statistics for current user."""
    # Count lists
    lists_count = await db.scalar(
        select(func.count(ListModel.list_id))
        .where(ListModel.user_id == current_user.user_id)
    )
    
    # Count items
    items_count = await db.scalar(
        select(func.count(ItemModel.item_id))
        .join(ListModel)
        .where(ListModel.user_id == current_user.user_id)
    )
    
    # Get most used tier (mock for now)
    most_used_tier = "A"  # TODO: Calculate from actual data
    
    return {
        "totalLists": lists_count or 0,
        "totalItems": items_count or 0,
        "mostUsedTier": most_used_tier
    }
```

### 2.4 Add Recent Lists Endpoint
**File**: `fastapi/app/api/endpoints/lists.py`

```python
@router.get("/recent", response_model=List[ListSimple])
async def get_recent_lists(
    limit: int = 3,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
) -> Any:
    """Get user's most recent lists."""
    query = (
        select(ListModel, func.count(ItemModel.item_id).label("item_count"))
        .outerjoin(ItemModel)
        .where(ListModel.user_id == current_user.user_id)
        .group_by(ListModel.list_id)
        .order_by(ListModel.updated_at.desc())
        .limit(limit)
    )
    
    result = await db.execute(query)
    lists_with_counts = result.all()
    
    return [
        {
            "list_id": list_obj.list_id,
            "title": list_obj.title,
            "description": list_obj.description,
            "item_count": item_count,
            "created_at": list_obj.created_at,
            "updated_at": list_obj.updated_at,
        }
        for list_obj, item_count in lists_with_counts
    ]
```

---

## Priority 3: Google OAuth Implementation 🔐
**For production deployment**

### 3.1 Install Google Auth Dependencies
```bash
pip install google-auth google-auth-httplib2 google-auth-oauthlib
```

### 3.2 Add Google Auth Verification
**File**: `fastapi/app/core/auth.py`

```python
from google.oauth2 import id_token
from google.auth.transport import requests

async def verify_google_token(token: str) -> dict:
    """Verify Google OAuth token and return user info."""
    try:
        # Verify the token
        idinfo = id_token.verify_oauth2_token(
            token, 
            requests.Request(), 
            settings.GOOGLE_CLIENT_ID
        )
        
        # Token is valid
        return {
            "google_id": idinfo['sub'],
            "email": idinfo['email'],
            "display_name": idinfo.get('name'),
            "photo_url": idinfo.get('picture'),
        }
    except ValueError:
        # Invalid token
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid Google token"
        )
```

### 3.3 Add Google Auth Endpoint
**File**: `fastapi/app/api/endpoints/users.py`

```python
@router.post("/auth/google", response_model=Token)
async def google_auth(
    token: str,
    db: AsyncSession = Depends(get_db)
) -> Any:
    """Authenticate with Google OAuth token."""
    # Verify token
    google_user = await verify_google_token(token)
    
    # Get or create user
    user = await get_user_by_email(db, email=google_user['email'])
    
    if not user:
        # Create new user
        user_obj = User(
            user_id=uuid.uuid4(),
            email=google_user['email'],
            username=google_user['email'].split('@')[0],
            google_id=google_user['google_id'],
            display_name=google_user['display_name'],
            photo_url=google_user['photo_url'],
            password_hash="",  # No password for Google users
        )
        db.add(user_obj)
        await db.commit()
        await db.refresh(user_obj)
        user = user_obj
    else:
        # Update user info
        user.display_name = google_user['display_name']
        user.photo_url = google_user['photo_url']
        await db.commit()
    
    # Generate JWT
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    return {
        "access_token": create_access_token(
            user.user_id, expires_delta=access_token_expires
        ),
        "token_type": "bearer",
    }
```

### 3.4 Update Settings
**File**: `fastapi/app/settings.py`

```python
GOOGLE_CLIENT_ID: str = os.getenv("GOOGLE_CLIENT_ID", "")
GOOGLE_CLIENT_SECRET: str = os.getenv("GOOGLE_CLIENT_SECRET", "")
```

---

## Testing Checklist ✅

### With Mock Auth:
- [ ] POST `/api/users/auth/mock` with email returns JWT token
- [ ] GET `/api/users/me` with token returns user info with display_name
- [ ] POST `/api/lists/` creates a new list
- [ ] GET `/api/lists/` returns user's lists
- [ ] GET `/api/users/me/stats` returns statistics

### Expected Response Formats:

**User Response**:
```json
{
  "user_id": "uuid-here",
  "email": "user@example.com",
  "username": "user",
  "display_name": "John Doe",
  "photo_url": "https://example.com/photo.jpg",
  "created_at": "2024-01-26T10:00:00",
  "updated_at": "2024-01-26T10:00:00"
}
```

**List Response**:
```json
{
  "list_id": "uuid-here",
  "user_id": "uuid-here",
  "title": "Best Programming Languages",
  "description": "My favorites",
  "item_count": 15,
  "created_at": "2024-01-26T10:00:00",
  "updated_at": "2024-01-26T10:00:00"
}
```

**Stats Response**:
```json
{
  "totalLists": 5,
  "totalItems": 47,
  "mostUsedTier": "A"
}
```

---

## How to Test with Frontend

1. Start the backend:
   ```bash
   cd fastapi
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

2. Frontend will connect to `http://localhost:8000`

3. Use mock auth endpoint to get token:
   ```bash
   curl -X POST "http://localhost:8000/api/users/auth/mock?email=test@example.com"
   ```

4. Frontend should now be able to:
   - Sign in (mocked)
   - Create lists
   - View lists
   - See user profile

---

## Questions?

If you have questions about any of these tasks:
1. Check the existing code in the mentioned files
2. Look at the schemas in `app/schemas/` for data structures
3. The frontend expects these exact response formats

Priority 1 tasks are critical - the app won't work without them!