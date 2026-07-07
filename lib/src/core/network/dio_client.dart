import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_endpoints.dart';
import 'api_exception.dart';

class DioClient {
  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: ApiEndpoints.connectTimeout,
        receiveTimeout: ApiEndpoints.receiveTimeout,
        responseType: ResponseType.json,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(_AuthInterceptor());
    _dio.interceptors.add(_RetryInterceptor(_dio));
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (o) => debugPrint(o.toString()),
        ),
      );
    }
  }

  static final DioClient instance = DioClient._internal();

  late final Dio _dio;

  /// Exposed for advanced cases (file upload, cancel tokens, …).
  Dio get raw => _dio;

  /// Auth token attached to every request; set after login, clear on logout.
  String? _authToken;
  void setAuthToken(String? token) => _authToken = token;

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      _request(() => _dio.get(path, queryParameters: queryParameters));

  Future<dynamic> post(String path, {Object? data}) =>
      _request(() => _dio.post(path, data: data));

  Future<dynamic> put(String path, {Object? data}) =>
      _request(() => _dio.put(path, data: data));

  Future<dynamic> delete(String path, {Object? data}) =>
      _request(() => _dio.delete(path, data: data));

  /// Runs a Dio call and unwraps it into raw data or an [ApiException].
  Future<dynamic> _request(Future<Response> Function() call) async {
    try {
      final response = await call();
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final token = DioClient.instance._authToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

/// Retries transient network failures (timeouts / connection errors) with a
/// short backoff. This smooths over free-tier cold starts and brief blips
/// without the user having to tap again.
class _RetryInterceptor extends Interceptor {
  _RetryInterceptor(this._dio);

  final Dio _dio;
  static const int _maxRetries = 2;

  bool _isTransient(DioException e) {
    // Only retry timeouts (e.g. free-tier cold starts). A connectivity error
    // (offline / DNS failure) won't be fixed by retrying, so let it surface
    // immediately instead of delaying the "no internet" message.
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout;
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final attempt = (err.requestOptions.extra['retry_attempt'] as int?) ?? 0;

    if (_isTransient(err) && attempt < _maxRetries) {
      final nextAttempt = attempt + 1;
      err.requestOptions.extra['retry_attempt'] = nextAttempt;
      // Linear backoff: 2s, then 4s.
      await Future.delayed(Duration(seconds: nextAttempt * 2));
      try {
        final response = await _dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } on DioException catch (e) {
        return handler.next(e);
      }
    }

    handler.next(err);
  }
}
