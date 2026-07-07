import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_exception.dart';
import '../models/user_model.dart';
import 'repository_providers.dart';

class SignupController extends AsyncNotifier<UserModel?> {
  @override
  FutureOr<UserModel?> build() => null;

  Future<void> submit({
    required String name,
    required String phone,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(userRepositoryProvider);
      return repo.createUser(name: name, phone: phone, password: password);
    });
  }

  void reset() => state = const AsyncData(null);
}

final signupControllerProvider =
    AsyncNotifierProvider<SignupController, UserModel?>(SignupController.new);

final signupErrorProvider = Provider<String?>((ref) {
  final state = ref.watch(signupControllerProvider);
  final error = state.error;
  if (error is ApiException) return error.message;
  if (error != null) return 'Something went wrong. Please try again.';
  return null;
});
