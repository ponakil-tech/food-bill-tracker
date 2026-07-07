import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final class AppProviderObserver extends ProviderObserver {
  const AppProviderObserver();

  String _name(ProviderObserverContext context) =>
      context.provider.name ?? context.provider.runtimeType.toString();

  @override
  void didAddProvider(ProviderObserverContext context, Object? value) {
    if (kDebugMode) {
      debugPrint('[Riverpod] + ${_name(context)} = $value');
    }
  }

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    if (kDebugMode) {
      debugPrint('[Riverpod] ~ ${_name(context)}: $previousValue → $newValue');
    }
  }

  @override
  void didDisposeProvider(ProviderObserverContext context) {
    if (kDebugMode) {
      debugPrint('[Riverpod] - ${_name(context)} disposed');
    }
  }

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    if (kDebugMode) {
      debugPrint('[Riverpod] ! ${_name(context)} failed: $error');
    }
  }
}
