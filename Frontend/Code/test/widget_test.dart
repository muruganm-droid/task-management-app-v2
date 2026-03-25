import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_management_app/data/api/api_client.dart';
import 'package:task_management_app/main.dart';
import 'package:task_management_app/presentation/providers.dart';

void main() {
  testWidgets('App launches and shows login screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    FlutterSecureStorage.setMockInitialValues({});
    const secureStorage = FlutterSecureStorage();
    final apiClient = ApiClient(secureStorage);
    await apiClient.init();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          apiClientProvider.overrideWithValue(apiClient),
        ],
        child: const TaskManagementApp(),
      ),
    );

    // Pump enough frames for animations (elasticOut doesn't settle easily)
    await tester.pump(const Duration(milliseconds: 1500));

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign In'), findsWidgets);
  });
}
