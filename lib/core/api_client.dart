import 'package:dio/dio.dart';

import 'api_exception.dart';
import 'auth_storage.dart';
import 'config.dart';

class ApiClient {
  ApiClient({required AuthStorage storage, Dio? dio}) : _storage = storage {
    this.dio = dio ??
        Dio(
          BaseOptions(
            baseUrl: ApiConfig.baseUrl,
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
            headers: const {'Content-Type': 'application/json'},
          ),
        );

    this.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final AuthStorage _storage;
  late final Dio dio;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? query,
    T Function(dynamic data)? parser,
  }) async {
    try {
      final res = await dio.get<dynamic>(path, queryParameters: query);
      return parser != null ? parser(res.data) : res.data as T;
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<T> post<T>(
    String path, {
    Object? data,
    T Function(dynamic data)? parser,
  }) async {
    try {
      final res = await dio.post<dynamic>(path, data: data);
      return parser != null ? parser(res.data) : res.data as T;
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<T> put<T>(
    String path, {
    Object? data,
    T Function(dynamic data)? parser,
  }) async {
    try {
      final res = await dio.put<dynamic>(path, data: data);
      return parser != null ? parser(res.data) : res.data as T;
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<T> patch<T>(
    String path, {
    Object? data,
    T Function(dynamic data)? parser,
  }) async {
    try {
      final res = await dio.patch<dynamic>(path, data: data);
      return parser != null ? parser(res.data) : res.data as T;
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<T> delete<T>(
    String path, {
    T Function(dynamic data)? parser,
  }) async {
    try {
      final res = await dio.delete<dynamic>(path);
      return parser != null ? parser(res.data) : res.data as T;
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  ApiException _toApiException(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return ApiException(data['message'] as String, e.response?.statusCode);
    }
    if (data is String && data.trim().isNotEmpty) {
      final plain = data.replaceAll(RegExp(r'<[^>]+>'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
      if (plain.isNotEmpty) {
        return ApiException(plain, e.response?.statusCode);
      }
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.unknown) {
      return ApiException(
        'Please connect to internet and try again.',
      );
    }
    final fallback = e.message?.trim();
    if (fallback != null && fallback.isNotEmpty) {
      return ApiException(fallback, e.response?.statusCode);
    }
    return ApiException('Something went wrong', e.response?.statusCode);
  }
}
