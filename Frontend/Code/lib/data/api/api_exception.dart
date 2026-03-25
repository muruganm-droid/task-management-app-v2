import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  factory ApiException.fromDioException(DioException error) {
    if (error.response != null) {
      final data = error.response?.data;
      String message = 'Something went wrong';
      if (data is Map<String, dynamic>) {
        message =
            data['message'] as String? ?? data['error'] as String? ?? message;
      }
      return ApiException(message, statusCode: error.response?.statusCode);
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('Connection timed out. Please try again.');
      case DioExceptionType.connectionError:
        return ApiException(
          'Unable to connect to the server. Check your internet connection.',
        );
      case DioExceptionType.cancel:
        return ApiException('Request was cancelled.');
      default:
        return ApiException('An unexpected error occurred.');
    }
  }

  @override
  String toString() => message;
}
