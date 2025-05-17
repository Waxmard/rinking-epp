# TierNerd Authentication Strategy

This document outlines the authentication strategy for the TierNerd application, focusing on a direct OAuth implementation with Google.

## Overview

TierNerd will implement Google Sign-In as the primary authentication method, allowing users to log in using their Google accounts. This approach offers several benefits:

- Simplified onboarding process for users
- Strong security through Google's authentication infrastructure
- No need for password management
- Access to user profile information (with consent)

## Implementation Approach: Direct OAuth with Google

We'll implement direct OAuth with Google (without Firebase intermediary) to maintain full control over our authentication flow and minimize dependencies.

### Architecture

```
┌─────────────┐     ┌──────────────┐     ┌────────────────┐
│ Flutter App │────▶│ Google Auth  │────▶│ TierNerd API   │
│             │◀────│ Servers      │     │ (FastAPI)      │
└─────────────┘     └──────────────┘     └────────────────┘
                                                 │
                                                 ▼
                                         ┌────────────────┐
                                         │ Database       │
                                         │ (User Records) │
                                         └────────────────┘
```

### Authentication Flow

1. **User initiates sign-in**: User taps "Sign in with Google" button in TierNerd app
2. **Google authentication**: App connects to Google servers for authentication
3. **Consent and authorization**: User consents to share profile information
4. **Token generation**: Google provides authentication tokens
5. **Backend verification**:
   - App sends token to TierNerd backend
   - Backend verifies token with Google
   - Backend creates/retrieves user account
6. **Session creation**:
   - Backend generates session token or JWT
   - App stores token for authenticated requests
7. **Authenticated state**: User is now signed in to TierNerd

## Technical Components

### Frontend (Flutter)

- **Google Sign-In Package**: Flutter package to integrate Google Sign-In
- **Authentication UI**: "Sign in with Google" button and associated UI flows
- **Token Management**: Secure storage and management of auth tokens
- **Session Handling**: Managing authenticated state within the app

### Backend (FastAPI)

- **Auth Endpoints**: Endpoints to receive and verify Google tokens
- **Token Verification**: Logic to verify tokens with Google servers
- **User Management**: Create or retrieve user accounts based on Google ID
- **JWT Implementation**: Generate and validate JWT tokens for app sessions
- **Protected Routes**: Ensure API endpoints require authentication

### Google Cloud Platform

- **OAuth Consent Screen**: Define app information and requested scopes
- **Client IDs**: Separate client IDs for each platform (Android, iOS, web)
- **API Configuration**: Enable required Google APIs for authentication

## Cost Analysis

**Google Authentication Services:**
- Basic OAuth 2.0 authentication: **Free**
- Token verification: **Free**
- Google Sign-In SDK/libraries: **Free**
- Google Cloud Project creation: **Free**

**Potential Costs:**
- **Verification Fee**: $75 one-time fee **only if**:
  - App requires sensitive or restricted scopes beyond basic profile info
  - App is used by general public (not just within organization)
  - For TierNerd's basic authentication needs (email, name, profile picture), verification is likely unnecessary

**Backend Costs:**
- API hosting costs for your FastAPI backend
- Database storage costs for user records
- These are independent of authentication method chosen

## Security Considerations

1. **Token Storage**: Securely store authentication tokens on device using platform-specific secure storage
2. **Backend Verification**: Always verify tokens on backend before granting access
3. **Scope Limitation**: Request only necessary user information (email, name, profile picture)
4. **Token Expiration**: Implement proper token expiration and refresh mechanisms
5. **Session Management**: Enable users to view active sessions and log out remotely
6. **HTTPS**: All communication must use secure HTTPS connections

## User Data Management

TierNerd will store the following user information from Google authentication:

- Google ID (unique identifier)
- Email address
- Display name
- Profile picture URL (optional)
- Account creation date
- Last login date

This data will be used for:
- User identification
- Profile display
- Account management
- Authentication verification

## Future Expansion Options

1. **Additional authentication methods**:
   - Apple Sign-In (for iOS users)
   - Email/password (traditional)

2. **Enhanced security features**:
   - Two-factor authentication
   - Session timeouts
   - IP-based restrictions

3. **User management**:
   - Account linking
   - Profile management
   - Account deletion

## Implementation Plan

1. Configure Google Cloud Platform OAuth
2. Set up authentication endpoints in backend
3. Implement user model in database
4. Develop Google Sign-In in Flutter UI
5. Create protected route middleware
6. Implement token refresh logic
7. Add session management features
8. Develop comprehensive testing

## References

- [Google Identity Services Documentation](https://developers.google.com/identity/protocols/oauth2)
- [OAuth 2.0 Specifications](https://oauth.net/2/)
- [JWT Introduction](https://jwt.io/introduction)