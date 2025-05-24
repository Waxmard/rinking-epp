# TierNerd API Endpoints

This document outlines the API endpoints needed to support the TierNerd application's UI functionality as described in the [UI Pages Documentation](ui_pages.md).

## Base URL

All API endpoints are prefixed with `/api/v1`.

## Authentication

The API uses JWT token-based authentication:
- `POST /auth/login`: Log in with credentials and get access token
- `POST /auth/refresh`: Refresh an expired token
- `POST /auth/google`: Authenticate with Google OAuth

All protected endpoints require an `Authorization` header with the format: `Bearer {token}`.

## User Endpoints

### Profile Management

- `GET /users/me`: Get current user profile
  - Returns user details including name, email, avatar URL, and preferences
- `PUT /users/me`: Update current user profile
  - Accepts user details for updating profile information
- `GET /users/me/lists`: Get summary of all lists created by the current user
  - Returns a paginated list of user's lists with basic information
  - Used for the home screen display

## List Endpoints

### List Management

- `GET /lists`: Get all lists for current user
  - Parameters:
    - `skip`: Number of items to skip (pagination)
    - `limit`: Maximum number of items to return
  - Returns: Array of list summary objects, sorted by last updated (newest first)

- `GET /lists/recent`: Get user's most recent list
  - Returns: The most recently accessed or updated list for the home screen

- `POST /lists`: Create a new list
  - Body:
    ```json
    {
      "title": "string",
      "description": "string",
      "is_public": boolean,
      "initial_items": [
        {
          "name": "string",
          "description": "string",
          "image_url": "string (optional)"
        }
      ]
    }
    ```
  - Returns: Created list summary object

- `GET /lists/{list_id}`: Get a specific list with items by tier
  - Parameters:
    - `list_id`: ID of the list to retrieve
    - `tier`: Optional parameter to filter by specific tier
  - Returns: List object with items from the specified tier, or all tiers if not specified

- `PUT /lists/{list_id}`: Update a list's metadata
  - Parameters:
    - `list_id`: ID of the list to update
  - Body:
    ```json
    {
      "title": "string",
      "description": "string",
      "is_public": boolean
    }
    ```
  - Returns: Updated list summary object

- `DELETE /lists/{list_id}`: Delete a list
  - Parameters:
    - `list_id`: ID of the list to delete
  - Returns: Success message

## Item Endpoints

### Item Management

- `POST /items/{list_id}`: Add a new item to a list
  - Parameters:
    - `list_id`: ID of the list to add the item to
  - Body:
    ```json
    {
      "name": "string",
      "description": "string",
      "image_url": "string (optional)"
    }
    ```
  - Returns: Created item object and a new comparison session ID

- `GET /items/{item_id}`: Get a specific item
  - Parameters:
    - `item_id`: ID of the item to retrieve
  - Returns: Item object with details

- `PUT /items/{item_id}`: Update an item's metadata
  - Parameters:
    - `item_id`: ID of the item to update
  - Body:
    ```json
    {
      "name": "string",
      "description": "string",
      "image_url": "string (optional)"
    }
    ```
  - Returns: Updated item object

- `DELETE /items/{item_id}`: Delete an item
  - Parameters:
    - `item_id`: ID of the item to delete
  - Returns: Success message

### Comparison and Ranking

- `POST /comparison/start`: Start a new comparison session for an item
  - Body:
    ```json
    {
      "list_id": "string",
      "item_id": "string" // The item to rank through comparisons
    }
    ```
  - Returns: Comparison session object with first comparison

- `POST /comparison/{session_id}/result`: Submit a comparison result
  - Parameters:
    - `session_id`: ID of the comparison session
  - Body:
    ```json
    {
      "result": "better" | "worse" // Only two options, no "equal" option
    }
    ```
  - Returns:
    - Next comparison if more comparisons are needed
    - Final ranking result if comparisons are complete
    - Or null if the comparison session is invalid/expired

