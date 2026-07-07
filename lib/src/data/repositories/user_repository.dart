import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/api_response.dart';
import '../../core/network/dio_client.dart';
import '../../models/user_model.dart';

class UserRepository {
  UserRepository({DioClient? client}) : _client = client ?? DioClient.instance;

  final DioClient _client;

  Future<UserModel> createUser({
    required String name,
    required String phone,
    required String password,
  }) async {
    final data = await _client.post(
      ApiEndpoints.users,
      data: {
        'name': name,
        'phone': phone,
        'password': password,
      },
    );
    return _parseUser(data);
  }

  /// POST /api/users/login — authenticate with phone + password.
  Future<UserModel> login({
    required String phone,
    required String password,
  }) async {
    final data = await _client.post(
      ApiEndpoints.login,
      data: {
        'phone': phone,
        'password': password,
      },
    );
    return _parseUser(data);
  }

  Future<UserModel> getUser(String id) async {
    final data = await _client.get(ApiEndpoints.user(id));
    return _parseUser(data);
  }

  Future<UserModel> updateUser(
    String id, {
    required String name,
    required String phone,
  }) async {
    final data = await _client.put(
      ApiEndpoints.user(id),
      data: {'name': name, 'phone': phone},
    );
    return _parseUser(data);
  }

  Future<void> deleteUser(String id) async {
    final data = await _client.delete(ApiEndpoints.user(id));
    _ensureSuccess(data);
  }

  UserModel _parseUser(dynamic data) {
    final envelope = _envelope(
      data,
      parse: (json) => UserModel.fromMap(json as Map<String, dynamic>),
    );
    final user = envelope.response;
    if (!envelope.isSuccess || user == null) {
      throw ApiException(
        envelope.errorMessage ?? 'Something went wrong. Please try again.',
      );
    }
    return user;
  }

  void _ensureSuccess(dynamic data) {
    final envelope = _envelope<void>(data);
    if (!envelope.isSuccess) {
      throw ApiException(
        envelope.errorMessage ?? 'Something went wrong. Please try again.',
      );
    }
  }

  ApiResponse<T> _envelope<T>(
    dynamic data, {
    T Function(Object? json)? parse,
  }) {
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Unexpected response from server.');
    }
    return ApiResponse<T>.fromMap(data, parse: parse);
  }
}
