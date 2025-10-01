import '../../../core/api_client.dart';

/// Proposals service for handling proposal-related API calls
class ProposalsService {
  /// Create a new proposal for a job
  /// POST /api/proposals
  static Future<Map<String, dynamic>> createProposal({
    required String jobId,
    required String coverLetter,
    required double bidAmount,
    required int deliveryTime,
    Map<String, dynamic>? additionalData,
  }) async {
    final data = <String, dynamic>{
      'job_id': jobId,
      'cover_letter': coverLetter,
      'bid_amount': bidAmount,
      'delivery_time': deliveryTime,
    };

    if (additionalData != null) data.addAll(additionalData);

    final response = await ApiClient.post('/proposals', data: data);
    return response.data as Map<String, dynamic>;
  }

  /// Get user's proposals
  /// GET /api/proposals/my-proposals
  static Future<Map<String, dynamic>> getMyProposals({
    int? page,
    int? perPage,
    String? status,
  }) async {
    final queryParameters = <String, dynamic>{};
    
    if (page != null) queryParameters['page'] = page;
    if (perPage != null) queryParameters['per_page'] = perPage;
    if (status != null) queryParameters['status'] = status;

    final response = await ApiClient.get(
      '/proposals/my-proposals',
      queryParameters: queryParameters,
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get proposals for a specific job
  /// GET /api/proposals/job/{job}
  static Future<Map<String, dynamic>> getJobProposals({
    required String jobId,
    int? page,
    int? perPage,
  }) async {
    final queryParameters = <String, dynamic>{};
    
    if (page != null) queryParameters['page'] = page;
    if (perPage != null) queryParameters['per_page'] = perPage;

    final response = await ApiClient.get(
      '/proposals/job/$jobId',
      queryParameters: queryParameters,
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get proposal details
  /// GET /api/proposals/{proposal}
  static Future<Map<String, dynamic>> getProposal(String proposalId) async {
    final response = await ApiClient.get('/proposals/$proposalId');
    return response.data as Map<String, dynamic>;
  }

  /// Update a proposal
  /// PUT /api/proposals/{proposal}
  static Future<Map<String, dynamic>> updateProposal({
    required String proposalId,
    String? coverLetter,
    double? bidAmount,
    int? deliveryTime,
    Map<String, dynamic>? additionalData,
  }) async {
    final data = <String, dynamic>{};

    if (coverLetter != null) data['cover_letter'] = coverLetter;
    if (bidAmount != null) data['bid_amount'] = bidAmount;
    if (deliveryTime != null) data['delivery_time'] = deliveryTime;
    if (additionalData != null) data.addAll(additionalData);

    final response = await ApiClient.put(
      '/proposals/$proposalId',
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  /// Delete a proposal
  /// DELETE /api/proposals/{proposal}
  static Future<Map<String, dynamic>> deleteProposal(String proposalId) async {
    final response = await ApiClient.delete('/proposals/$proposalId');
    return response.data as Map<String, dynamic>;
  }

  /// Accept a proposal
  /// POST /api/proposals/{proposal}/accept
  static Future<Map<String, dynamic>> acceptProposal({
    required String proposalId,
    String? message,
  }) async {
    final data = <String, dynamic>{};
    if (message != null) data['message'] = message;

    final response = await ApiClient.post(
      '/proposals/$proposalId/accept',
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  /// Reject a proposal
  /// POST /api/proposals/{proposal}/reject
  static Future<Map<String, dynamic>> rejectProposal({
    required String proposalId,
    String? reason,
  }) async {
    final data = <String, dynamic>{};
    if (reason != null) data['reason'] = reason;

    final response = await ApiClient.post(
      '/proposals/$proposalId/reject',
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }
}