- `GET /comparison/{session_id}/status`: Check the status of a comparison session
  - Parameters:
    - `session_id`: ID of the comparison session
  - Returns: Current status of the session including progress

## Tier Management

- `GET /lists/{list_id}/tier/{tier}`: Get all items in a specific tier for a list
  - Parameters:
    - `list_id`: ID of the list
    - `tier`: Tier to retrieve (S, A, B, C, D, F, or unranked)
  - Returns: Array of items in the specified tier

## Response Formats

### List Summary Object

```json
{
  "list_id": "string",
  "user_id": "string",
  "title": "string",
  "description": "string",
  "is_public": boolean,
  "item_count": integer,
  "tier_counts": {
    "S": integer,
    "A": integer,
    "B": integer,
    "C": integer,
    "D": integer,
    "F": integer,
    "unranked": integer
  },
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

### List With Tier Items Object

```json
{
  "list_id": "string",
  "user_id": "string",
  "title": "string",
  "description": "string",
  "is_public": boolean,
  "created_at": "datetime",
  "updated_at": "datetime",
  "tier_requested": "string or null", // The tier that was requested, null if all tiers
  "items": [Item], // Items from the requested tier, or grouped by tier if all tiers requested
  "tier_counts": {
    "S": integer,
    "A": integer,
    "B": integer,
    "C": integer,
    "D": integer,
    "F": integer,
    "unranked": integer
  }
}
```

### Item Object

```json
{
  "item_id": "string",
  "list_id": "string",
  "name": "string",
  "description": "string",
  "image_url": "string",
  "position": integer,
  "rating": number,
  "tier": "string (S, A, B, C, D, F, or null)",
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

### Comparison Session Object

```json
{
  "session_id": "string",
  "list_id": "string",
  "item_id": "string", // The item being ranked
  "status": "in_progress" | "completed",
  "progress": number, // 0-100 percentage
  "comparison": {
    "reference_item": Item, // The item we're comparing against
    "target_item": Item, // The item being ranked
    "comparison_index": integer, // Current position in the binary search
    "min_index": integer, // Current min bound of binary search
    "max_index": integer  // Current max bound of binary search
  }
}
```

### User Object

```json
{
  "user_id": "string",
  "username": "string",
  "email": "string",
  "display_name": "string",
  "avatar_url": "string",
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

## Error Handling

All API endpoints use standard HTTP status codes:
- 200: Success
- 201: Created
- 400: Bad Request
- 401: Unauthorized
- 403: Forbidden
- 404: Not Found
- 422: Validation Error
- 500: Internal Server Error

Error responses follow this format:
```json
{
  "detail": "Error message"
}
```

For validation errors:
```json
{
  "detail": [
    {
      "loc": ["body", "field_name"],
      "msg": "Error message",
      "type": "error_type"
    }
  ]
}
```

## Implementation Notes

1. **Session-based Comparison Approach**:
   - The Comparison Session Object contains all state for ranking an item
   - Server maintains this state throughout the comparison process
   - Using a session ID simplifies the client experience and allows the server to optimize the comparison algorithm

2. **Simplified Comparison Flow**:
   - Only "better" or "worse" options (no "equal") to force decisive rankings
   - Binary search algorithm determines the most efficient sequence of comparisons
   - Server handles all the complexity of maintaining the search state

3. **Tiered Data Loading**:
   - List data is always returned in a tiered approach
   - Tier counts provide a quick overview of item distribution
   - Individual tiers can be loaded on demand to improve performance
   - Supports progressive loading for large lists

4. **Key Workflow**: Adding an item and ranking it
   - Add item with POST /items/{list_id}
   - Use the returned session_id to start comparisons
   - Submit each comparison result
   - The system automatically assigns the proper tier when complete

5. **Future Enhancements** (not included in initial implementation):
   - Batch tier assignment for drag-and-drop functionality
   - "Equal" option in comparisons
   - Manual tier assignment
   - List sharing features
