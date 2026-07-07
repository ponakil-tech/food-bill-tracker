import 'dart:io';

import 'package:dio/dio.dart';

/// A single, UI-friendly error type. Every Dio failure is normalised into one
/// of these so screens never have to inspect [DioException] directly.
class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.isNetworkError = false,
  });

  final String message;
  final int? statusCode;

  /// True when the failure is connectivity-related (no internet / DNS / host
  /// unreachable), so the UI can show a "check your connection" style message.
  final bool isNetworkError;

  static const _noInternetMessage =
      'No internet connection. Please check your network and try again.';

  /// A connectivity failure (offline, DNS lookup failed, host unreachable).
  const ApiException.noInternet()
      : message = _noInternetMessage,
        statusCode = null,
        isNetworkError = true;

  /// Translate a raw [DioException] into a readable [ApiException].
  factory ApiException.fromDio(DioException error) {
    // A DNS/offline failure can surface either as `connectionError` or as
    // `unknown` wrapping a SocketException — treat both as "no internet".
    if (error.type == DioExceptionType.connectionError ||
        error.error is SocketException) {
      return const ApiException.noInternet();
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException('Connection timed out. Please try again.');

      case DioExceptionType.cancel:
        return const ApiException('Request was cancelled.');

      case DioExceptionType.badCertificate:
        return const ApiException('Invalid server certificate.');

      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        return ApiException(
          _messageFromResponse(error.response) ?? 'Something went wrong.',
          statusCode: code,
        );

      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return const ApiException('Unexpected error. Please try again.');

      default:
        return const ApiException('Unexpected error. Please try again.');
    }
  }

  static String? _messageFromResponse(Response? response) {
    final data = response?.data;
    if (data is Map) {
      // The API's envelope carries failures under `errorMessage`.
      if (data['errorMessage'] is String) return data['errorMessage'] as String;
      if (data['message'] is String) return data['message'] as String;
    }
    return null;
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
