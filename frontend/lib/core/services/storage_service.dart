import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static late SharedPreferences _prefs;
  static late Box _box;
  
  static const String _authTokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language';
  static const String _onboardingKey = 'onboarding_completed';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await Hive.initFlutter();
    _box = await Hive.openBox('gig_marketplace');
  }

  // Authentication Token
  static Future<void> setAuthToken(String token) async {
    await _prefs.setString(_authTokenKey, token);
  }

  static String? getAuthToken() {
    return _prefs.getString(_authTokenKey);
  }

  static Future<void> removeAuthToken() async {
    await _prefs.remove(_authTokenKey);
  }

  // User Data
  static Future<void> setUserData(Map<String, dynamic> userData) async {
    await _box.put(_userDataKey, userData);
  }

  static Map<String, dynamic>? getUserData() {
    final data = _box.get(_userDataKey);
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  static Future<void> removeUserData() async {
    await _box.delete(_userDataKey);
  }

  // Theme
  static Future<void> setThemeMode(String themeMode) async {
    await _prefs.setString(_themeKey, themeMode);
  }

  static String getThemeMode() {
    return _prefs.getString(_themeKey) ?? 'system';
  }

  // Language
  static Future<void> setLanguage(String language) async {
    await _prefs.setString(_languageKey, language);
  }

  static String getLanguage() {
    return _prefs.getString(_languageKey) ?? 'en';
  }

  // Onboarding
  static Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs.setBool(_onboardingKey, completed);
  }

  static bool isOnboardingCompleted() {
    return _prefs.getBool(_onboardingKey) ?? false;
  }

  // Cache Management
  static Future<void> cacheData(String key, dynamic data) async {
    await _box.put(key, data);
  }

  static T? getCachedData<T>(String key) {
    return _box.get(key);
  }

  static Future<void> removeCachedData(String key) async {
    await _box.delete(key);
  }

  static Future<void> clearCache() async {
    await _box.clear();
  }

  // Clear all data (for logout)
  static Future<void> clearAll() async {
    await removeAuthToken();
    await removeUserData();
    await clearCache();
  }
}