import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static const String _baseUrl = 'https://dummyjson.com';

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  static void initialize() {
    log('API Service initialized with base URL: $_baseUrl');
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = options.headers['Authorization'];
          if (kDebugMode && token != null) {
            log('Sending Request: ${options.method} ${options.path}');
            log('Token: $token');
          }
          handler.next(options);
        },
        onError: (DioException e, handler) {
          if (kDebugMode)
            log('API Error: ${e.response?.statusCode} - ${e.response?.data}');
          String message = "Something went wrong";

          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.sendTimeout ||
              e.type == DioExceptionType.receiveTimeout) {
            message = "Connection timed out. Check your internet.";
          } else if (e.type == DioExceptionType.unknown) {
            message = "Server unreachable. Please check backend.";
          } else if (e.response?.statusCode == 401) {
            message = "Session expired. Please login again";
          } else if (e.response?.statusCode == 500) {
            message = "Server error. Try again later";
          } else if (e.response?.data?['msg'] != null) {
            message = e.response!.data['msg'];
          }

          handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              message: message,
              response: e.response,
              type: e.type,
            ),
          );
        },
      ),
    );
  }

  static void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  static void clearToken() {
    _dio.options.headers.remove('Authorization');
  }

  static Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    try {
      log("API GET Request to $path with query: $query");
      final response = await _dio.get(path, queryParameters: query);
      log("API GET Response: ${response.data}");
      return response.data;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  static Future<dynamic> post(String path, dynamic data) async {
    try {
      log("API POST Request to $path with data: $data");
      final response = await _dio.post(path, data: data);
      log("API POST Response: ${response.data}");
      return response.data;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  static Future<dynamic> put(String path, dynamic data) async {
    try {
      log("API PUT Request to $path with data: $data");
      final response = await _dio.put(path, data: data);
      log("API PUT Response: ${response.data}");
      return response.data;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  static Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      log("API DELETE Request to $path with query: $query");
      final response = await _dio.delete(path, queryParameters: query);
      log("API DELETE Response: ${response.data}");
      return response.data;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  static String handleError(DioException error) {
    String message = "Unknown error occurred";

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      message = "Connection timed out. Check your internet.";
    } else if (error.type == DioExceptionType.unknown) {
      message = "Server unreachable. Please check backend server.";
    } else if (error.response != null) {
      message =
          error.response?.data?['msg'] ??
          error.response?.statusMessage ??
          "Server error";
    } else {
      message = error.message ?? message;
    }

    if (kDebugMode) log("API Error: $message");
    return message;
  }
}
