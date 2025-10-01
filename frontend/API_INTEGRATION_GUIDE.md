# Flutter Frontend API Integration Guide

This guide explains how to use the API services in the gig marketplace Flutter frontend.

## Overview

The frontend has been structured to consume all 61+ backend API endpoints across these features:
- **Auth**: 13 endpoints (login, logout, register, 2FA, social login, etc.)
- **Users**: 5 endpoints (profile, dashboard, analytics, avatar)
- **Jobs**: 10 endpoints (CRUD, search, bookmark, my-jobs)
- **Chat**: 5 endpoints (conversations, messages, read status)
- **Projects**: 8 endpoints (CRUD, messages, rate, complete, cancel)
- **Proposals**: 8 endpoints (CRUD, accept, reject, my-proposals)
- **Notifications**: 4 endpoints (list, read, mark all read, delete)

## Core Architecture

### API Client (`lib/core/api_client.dart`)
Enhanced Dio-based HTTP client with:
- Automatic token injection via interceptors
- Error mapping to typed exceptions
- Support for `--dart-define=API_BASE` for flexible environment configuration
- Automatic 401 handling (clears tokens)
- Request/response logging in development mode

### Token Store (`lib/core/token_store.dart`)
Secure token management using SharedPreferences:
```dart
// Save token
await TokenStore.saveToken(token);

// Get token
final token = await TokenStore.getToken();

// Check if has token
final hasToken = await TokenStore.hasToken();

// Clear token
await TokenStore.clearToken();
```

### Error Mapper (`lib/core/error_mapper.dart`)
Maps HTTP errors to typed exceptions:
- `ValidationException` (422) - with field-level error extraction
- `UnauthorizedException` (401)
- `ForbiddenException` (403)
- `NotFoundException` (404)
- `ServerException` (500)
- `NetworkException` (connection errors)
- `TimeoutException` (timeouts)

## Usage Examples

### Authentication

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/providers/auth_provider.dart';

// In a ConsumerWidget or ConsumerStatefulWidget
final authNotifier = ref.read(authProvider.notifier);

// Login
final success = await authNotifier.login(
  email: 'user@example.com',
  password: 'password123',
);

// Logout
await authNotifier.logout();

// Get current user
await authNotifier.getCurrentUser();

// Register
await authNotifier.register(
  name: 'John Doe',
  email: 'john@example.com',
  password: 'password123',
  passwordConfirmation: 'password123',
);
```

### Jobs

```dart
import '../features/jobs/services/jobs_service.dart';

// Get all jobs
final jobs = await JobsService.getJobs(page: 1, perPage: 20);

// Search jobs
final results = await JobsService.searchJobs(
  query: 'Flutter developer',
  minBudget: 100,
  maxBudget: 1000,
);

// Get job details
final job = await JobsService.getJob('job-id-123');

// Create a job
final newJob = await JobsService.createJob(
  title: 'Need a Flutter developer',
  description: 'Building a mobile app',
  categoryId: 'cat-123',
  budget: 500.0,
  budgetType: 'fixed',
);

// Bookmark a job
await JobsService.bookmarkJob('job-id-123');

// Get my jobs
final myJobs = await JobsService.getMyJobs();
```

### Chat

```dart
import '../features/chat/services/chat_service.dart';

// Get conversations
final conversations = await ChatService.getConversations();

// Create conversation
final newConversation = await ChatService.createConversation(
  userId: 'user-123',
  message: 'Hello!',
);

// Send message
await ChatService.sendMessage(
  conversationId: 'conv-123',
  message: 'Hi there!',
);

// Mark as read
await ChatService.markAsRead(conversationId: 'conv-123');
```

### Projects

```dart
import '../features/projects/services/projects_service.dart';

// Get projects
final projects = await ProjectsService.getProjects(status: 'active');

// Complete project
await ProjectsService.completeProject(
  projectId: 'proj-123',
  notes: 'Project completed successfully',
);

// Rate project
await ProjectsService.rateProject(
  projectId: 'proj-123',
  rating: 5.0,
  review: 'Excellent work!',
);

// Send message in project
await ProjectsService.sendMessage(
  projectId: 'proj-123',
  message: 'Great progress!',
);
```

### Proposals

```dart
import '../features/proposals/services/proposals_service.dart';

// Create proposal
final proposal = await ProposalsService.createProposal(
  jobId: 'job-123',
  coverLetter: 'I am interested in this project...',
  bidAmount: 450.0,
  deliveryTime: 7,
);

// Get my proposals
final myProposals = await ProposalsService.getMyProposals();

// Accept proposal (job owner)
await ProposalsService.acceptProposal(
  proposalId: 'prop-123',
  message: 'Looking forward to working with you!',
);

// Update proposal
await ProposalsService.updateProposal(
  proposalId: 'prop-123',
  bidAmount: 400.0,
);
```

### Notifications

```dart
import '../features/notifications/services/notifications_service.dart';

