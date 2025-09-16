import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/environment_config.dart';
import '../constants/app_constants.dart';
import 'storage_service.dart';

class ApiService {
  static late Dio _dio;
  static bool _initialized = false;

  static Dio get dio {
    if (!_initialized) {
      _initialize();
    }
    return _dio;
  }

  static void _initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: Duration(milliseconds: AppConstants.connectTimeout),
      receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      // Add additional headers for CORS and API compatibility
      extra: {
        'withCredentials': false,
      },
    ));

    // Add auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = StorageService.getAuthToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        // Add user agent for better server compatibility
        options.headers['User-Agent'] = 'GigMarketplace-Flutter/1.0.0';
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Handle unauthorized access
          _handleUnauthorized();
        }
        handler.next(error);
      },
    ));

    // Add logger in development mode
    if (EnvironmentConfig.isDevelopment) {
      _dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        compact: false,
      ));
    }

    _initialized = true;
  }

  static void _handleUnauthorized() {
    // Clear stored auth data
    StorageService.clearAll();
    // Redirect to login screen would be handled by the app router
  }

  // Helper method to handle API errors consistently
  static Map<String, dynamic> _handleError(DioException error) {
    String message = AppConstants.unknownError;
    int statusCode = 0;

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      message = 'Request timeout. Please check your internet connection.';
    } else if (error.type == DioExceptionType.connectionError) {
      message = AppConstants.networkError;
    } else if (error.response != null) {
      statusCode = error.response!.statusCode ?? 0;
      
      switch (statusCode) {
        case 400:
          message = 'Bad request. Please check your input data.';
          break;
        case 401:
          message = AppConstants.authError;
          break;
        case 403:
          message = 'Access forbidden. You do not have permission to perform this action.';
          break;
        case 404:
          message = 'Resource not found.';
          break;
        case 422:
          message = 'Validation failed. Please check your input data.';
          break;
        case 500:
          message = AppConstants.serverError;
          break;
        default:
          message = 'An error occurred (Status: $statusCode)';
      }

      // Try to extract error message from response
      try {
        final responseData = error.response!.data;
        if (responseData is Map<String, dynamic> && responseData.containsKey('message')) {
          message = responseData['message'].toString();
        }
      } catch (e) {
        // Keep the default message if parsing fails
      }
    }

    return {
      'success': false,
      'message': message,
      'statusCode': statusCode,
      'error': error.toString(),
    };
  }

  // Authentication endpoints
  static Future<Map<String, dynamic>> login(Map<String, dynamic> data) async {
    try {
      final response = await dio.post('/auth/login', data: data);
      return {
        'success': true,
        'data': response.data,
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return {
        'success': false,
        'message': AppConstants.unknownError,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    try {
      final response = await dio.post('/auth/register', data: data);
      return {
        'success': true,
        'data': response.data,
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return {
        'success': false,
        'message': AppConstants.unknownError,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> logout() async {
    try {
      final response = await dio.post('/auth/logout');
      return {
        'success': true,
        'data': response.data,
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return {
        'success': false,
        'message': AppConstants.unknownError,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await dio.get('/auth/me');
      return {
        'success': true,
        'data': response.data,
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return {
        'success': false,
        'message': AppConstants.unknownError,
        'error': e.toString(),
      };
    }
  }

  // Job endpoints
  static Future<Map<String, dynamic>> getJobs({Map<String, dynamic>? query}) async {
    try {
      final response = await dio.get('/jobs', queryParameters: query);
      return {
        'success': true,
        'data': response.data,
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return {
        'success': false,
        'message': AppConstants.unknownError,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> getJob(int jobId) async {
    try {
      final response = await dio.get('/jobs/$jobId');
      return {
        'success': true,
        'data': response.data,
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return {
        'success': false,
        'message': AppConstants.unknownError,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> createJob(Map<String, dynamic> data) async {
    try {
      final response = await dio.post('/jobs', data: data);
      return {
        'success': true,
        'data': response.data,
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return {
        'success': false,
        'message': AppConstants.unknownError,
        'error': e.toString(),
      };
    }
  }

  // Categories
  static Future<Map<String, dynamic>> getCategories() async {
    try {
      final response = await dio.get('/categories');
      return {
        'success': true,
        'data': response.data,
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return {
        'success': false,
        'message': AppConstants.unknownError,
        'error': e.toString(),
      };
    }
  }

  // Health check endpoint
  static Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await dio.get('/');
      return {
        'success': true,
        'data': response.data,
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return {
        'success': false,
        'message': AppConstants.unknownError,
        'error': e.toString(),
      };
    }
  }

  // Generic methods with error handling
  static Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query}) async {
    try {
      final response = await dio.get(path, queryParameters: query);
      return {
        'success': true,
        'data': response.data,
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return {
        'success': false,
        'message': AppConstants.unknownError,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> post(String path, {dynamic data}) async {
    try {
      final response = await dio.post(path, data: data);
      return {
        'success': true,
        'data': response.data,
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return {
        'success': false,
        'message': AppConstants.unknownError,
        'error': e.toString(),
      };
    }
  }
}