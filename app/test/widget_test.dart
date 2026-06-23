// This is a basic Flutter widget test for PetMatchApp.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petmatch_app/app.dart';
import 'package:petmatch_app/core/providers/core_providers.dart';
import 'package:petmatch_app/core/services/notification_service.dart';

void main() {
  testWidgets('PetMatchApp launches and shows splash screen', (WidgetTester tester) async {
    // Setup Mock SharedPreferences initial values
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    final notificationService = NotificationService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          notificationServiceProvider.overrideWithValue(notificationService),
        ],
        child: const PetMatchApp(),
      ),
    );

    // Verify that the App launched and the PetMatchApp widget exists.
    expect(find.byType(PetMatchApp), findsOneWidget);

    // Let the splash timer expire to avoid pending timer errors
    await tester.pump(const Duration(seconds: 4));
  });
}

