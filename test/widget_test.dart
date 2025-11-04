import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:alttask/auth/auth_provider.dart';
import 'package:alttask/main.dart';
import 'package:alttask/screens/login_screen.dart';
import 'package:alttask/theme_provider.dart';

void main() {
  testWidgets('Displays LoginScreen when user is not authenticated', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => AuthProvider()),
          ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ],
        child: const AltTask(),
      ),
    );

    // Verify that the LoginScreen is displayed.
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
