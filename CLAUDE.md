# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Flutter-based mobile app development project focused on creating educational applications for elementary students with real API integration.

## Project Structure

**elementary_student_app/**
- Flutter application with real API authentication
- Email/password login and registration
- JWT token-based authentication with secure storage
- API endpoint: `http://localhost:6000`

## Important Development Rules

### ⛔ NEVER Use Mock Data

**CRITICAL RULE**: This project uses REAL API integration ONLY. Mock data usage is STRICTLY PROHIBITED in all circumstances.

- ❌ NEVER create mock services or mock data
- ❌ NEVER use demo/test accounts with hardcoded credentials
- ❌ NEVER implement fallback to mock data
- ✅ ALWAYS use the real API endpoints defined in API-DOCUMENTATION.md
- ✅ ALWAYS implement proper error handling for API failures
- ✅ ALWAYS use real authentication tokens and secure storage

### API Integration

**Base URL**: `http://eng.gunsiya.com`

**Authentication Flow**:
1. Register: `POST /api/auth/register` - Creates new user account
2. Login: `POST /api/auth/login` - Returns JWT tokens (access & refresh)
3. Token Storage: Use `flutter_secure_storage` for secure token management
4. Auto-refresh: Implement automatic token refresh on 401 errors
5. Logout: `POST /api/auth/logout` - Invalidates refresh token

**Required Headers**:
- `Content-Type: application/json`
- `Authorization: Bearer {accessToken}` (for protected endpoints)

### Authentication Requirements

**Email & Password Validation**:
- Email: Valid email format required
- Username: 3-50 characters, alphanumeric and underscores only
- Password: Minimum 8 characters, must include uppercase, lowercase, and number

**Token Management**:
- Access Token: Valid for 15 minutes
- Refresh Token: Valid for 7 days
- Auto-refresh on 401 responses
- Secure storage using `flutter_secure_storage`

### Code Architecture

**State Management**: Provider pattern with `ChangeNotifier`

**Service Layer**:
- `api_auth_service.dart` - Real API authentication service
- Handles HTTP requests, token management, and auto-refresh
- Implements secure storage for credentials

**Models**:
- `UserModel` - User data with API response mapping
- Factory methods: `fromApiLoginResponse()`, `fromApiRegisterResponse()`

**Providers**:
- `AuthProvider` - Central authentication state management
- Methods: `signUpWithEmail()`, `signInWithEmail()`, `signOut()`

## Common Development Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Clean build artifacts
flutter clean

# Build for release
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

## Key Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  provider: ^6.1.5+1
  http: ^1.2.0
  flutter_secure_storage: ^9.0.0

  # Legacy (not used for API auth):
  firebase_core: ^4.1.1
  firebase_auth: ^6.1.0
  google_sign_in: ^7.2.0
  flutter_naver_login: ^2.1.1
```

## Error Handling

**HTTP Status Codes**:
- 200: Success
- 201: Created (registration success)
- 400: Bad Request (validation error)
- 401: Unauthorized (invalid credentials or expired token)
- 403: Forbidden (account deactivated)
- 409: Conflict (duplicate email/username)
- 500: Internal Server Error

**Error Display**:
- Show user-friendly error messages via SnackBar
- Parse API error responses: `error['message']`
- Handle network errors gracefully

## Testing

**Before Testing**:
1. API server is running at `http://eng.gunsiya.com` (nginx reverse proxy)
2. Health check: `curl http://eng.gunsiya.com/health`
3. Example sentence API is confirmed working
4. Auth endpoints may need backend verification

**Test Accounts**:
- Create real accounts via registration flow
- NO mock/demo accounts allowed

## Security Considerations

1. **Token Storage**: Use `flutter_secure_storage` only
2. **Password Validation**: Enforce strong password rules
3. **HTTPS**: Use HTTPS in production (currently HTTP for local dev)
4. **Error Messages**: Don't expose sensitive information in errors
5. **Token Refresh**: Implement automatic token refresh for seamless UX

## Social Login Status

Google and Naver login buttons are displayed but currently show "not implemented" messages. Future implementation will use OAuth APIs defined in API-DOCUMENTATION.md.

## Development Workflow

1. **API First**: Always check API-DOCUMENTATION.md for endpoint specs
2. **No Mocks**: Never create mock services or fallback data
3. **Error Handling**: Implement proper try-catch with user-friendly messages
4. **Token Management**: Always handle token expiration and refresh
5. **Validation**: Match API validation rules exactly (email, username, password)

## Notes for Claude Code

- When implementing new features, ALWAYS use real API calls
- When authentication fails, show the actual error from API response
- When adding new API endpoints, update API-DOCUMENTATION.md first
- NEVER suggest or implement mock data as a temporary solution
- If API is unavailable, inform user - do NOT use mock data fallback
