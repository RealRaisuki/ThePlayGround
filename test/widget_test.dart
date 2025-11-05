
import 'package:alttask/category_provider.dart';
import 'package:alttask/screens/auth/auth_screen.dart';
import 'package:alttask/screens/todo_list_screen.dart';
import 'package:alttask/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:alttask/main.dart';
import 'package:alttask/theme_provider.dart';

// Mock AuthService
class MockAuthService extends Mock implements AuthService {
  @override
  Stream<fb_auth.User?> get user => Stream.value(mockUser);

  fb_auth.User? mockUser;
}

// Mock Firebase User
class MockFirebaseUser extends Mock implements fb_auth.User {
  @override
  String get uid => 'test_uid';

  @override
  String? get email => 'test@example.com';

  @override
  fb_auth.UserMetadata get metadata => MockUserMetadata();
}

class MockUserMetadata extends Mock implements fb_auth.UserMetadata {
  @override
  DateTime? get creationTime => DateTime.now();
}

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  testWidgets('Displays AuthScreen when user is not authenticated', (
    WidgetTester tester,
  ) async {
    // Set mock user to null for unauthenticated state
    mockAuthService.mockUser = null;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthService>.value(value: mockAuthService),
          ChangeNotifierProvider(create: (context) => ThemeProvider()),
          ChangeNotifierProvider(create: (context) => CategoryProvider()),
        ],
        child: const AltTask(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify that the AuthScreen is displayed.
    expect(find.byType(AuthScreen), findsOneWidget);
  });

  testWidgets('Displays TodoListScreen when user is authenticated', (
    WidgetTester tester,
  ) async {
    // Set mock user for authenticated state
    mockAuthService.mockUser = MockFirebaseUser();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthService>.value(value: mockAuthService),
          ChangeNotifierProvider(create: (context) => ThemeProvider()),
          ChangeNotifierProvider(create: (context) => CategoryProvider()),
        ],
        child: const AltTask(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify that the TodoListScreen is displayed.
    expect(find.byType(TodoListScreen), findsOneWidget);
  });
}
