// Smoke test: with a fake repository, the login flow authenticates and lands
// on the food list.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_bill_tracker/app/app.dart';
import 'package:food_bill_tracker/src/core/storage/prefs_service.dart';
import 'package:food_bill_tracker/src/data/repositories/user_repository.dart';
import 'package:food_bill_tracker/src/models/user_model.dart';
import 'package:food_bill_tracker/src/providers/repository_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Returns a user without touching the network.
class _FakeUserRepository extends UserRepository {
  @override
  Future<UserModel> login({
    required String phone,
    required String password,
  }) async {
    return const UserModel(id: 1, name: 'Midhilesh', phone: '9898989898');
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PrefsService.instance.init();
  });

  testWidgets('Login flow lands on the food list', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userRepositoryProvider.overrideWithValue(_FakeUserRepository()),
        ],
        child: const MyApp(),
      ),
    );

    // Starts on the login screen.
    expect(find.text('Food Note App'), findsOneWidget);

    // Enter credentials and log in.
    await tester.enterText(
      find.widgetWithIcon(TextFormField, Icons.phone_outlined),
      '9898989898',
    );
    await tester.enterText(
      find.widgetWithIcon(TextFormField, Icons.lock_outline),
      '123456',
    );
    await tester.tap(find.text('LOGIN'));
    await tester.pumpAndSettle();

    // Landed on the list screen with seeded entries.
    expect(find.text('My Food Entries'), findsOneWidget);
    expect(find.text('01 Jul 2026'), findsOneWidget);
  });
}
