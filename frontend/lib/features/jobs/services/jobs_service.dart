import '../../../core/api_client.dart';

/// Jobs service for handling job-related API calls
class JobsService {
  /// Get list of jobs with optional filters
  /// GET /api/jobs
  static Future<Map<String, dynamic>> getJobs({
    int? page,
    int? perPage,
    String? category,
    String? status,
    Map<String, dynamic>? filters,
  }) async {
    final queryParameters = <String, dynamic>{};
    
    if (page != null) queryParameters['page'] = page;
    if (perPage != null) queryParameters['per_page'] = perPage;
    if (category != null) queryParameters['category'] = category;
    if (status != null) queryParameters['status'] = status;
    if (filters != null) queryParameters.addAll(filters);

    final response = await ApiClient.get(
      '/jobs',
      queryParameters: queryParameters,
    );
    return response.data as Map<String, dynamic>;
  }

  /// Create a new job
  /// POST /api/jobs
  static Future<Map<String, dynamic>> createJob({
    required String title,
    required String description,
    required String categoryId,
    required double budget,
    required String budgetType,
    String? duration,
    List<String>? skills,
    Map<String, dynamic>? additionalData,
  }) async {
    final data = <String, dynamic>{
      'title': title,
      'description': description,
      'category_id': categoryId,
      'budget': budget,
      'budget_type': budgetType,
    };

    if (duration != null) data['duration'] = duration;
    if (skills != null) data['skills'] = skills;
    if (additionalData != null) data.addAll(additionalData);

    final response = await ApiClient.post('/jobs', data: data);
    return response.data as Map<String, dynamic>;
  }

  /// Search jobs
  /// GET /api/jobs/search
  static Future<Map<String, dynamic>> searchJobs({
    required String query,
    String? category,
    double? minBudget,
    double? maxBudget,
    List<String>? skills,
    int? page,
    int? perPage,
  }) async {
    final queryParameters = <String, dynamic>{
      'q': query,
    };

    if (category != null) queryParameters['category'] = category;
    if (minBudget != null) queryParameters['min_budget'] = minBudget;
    if (maxBudget != null) queryParameters['max_budget'] = maxBudget;
    if (skills != null) queryParameters['skills'] = skills.join(',');
    if (page != null) queryParameters['page'] = page;
    if (perPage != null) queryParameters['per_page'] = perPage;

    final response = await ApiClient.get(
      '/jobs/search',
      queryParameters: queryParameters,
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get user's jobs
  /// GET /api/jobs/my-jobs
  static Future<Map<String, dynamic>> getMyJobs({
    int? page,
    int? perPage,
    String? status,
  }) async {
    final queryParameters = <String, dynamic>{};
    
    if (page != null) queryParameters['page'] = page;
    if (perPage != null) queryParameters['per_page'] = perPage;
    if (status != null) queryParameters['status'] = status;

    final response = await ApiClient.get(
      '/jobs/my-jobs',
      queryParameters: queryParameters,
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get job details
  /// GET /api/jobs/{job}
  static Future<Map<String, dynamic>> getJob(String jobId) async {
    final response = await ApiClient.get('/jobs/$jobId');
    return response.data as Map<String, dynamic>;
  }

  /// Update a job
  /// PUT /api/jobs/{job}
  static Future<Map<String, dynamic>> updateJob({
    required String jobId,
    String? title,
    String? description,
    String? categoryId,
    double? budget,
    String? budgetType,
    String? duration,
    String? status,
    List<String>? skills,
    Map<String, dynamic>? additionalData,
  }) async {
    final data = <String, dynamic>{};

    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (categoryId != null) data['category_id'] = categoryId;
    if (budget != null) data['budget'] = budget;
    if (budgetType != null) data['budget_type'] = budgetType;
    if (duration != null) data['duration'] = duration;
    if (status != null) data['status'] = status;
    if (skills != null) data['skills'] = skills;
    if (additionalData != null) data.addAll(additionalData);

    final response = await ApiClient.put('/jobs/$jobId', data: data);
    return response.data as Map<String, dynamic>;
  }

  /// Delete a job
  /// DELETE /api/jobs/{job}
  static Future<Map<String, dynamic>> deleteJob(String jobId) async {
    final response = await ApiClient.delete('/jobs/$jobId');
    return response.data as Map<String, dynamic>;
  }

  /// Bookmark a job
  /// POST /api/jobs/{job}/bookmark
  static Future<Map<String, dynamic>> bookmarkJob(String jobId) async {
    final response = await ApiClient.post('/jobs/$jobId/bookmark');
    return response.data as Map<String, dynamic>;
  }

  /// Remove bookmark from a job
  /// DELETE /api/jobs/{job}/bookmark
  static Future<Map<String, dynamic>> removeBookmark(String jobId) async {
    final response = await ApiClient.delete('/jobs/$jobId/bookmark');
    return response.data as Map<String, dynamic>;
  }

  /// Get bookmarked jobs
  /// GET /api/jobs/bookmarked
  static Future<Map<String, dynamic>> getBookmarkedJobs({
    int? page,
    int? perPage,
  }) async {
    final queryParameters = <String, dynamic>{};
    
    if (page != null) queryParameters['page'] = page;
    if (perPage != null) queryParameters['per_page'] = perPage;

    final response = await ApiClient.get(
      '/jobs/bookmarked',
      queryParameters: queryParameters,
    );
    return response.data as Map<String, dynamic>;
  }
}
