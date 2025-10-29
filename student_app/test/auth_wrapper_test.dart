import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_app/main.dart';
import 'package:student_app/home_screen.dart';
import 'package:student_app/login_screen.dart';
import 'package:student_app/register_screen.dart';
import 'package:mockito/mockito.dart';
import 'auth_wrapper_test.mocks.dart'; // Import the generated mock file
import 'package:mockito/annotations.dart';

@GenerateMocks([User])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthWrapper Tests', () {
    testWidgets('Navigates to RegisterScreen on first launch', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({}); // Mock SharedPreferences

      await tester.pumpWidget(const MaterialApp(home: AuthWrapper()));

      await tester.pumpAndSettle();

      expect(find.byType(RegisterScreen), findsOneWidget);
    });

    testWidgets('Navigates to HomeScreen if user is authenticated', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'hasOpenedBefore': true});

      // Mock FirebaseAuth
      final mockUser = MockUser();
      when(mockUser.emailVerified).thenReturn(true);
      when(FirebaseAuth.instance.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));

      await tester.pumpWidget(const MaterialApp(home: AuthWrapper()));

      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Navigates to LoginScreen if user is not authenticated', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'hasOpenedBefore': true});

      // Mock FirebaseAuth
      when(FirebaseAuth.instance.authStateChanges()).thenAnswer((_) => Stream.value(null));

      await tester.pumpWidget(const MaterialApp(home: AuthWrapper()));

      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}