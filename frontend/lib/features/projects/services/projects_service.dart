import '../../../core/api_client.dart';

/// Projects service for handling project-related API calls
class ProjectsService {
  /// Get all projects
  /// GET /api/projects
  static Future<Map<String, dynamic>> getProjects({
    int? page,
    int? perPage,
    String? status,
  }) async {
    final queryParameters = <String, dynamic>{};
    
    if (page != null) queryParameters['page'] = page;
    if (perPage != null) queryParameters['per_page'] = perPage;
    if (status != null) queryParameters['status'] = status;

    final response = await ApiClient.get(
      '/projects',
      queryParameters: queryParameters,
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get project details
  /// GET /api/projects/{project}
  static Future<Map<String, dynamic>> getProject(String projectId) async {
    final response = await ApiClient.get('/projects/$projectId');
    return response.data as Map<String, dynamic>;
  }

  /// Update project details
  /// PUT /api/projects/{project}
  static Future<Map<String, dynamic>> updateProject({
    required String projectId,
    String? title,
    String? description,
    String? status,
    Map<String, dynamic>? additionalData,
  }) async {
    final data = <String, dynamic>{};

    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (status != null) data['status'] = status;
    if (additionalData != null) data.addAll(additionalData);

    final response = await ApiClient.put(
      '/projects/$projectId',
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  /// Cancel a project
  /// POST /api/projects/{project}/cancel
  static Future<Map<String, dynamic>> cancelProject({
    required String projectId,
    String? reason,
  }) async {
    final data = <String, dynamic>{};
    if (reason != null) data['reason'] = reason;

    final response = await ApiClient.post(
      '/projects/$projectId/cancel',
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  /// Complete a project
  /// POST /api/projects/{project}/complete
  static Future<Map<String, dynamic>> completeProject({
    required String projectId,
    String? notes,
  }) async {
    final data = <String, dynamic>{};
    if (notes != null) data['notes'] = notes;

    final response = await ApiClient.post(
      '/projects/$projectId/complete',
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get project messages
  /// GET /api/projects/{project}/messages
  static Future<Map<String, dynamic>> getMessages({
    required String projectId,
    int? page,
    int? perPage,
  }) async {
    final queryParameters = <String, dynamic>{};
    
    if (page != null) queryParameters['page'] = page;
    if (perPage != null) queryParameters['per_page'] = perPage;

    final response = await ApiClient.get(
      '/projects/$projectId/messages',
      queryParameters: queryParameters,
    );
    return response.data as Map<String, dynamic>;
  }

  /// Send a message in a project
  /// POST /api/projects/{project}/messages
  static Future<Map<String, dynamic>> sendMessage({
    required String projectId,
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
      '/projects/$projectId/messages',
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  /// Rate a project
  /// POST /api/projects/{project}/rate
  static Future<Map<String, dynamic>> rateProject({
    required String projectId,
    required double rating,
    String? review,
  }) async {
    final data = <String, dynamic>{
      'rating': rating,
    };

    if (review != null) data['review'] = review;

    final response = await ApiClient.post(
      '/projects/$projectId/rate',
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }
}