// Get notifications
final notifications = await NotificationsService.getNotifications(
  unreadOnly: true,
);

// Mark as read
await NotificationsService.markAsRead(
  notificationId: 'notif-123',
);

// Mark all as read
await NotificationsService.markAllAsRead();

// Delete notification
await NotificationsService.deleteNotification(
  notificationId: 'notif-123',
);
```

### Users

```dart
import '../features/users/services/users_service.dart';

// Get dashboard
final dashboard = await UsersService.getDashboard();

// Get profile
final profile = await UsersService.getProfile();

// Update profile
await UsersService.updateProfile(
  name: 'John Doe',
  bio: 'Experienced Flutter developer',
  skills: ['Flutter', 'Dart', 'Firebase'],
);

// Upload avatar
await UsersService.uploadAvatar(filePath: '/path/to/image.jpg');

// Get analytics
final analytics = await UsersService.getAnalytics();
```

## Error Handling

All services throw typed exceptions that can be caught and handled:

```dart
import '../core/error_mapper.dart';

try {
  final jobs = await JobsService.getJobs();
  // Handle success
} on ValidationException catch (e) {
  // Handle validation errors (422)
  final errors = e.errors; // Map<String, List<String>>
  final firstError = e.getFirstFieldError('title');
  final allErrors = e.getAllErrorsAsString();
} on UnauthorizedException catch (e) {
  // Handle 401 - user needs to login
  context.go('/login');
} on ForbiddenException catch (e) {
  // Handle 403 - user doesn't have permission
} on NotFoundException catch (e) {
  // Handle 404 - resource not found
} on ServerException catch (e) {
  // Handle 500 - server error
} on NetworkException catch (e) {
  // Handle network errors
} on ApiException catch (e) {
  // Handle any other API exception
  print(e.message);
}
```

## Environment Configuration

### Using --dart-define for API Base URL

```bash
# Development
flutter run --dart-define=API_BASE=http://localhost:8000/api

# Staging
flutter run --dart-define=API_BASE=https://staging.gig.com.bd/api

# Production
flutter run --dart-define=API_BASE=https://gig.com.bd/gig-main/backend/api

# Build APK
flutter build apk --dart-define=API_BASE=https://gig.com.bd/gig-main/backend/api

# Build iOS
flutter build ios --dart-define=API_BASE=https://gig.com.bd/gig-main/backend/api
```

If `API_BASE` is not provided, it falls back to the environment configured in `lib/core/config/environment_config.dart`.

## Authentication Flow

1. **App Startup**: 
   - Splash screen checks for token using `TokenStore.hasToken()`
   - If token exists, calls `GET /api/auth/me` to validate
   - Redirects to `/home` on success, `/login` on failure

2. **Login**:
   - User enters credentials
   - Calls `POST /api/auth/login`
   - Saves token to `TokenStore`
   - Saves user data to `StorageService`
   - Redirects to `/home`

3. **Protected Routes**:
   - Router checks token in `redirect` callback
   - Redirects to `/login` if no token
   - API calls automatically include token via interceptor

4. **Token Expiry**:
   - 401 response triggers auto-logout
   - Token cleared from storage
   - User redirected to login

5. **Logout**:
   - Calls `POST /api/auth/logout`
   - Clears token from storage
   - Redirects to `/login`

## State Management

Uses Riverpod for state management:

```dart
// Auth state
final authState = ref.watch(authProvider);
final isAuthenticated = authState.isAuthenticated;
final currentUser = authState.user;
final isLoading = authState.isLoading;
final error = authState.error;

// Trigger actions
ref.read(authProvider.notifier).login(...);
ref.read(authProvider.notifier).logout();
```

## Testing

All services can be tested independently:

```dart
import 'package:flutter_test/flutter_test.dart';
import '../features/jobs/services/jobs_service.dart';

void main() {
  test('Should fetch jobs', () async {
    final result = await JobsService.getJobs();
    expect(result, isNotNull);
    expect(result['data'], isList);
  });
}
```

## Build Commands

```bash
# Run tests
flutter test

# Build Android APK (release)
flutter build apk --release --dart-define=API_BASE=https://gig.com.bd/gig-main/backend/api

# Build iOS (release)
flutter build ios --release --dart-define=API_BASE=https://gig.com.bd/gig-main/backend/api

# Build web
flutter build web --dart-define=API_BASE=https://gig.com.bd/gig-main/backend/api
```

## Summary

✅ All 61+ backend endpoints are now accessible through dedicated service classes
✅ Type-safe error handling with specific exception types
✅ Centralized authentication with token management
✅ Auth guards on protected routes
✅ Support for multiple environments via --dart-define
✅ Clean separation of concerns (services, providers, UI)
✅ Consistent API across all features
