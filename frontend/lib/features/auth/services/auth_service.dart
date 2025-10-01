import '../../../core/api_client.dart';
import '../../../core/token_store.dart';
import '../../../core/services/storage_service.dart';

/// Authentication service for handling all auth-related API calls
class AuthService {
  /// Login with email and password
  /// POST /api/auth/login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data as Map<String, dynamic>;
    
    // Save token if present
    if (data.containsKey('token')) {
      await TokenStore.saveToken(data['token']);
    }
    if (data.containsKey('access_token')) {
      await TokenStore.saveToken(data['access_token']);
    }
    
    // Save user data if present
    if (data.containsKey('user')) {
      await StorageService.setUserData(data['user']);
    }

    return data;
  }

  /// Logout the current user
  /// POST /api/auth/logout
  static Future<Map<String, dynamic>> logout() async {
    final response = await ApiClient.post('/auth/logout');
    
    // Clear local storage
    await TokenStore.clearToken();
    await StorageService.clearAll();
    
    return response.data as Map<String, dynamic>;
  }

  /// Get current user information
  /// GET /api/auth/me
  static Future<Map<String, dynamic>> me() async {
    final response = await ApiClient.get('/auth/me');
    
    final data = response.data as Map<String, dynamic>;
    
    // Update stored user data
    if (data.containsKey('user')) {
      await StorageService.setUserData(data['user']);
    } else {
      // If the response itself is the user object
      await StorageService.setUserData(data);
    }
    
    return data;
  }

  /// Refresh authentication token
  /// POST /api/auth/refresh
  static Future<Map<String, dynamic>> refresh() async {
    final response = await ApiClient.post('/auth/refresh');
    
    final data = response.data as Map<String, dynamic>;
    
    // Update token if present
    if (data.containsKey('token')) {
      await TokenStore.saveToken(data['token']);
    }
    if (data.containsKey('access_token')) {
      await TokenStore.saveToken(data['access_token']);
    }
    
    return data;
  }

  /// Verify email address
  /// POST /api/auth/verify-email
  static Future<Map<String, dynamic>> verifyEmail({
    required String token,
  }) async {
    final response = await ApiClient.post(
      '/auth/verify-email',
      data: {'token': token},
    );
    
    return response.data as Map<String, dynamic>;
  }

  /// Resend verification email
  /// POST /api/auth/resend-verification
  static Future<Map<String, dynamic>> resendVerification() async {
    final response = await ApiClient.post('/auth/resend-verification');
    return response.data as Map<String, dynamic>;
  }

  /// Enable two-factor authentication
  /// POST /api/auth/enable-2fa
  static Future<Map<String, dynamic>> enableTwoFactor() async {
    final response = await ApiClient.post('/auth/enable-2fa');
    return response.data as Map<String, dynamic>;
  }

  /// Disable two-factor authentication
  /// POST /api/auth/disable-2fa
  static Future<Map<String, dynamic>> disableTwoFactor({
    required String code,
  }) async {
    final response = await ApiClient.post(
      '/auth/disable-2fa',
      data: {'code': code},
    );
    return response.data as Map<String, dynamic>;
  }

  /// Social login (Google, Facebook, LinkedIn)
  /// POST /api/auth/social-login
  static Future<Map<String, dynamic>> socialLogin({
    required String provider,
    required String token,
  }) async {
    final response = await ApiClient.post(
      '/auth/social-login',
      data: {
        'provider': provider,
        'token': token,
      },
    );

    final data = response.data as Map<String, dynamic>;
    
    // Save token if present
    if (data.containsKey('token')) {
      await TokenStore.saveToken(data['token']);
    }
    if (data.containsKey('access_token')) {
      await TokenStore.saveToken(data['access_token']);
    }
    
    // Save user data if present
    if (data.containsKey('user')) {
      await StorageService.setUserData(data['user']);
    }

    return data;
  }

  /// Register a new user
  /// POST /api/auth/register
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await ApiClient.post(
      '/auth/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );

    final data = response.data as Map<String, dynamic>;
    
    // Save token if present
    if (data.containsKey('token')) {
      await TokenStore.saveToken(data['token']);
    }
    if (data.containsKey('access_token')) {
      await TokenStore.saveToken(data['access_token']);
    }
    
    // Save user data if present
    if (data.containsKey('user')) {
      await StorageService.setUserData(data['user']);
    }

    return data;
  }

  /// Request password reset
  /// POST /api/auth/forgot-password
  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    final response = await ApiClient.post(
      '/auth/forgot-password',
      data: {'email': email},
    );
    return response.data as Map<String, dynamic>;
  }

  /// Reset password with token
  /// POST /api/auth/reset-password
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await ApiClient.post(
      '/auth/reset-password',
      data: {
        'email': email,
        'token': token,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}
