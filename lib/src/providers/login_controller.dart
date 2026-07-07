import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_exception.dart';
import '../models/user_model.dart';
import 'repository_providers.dart';

/// Async state for the login action (`POST /api/users/login`).
///
/// State is an [AsyncValue<UserModel?>]:
/// - `AsyncData(null)` → idle
/// - `AsyncLoading()`  → request in flight (button spinner)
/// - `AsyncData(user)` → success (store session, navigate)
/// - `AsyncError(e)`   → failure (snackbar with the server message)
class LoginController extends AsyncNotifier<UserModel?> {
  @override
  FutureOr<UserModel?> build() => null;

  Future<void> submit({
    required String phone,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(userRepositoryProvider);
      return repo.login(phone: phone, password: password);
    });
  }

  void reset() => state = const AsyncData(null);
}

final loginControllerProvider =
    AsyncNotifierProvider<LoginController, UserModel?>(
  LoginController.new,
);

/// Friendly error message for the current login failure, if any.
final loginErrorProvider = Provider<String?>((ref) {
  final error = ref.watch(loginControllerProvider).error;
  if (error is ApiException) return error.message;
  if (error != null) return 'Something went wrong. Please try again.';
  return null;
});
