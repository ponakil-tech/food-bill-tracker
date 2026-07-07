
class ApiResponse<T> {
  const ApiResponse({
    this.status,
    this.successMessage,
    this.errorMessage,
    this.response,
  });

  final String? status;
  final String? successMessage;
  final String? errorMessage;
  final T? response;

  bool get isSuccess => status?.toUpperCase() == 'SUCCESS';

  factory ApiResponse.fromMap(
    Map<String, dynamic> map, {
    T Function(Object? json)? parse,
  }) {
    final payload = map['response'];
    return ApiResponse<T>(
      status: map['status'] as String?,
      successMessage: map['successMessage'] as String?,
      errorMessage: map['errorMessage'] as String?,
      response: (parse != null && payload != null) ? parse(payload) : null,
    );
  }
}
