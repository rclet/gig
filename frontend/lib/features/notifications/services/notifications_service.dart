import '../../../core/api_client.dart';

/// Notifications service for handling notification-related API calls
class NotificationsService {
  /// Get all notifications
  /// GET /api/notifications
  static Future<Map<String, dynamic>> getNotifications({
    int? page,
    int? perPage,
    bool? unreadOnly,
  }) async {
    final queryParameters = <String, dynamic>{};
    
    if (page != null) queryParameters['page'] = page;
    if (perPage != null) queryParameters['per_page'] = perPage;
    if (unreadOnly != null) queryParameters['unread_only'] = unreadOnly;

    final response = await ApiClient.get(
      '/notifications',
      queryParameters: queryParameters,
    );
    return response.data as Map<String, dynamic>;
  }

  /// Mark all notifications as read
  /// POST /api/notifications/mark-all-read
  static Future<Map<String, dynamic>> markAllAsRead() async {
    final response = await ApiClient.post('/notifications/mark-all-read');
    return response.data as Map<String, dynamic>;
  }

  /// Mark a notification as read
  /// PUT /api/notifications/{notification}/read
  static Future<Map<String, dynamic>> markAsRead({
    required String notificationId,
  }) async {
    final response = await ApiClient.put(
      '/notifications/$notificationId/read',
    );
    return response.data as Map<String, dynamic>;
  }

  /// Delete a notification
  /// DELETE /api/notifications/{notification}
  static Future<Map<String, dynamic>> deleteNotification({
    required String notificationId,
  }) async {
    final response = await ApiClient.delete(
      '/notifications/$notificationId',
    );
    return response.data as Map<String, dynamic>;
  }
}
