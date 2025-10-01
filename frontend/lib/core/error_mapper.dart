import 'package:dio/dio.dart';

/// Base API exception
abstract class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => message;
}

/// 400 Bad Request
class BadRequestException extends ApiException {
  BadRequestException(String message, {dynamic data})
      : super(message, statusCode: 400, data: data);
}

/// 401 Unauthorized
class UnauthorizedException extends ApiException {
  UnauthorizedException(String message, {dynamic data})
      : super(message, statusCode: 401, data: data);
}

/// 403 Forbidden
class ForbiddenException extends ApiException {
  ForbiddenException(String message, {dynamic data})
      : super(message, statusCode: 403, data: data);
}

/// 404 Not Found
class NotFoundException extends ApiException {
  NotFoundException(String message, {dynamic data})
      : super(message, statusCode: 404, data: data);
}

/// 422 Validation Error
class ValidationException extends ApiException {
  final Map<String, List<String>>? errors;

  ValidationException(String message, {this.errors, dynamic data})
      : super(message, statusCode: 422, data: data);

  /// Get validation errors for a specific field
  List<String>? getFieldErrors(String field) => errors?[field];

  /// Get the first error message for a field
  String? getFirstFieldError(String field) => errors?[field]?.firstOrNull;

  /// Get all error messages as a flat list
  List<String> getAllErrorMessages() {
    if (errors == null) return [];
    return errors!.values.expand((list) => list).toList();
  }

  /// Get all errors as a single string
  String getAllErrorsAsString({String separator = '\n'}) {
    return getAllErrorMessages().join(separator);
  }
}

/// 500 Internal Server Error
class ServerException extends ApiException {
  ServerException(String message, {dynamic data})
      : super(message, statusCode: 500, data: data);
}

/// Network/Connection Error
class NetworkException extends ApiException {
  NetworkException(String message) : super(message);
}

/// Timeout Error
class TimeoutException extends ApiException {
  TimeoutException(String message) : super(message);
}

/// Unknown/Generic Error
class UnknownException extends ApiException {
  UnknownException(String message, {int? statusCode, dynamic data})
      : super(message, statusCode: statusCode, data: data);
}

/// Error mapper to convert DioException to typed exceptions
class ErrorMapper {
  /// Map DioException to typed ApiException
  static ApiException mapError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return TimeoutException(
        'Request timeout. Please check your internet connection.',
      );
    }

    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.unknown) {
      return NetworkException(
        'Network error. Please check your internet connection.',
      );
    }

    final response = error.response;
    if (response == null) {
      return UnknownException('An unknown error occurred');
    }

    final statusCode = response.statusCode ?? 0;
    final data = response.data;
    String message = 'An error occurred';

    // Try to extract message from response
    if (data is Map<String, dynamic>) {
      message = data['message']?.toString() ?? message;
    }

    switch (statusCode) {
      case 400:
        return BadRequestException(message, data: data);
      
      case 401:
        return UnauthorizedException(
          message.isEmpty ? 'Unauthorized. Please log in again.' : message,
          data: data,
        );
      
      case 403:
        return ForbiddenException(
          message.isEmpty ? 'Access forbidden.' : message,
          data: data,
        );
      
      case 404:
        return NotFoundException(
          message.isEmpty ? 'Resource not found.' : message,
          data: data,
        );
      
      case 422:
        // Extract validation errors
        Map<String, List<String>>? errors;
        if (data is Map<String, dynamic> && data.containsKey('errors')) {
          final errorsData = data['errors'];
          if (errorsData is Map<String, dynamic>) {
            errors = errorsData.map((key, value) {
              if (value is List) {
                return MapEntry(key, value.map((e) => e.toString()).toList());
              }
              return MapEntry(key, [value.toString()]);
            });
          }
        }
        return ValidationException(
          message.isEmpty ? 'Validation failed.' : message,
          errors: errors,
          data: data,
        );
      
      case 500:
      case 502:
      case 503:
        return ServerException(
          message.isEmpty ? 'Server error. Please try again later.' : message,
          data: data,
        );
      
      default:
        return UnknownException(
          message.isEmpty ? 'An error occurred (Status: $statusCode)' : message,
          statusCode: statusCode,
          data: data,
        );
    }
  }

  /// Helper to handle API calls with proper error mapping
  static Future<T> handleApiCall<T>(Future<T> Function() apiCall) async {
    try {
      return await apiCall();
    } on DioException catch (e) {
      throw mapError(e);
    }
  }
}
