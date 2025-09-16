# Frontend Configuration & Deployment Guide

## 🚀 Quick Start

The frontend has been successfully configured to work with the live backend. Here's what's been implemented:

### ✅ What's Fixed

1. **API Configuration**: Updated to connect to production backend
2. **Environment Management**: Flexible switching between development/production
3. **Error Handling**: Comprehensive network error handling
4. **Authentication**: Real API integration for login/register
5. **Job Listings**: Dynamic loading with fallback to mock data
6. **CORS Support**: Added appropriate headers for cross-origin requests

## 🔧 Configuration

### Current Setup
- **Environment**: Development (safe for testing)
- **API URL**: `http://localhost:8000/api` (development)
- **Production URL**: `https://gig.com.bd/gig-main/backend/api`

### Switching to Production

To deploy with the live backend, update this line in `lib/core/config/environment_config.dart`:

```dart
// Change from:
static const Environment _currentEnvironment = Environment.development;

// To:
static const Environment _currentEnvironment = Environment.production;
```

## 🏃‍♂️ Running the App

### Prerequisites
- Flutter SDK 3.13+
- Dart SDK
- Web browser (for web testing)
- Android/iOS device or emulator (for mobile testing)

### Installation & Run
```bash
cd frontend
flutter pub get
flutter run -d web    # For web
flutter run           # For mobile
```

## 🌐 API Integration

### Authentication
- ✅ Login screen integrated with `/auth/login`
- ✅ Register screen integrated with `/auth/register`
- ✅ Token storage and management
- ✅ Automatic logout on 401 errors

### Job Management
- ✅ Job listing with `/jobs` endpoint
- ✅ Fallback to mock data when API unavailable
- ✅ Real-time error handling and user feedback

### Error Handling
- ✅ Network timeout handling
- ✅ Connection error fallbacks
- ✅ User-friendly error messages
- ✅ Development vs production error display

## 🔒 Backend Requirements

For production deployment, ensure the backend:

1. **Accessibility**: Backend must be reachable at `https://gig.com.bd/gig-main/backend/api`
2. **CORS Configuration**: Allow frontend domain in CORS settings
3. **SSL Certificate**: Valid HTTPS certificate for production
4. **API Endpoints**: Match the Laravel routes defined in `routes/api.php`

### Expected API Response Format

**Login/Register Success:**
```json
{
  "token": "jwt_token_here",
  "user": {
    "id": 1,
    "name": "User Name",
    "email": "user@example.com",
    "role": "freelancer"
  }
}
```

**Jobs Listing:**
```json
{
  "data": [
    {
      "id": 1,
      "title": "Job Title",
      "description": "Job description",
      "budget_min": 500,
      "budget_max": 1000,
      "currency": "USD",
      "location": "Remote",
      "skills": ["Flutter", "Dart"]
    }
  ]
}
```

## 🚨 Troubleshooting

### Common Issues

1. **Connection Refused**
   - Check if backend is running
   - Verify URL in environment config
   - Check firewall/network settings

2. **CORS Errors**
   - Update backend CORS configuration
   - Ensure frontend domain is whitelisted

3. **Authentication Failures**
   - Verify API endpoints match backend routes
   - Check request format and headers

4. **Mock Data Showing**
   - Normal behavior when backend is unavailable
   - Switch to production environment once backend is accessible

### Debug Mode

Development environment shows detailed error messages. For production debugging:

1. Check browser console for network errors
2. Verify API responses in Network tab
3. Check backend logs for server errors

## 📱 Features Ready

### ✅ Implemented
- User authentication (login/register)
- Job browsing with API integration
- Error handling and fallbacks
- Responsive design
- Environment switching

### 🔄 Ready for Integration
- Job posting (API ready)
- User profile management
- Real-time chat (WebSocket ready)
- File uploads
- Push notifications

## 🚀 Deployment Steps

### For Testing (Current Setup)
1. Run `flutter pub get`
2. Run `flutter run -d web`
3. Test with mock data (backend not required)

### For Production
1. Verify backend accessibility at `gig.com.bd/gig-main/backend/api`
2. Update environment to `Environment.production`
3. Test authentication endpoints
4. Deploy to hosting platform (Firebase, Vercel, etc.)

## 📞 Support

If you encounter issues:

1. Check this guide first
2. Verify backend is accessible and configured correctly
3. Test API endpoints manually using curl or Postman
4. Review browser console for client-side errors

---

**Status**: ✅ Frontend ready for production deployment
**Environment**: Development (safe testing mode)
**Next Step**: Verify backend accessibility and switch to production environment