import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_bill_tracker/app/app.dart';
import 'package:food_bill_tracker/app/observers/app_provider_observer.dart';
import 'package:food_bill_tracker/src/core/storage/prefs_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PrefsService.instance.init();
  runApp(
    const ProviderScope(observers: [AppProviderObserver()], child: MyApp()),
  );
}
