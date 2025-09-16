# Frontend Configuration Guide

## API Configuration

The frontend has been updated to connect to the live backend at `https://gig.com.bd/gig-main/backend/api`. 

### Environment Configuration

The app uses an environment-based configuration system located in:
```
lib/core/config/environment_config.dart
```

### Switching Between Environments

To change the API endpoints, modify the `_currentEnvironment` constant in `environment_config.dart`:

```dart
// For development (localhost)
static const Environment _currentEnvironment = Environment.development;

// For production (live backend)
static const Environment _currentEnvironment = Environment.production;
```

### Environment URLs

1. **Development** (localhost):
   - API: `http://localhost:8000/api`
   - Socket: `http://localhost:8000`

2. **Production** (live backend):
   - API: `https://gig.com.bd/gig-main/backend/api`
   - Socket: `https://gig.com.bd/gig-main/backend`

### Key Changes Made

1. **Updated API Configuration**: Changed from localhost to production URL
2. **Improved Error Handling**: Added comprehensive error handling for network issues
3. **Better API Service**: Created robust API service with consistent error responses
4. **CORS Headers**: Added appropriate headers for cross-origin requests
5. **Environment Management**: Created flexible environment switching system

### Testing the Connection

The app will now attempt to connect to the live backend. If there are connectivity issues:

1. Check if the backend is accessible at the configured URL
2. Verify CORS settings on the backend
3. Ensure the API endpoints match the Laravel routes
4. Switch to development mode for local testing if needed

### Backend Requirements

For the frontend to work properly, the backend should:

1. Be accessible at `https://gig.com.bd/gig-main/backend/api`
2. Have CORS configured to allow requests from the frontend domain
3. Return JSON responses in the expected format:
   ```json
   {
     "token": "jwt_token_here",
     "user": {
       "id": 1,
       "name": "User Name",
       "email": "user@example.com"
     }
   }
   ```

### Deployment Notes

- The environment is currently set to **development** mode to avoid connection issues during testing
- To deploy to production, change `_currentEnvironment` to `Environment.production`
- Ensure the backend is properly configured and accessible before switching to production mode
- Test API connectivity using the health check endpoint

### Troubleshooting

If the app shows connection errors:

1. **Network Issues**: Check internet connectivity and firewall settings
2. **Backend Down**: Verify the backend server is running and accessible
3. **CORS Issues**: Ensure backend CORS settings allow the frontend domain
4. **SSL Issues**: Verify SSL certificates are properly configured for HTTPS
5. **Wrong Environment**: Double-check the environment configuration

### Files Modified

- `lib/core/config/environment_config.dart` - Environment configuration
- `lib/core/constants/app_constants.dart` - API constants
- `lib/core/services/api_service.dart` - API service with error handling
- `lib/features/auth/screens/login_screen.dart` - Updated login with real API
- `lib/features/auth/screens/register_screen.dart` - Updated registration with real API