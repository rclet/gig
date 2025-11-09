import '../../../core/api_client.dart';

/// Chat service for handling chat and messaging API calls
class ChatService {
  /// Get all conversations
  /// GET /api/chat/conversations
  static Future<Map<String, dynamic>> getConversations({
    int? page,
    int? perPage,
  }) async {
    final queryParameters = <String, dynamic>{};
    
    if (page != null) queryParameters['page'] = page;
    if (perPage != null) queryParameters['per_page'] = perPage;

    final response = await ApiClient.get(
      '/chat/conversations',
      queryParameters: queryParameters,
    );
    return response.data as Map<String, dynamic>;
  }

  /// Create a new conversation
  /// POST /api/chat/conversations
  static Future<Map<String, dynamic>> createConversation({
    required String userId,
    String? message,
  }) async {
    final data = <String, dynamic>{
      'user_id': userId,
    };

    if (message != null) data['message'] = message;

    final response = await ApiClient.post(
      '/chat/conversations',
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get conversation details with messages
  /// GET /api/chat/conversations/{conversation}
  static Future<Map<String, dynamic>> getConversation({
    required String conversationId,
    int? page,
    int? perPage,
  }) async {
    final queryParameters = <String, dynamic>{};
    
    if (page != null) queryParameters['page'] = page;
    if (perPage != null) queryParameters['per_page'] = perPage;

    final response = await ApiClient.get(
      '/chat/conversations/$conversationId',
      queryParameters: queryParameters,
    );
    return response.data as Map<String, dynamic>;
  }

  /// Send a message in a conversation
  /// POST /api/chat/conversations/{conversation}/messages
  static Future<Map<String, dynamic>> sendMessage({
    required String conversationId,
    required String message,
    String? type,
    Map<String, dynamic>? metadata,
  }) async {
    final data = <String, dynamic>{
      'message': message,
    };

    if (type != null) data['type'] = type;
    if (metadata != null) data['metadata'] = metadata;

    final response = await ApiClient.post(
      '/chat/conversations/$conversationId/messages',
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  /// Mark conversation as read
  /// PUT /api/chat/conversations/{conversation}/read
  static Future<Map<String, dynamic>> markAsRead({
    required String conversationId,
  }) async {
    final response = await ApiClient.put(
      '/chat/conversations/$conversationId/read',
    );
    return response.data as Map<String, dynamic>;
  }
}
