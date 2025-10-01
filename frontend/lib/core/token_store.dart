import 'package:shared_preferences/shared_preferences.dart';

/// Dedicated token store for managing authentication tokens
class TokenStore {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  static SharedPreferences? _prefs;

  /// Initialize the token store
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get the authentication token
  static Future<String?> getToken() async {
    await init();
    return _prefs?.getString(_tokenKey);
  }

  /// Save the authentication token
  static Future<bool> saveToken(String token) async {
    await init();
    return await _prefs?.setString(_tokenKey, token) ?? false;
  }

  /// Get the refresh token
  static Future<String?> getRefreshToken() async {
    await init();
    return _prefs?.getString(_refreshTokenKey);
  }

  /// Save the refresh token
  static Future<bool> saveRefreshToken(String token) async {
    await init();
    return await _prefs?.setString(_refreshTokenKey, token) ?? false;
  }

  /// Save both tokens at once
  static Future<void> saveTokens({
    required String token,
    String? refreshToken,
  }) async {
    await saveToken(token);
    if (refreshToken != null) {
      await saveRefreshToken(refreshToken);
    }
  }

  /// Clear the authentication token
  static Future<bool> clearToken() async {
    await init();
    final tokenRemoved = await _prefs?.remove(_tokenKey) ?? false;
    final refreshRemoved = await _prefs?.remove(_refreshTokenKey) ?? false;
    return tokenRemoved && refreshRemoved;
  }

  /// Check if user has a valid token
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
