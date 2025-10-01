import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../../../core/error_mapper.dart';

/// Auth state
class AuthState {
  final Map<String, dynamic>? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    Map<String, dynamic>? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Auth provider
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  /// Login with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await AuthService.login(
        email: email,
        password: password,
      );
      
      state = state.copyWith(
        user: result['user'] ?? result,
        isAuthenticated: true,
        isLoading: false,
      );
      
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await AuthService.logout();
      state = const AuthState();
    } on ApiException catch (e) {
      // Even if logout fails on server, clear local state
      state = const AuthState(error: e.message);
    }
  }

  /// Get current user
  Future<bool> getCurrentUser() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await AuthService.me();
      
      state = state.copyWith(
        user: result['user'] ?? result,
        isAuthenticated: true,
        isLoading: false,
      );
      
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: e.message,
      );
      return false;
    }
  }

  /// Refresh token
  Future<bool> refreshToken() async {
    try {
      await AuthService.refresh();
      return true;
    } on ApiException {
      return false;
    }
  }

  /// Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await AuthService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      
      state = state.copyWith(
        user: result['user'] ?? result,
        isAuthenticated: true,
        isLoading: false,
      );
      
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return false;
    }
  }

  /// Social login
  Future<bool> socialLogin({
    required String provider,
    required String token,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await AuthService.socialLogin(
        provider: provider,
        token: token,
      );
      
      state = state.copyWith(
        user: result['user'] ?? result,
        isAuthenticated: true,
        isLoading: false,
      );
      
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Auth provider instance
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
