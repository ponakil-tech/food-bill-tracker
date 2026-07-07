import 'package:shared_preferences/shared_preferences.dart';


class PrefsService {
  PrefsService._internal();

  static final PrefsService instance = PrefsService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _store {
    final store = _prefs;
    if (store == null) {
      throw StateError(
        'PrefsService.init() must be awaited before use.',
      );
    }
    return store;
  }

  Future<bool> setString(String key, String value) =>
      _store.setString(key, value);
  String? getString(String key) => _store.getString(key);

  Future<bool> setBool(String key, bool value) => _store.setBool(key, value);
  bool getBool(String key, {bool defaultValue = false}) =>
      _store.getBool(key) ?? defaultValue;

  Future<bool> remove(String key) => _store.remove(key);
  Future<bool> clear() => _store.clear();
}
