import '../../../core/api_client.dart';

/// Users service for handling user-related API calls
class UsersService {
  /// Get user dashboard data
  /// GET /api/users/dashboard
  static Future<Map<String, dynamic>> getDashboard() async {
    final response = await ApiClient.get('/users/dashboard');
    return response.data as Map<String, dynamic>;
  }

  /// Get user profile
  /// GET /api/users/profile
  static Future<Map<String, dynamic>> getProfile() async {
    final response = await ApiClient.get('/users/profile');
    return response.data as Map<String, dynamic>;
  }

  /// Update user profile
  /// PUT /api/users/profile
  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? bio,
    String? location,
    String? website,
    List<String>? skills,
    Map<String, dynamic>? additionalData,
  }) async {
    final data = <String, dynamic>{};
    
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (phone != null) data['phone'] = phone;
    if (bio != null) data['bio'] = bio;
    if (location != null) data['location'] = location;
    if (website != null) data['website'] = website;
    if (skills != null) data['skills'] = skills;
    if (additionalData != null) data.addAll(additionalData);

    final response = await ApiClient.put(
      '/users/profile',
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  /// Upload user avatar
  /// POST /api/users/avatar
  static Future<Map<String, dynamic>> uploadAvatar({
    required String filePath,
  }) async {
    final response = await ApiClient.uploadFile(
      '/users/avatar',
      filePath,
      'avatar',
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get user analytics
  /// GET /api/users/analytics
  static Future<Map<String, dynamic>> getAnalytics() async {
    final response = await ApiClient.get('/users/analytics');
    return response.data as Map<String, dynamic>;
  }
}
