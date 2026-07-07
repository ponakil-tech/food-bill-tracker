import 'package:flutter_riverpod/legacy.dart';

import '../../src/core/storage/prefs_service.dart';
import '../../src/core/storage/storage_keys.dart';
import '../../src/models/user_model.dart';

/// Global session state: the logged-in [UserModel], or `null` when logged out.
///
/// Lives in the app layer because it is app-wide and outlives any single
/// screen. On login/logout it also mirrors the session into [PrefsService] so
/// it can be restored on next launch.
class AuthNotifier extends StateNotifier<UserModel?> {
  AuthNotifier() : super(null);

  final _prefs = PrefsService.instance;

  bool get isLoggedIn => state != null;

  void login(UserModel user) {
    state = user;
    _prefs.setBool(StorageKeys.isLoggedIn, true);
    _prefs.setString(StorageKeys.username, user.name);
  }

  void logout() {
    state = null;
    _prefs.remove(StorageKeys.isLoggedIn);
    _prefs.remove(StorageKeys.username);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>(
  (ref) => AuthNotifier(),
);
