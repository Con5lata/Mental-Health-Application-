import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_app/login_screen.dart';

void main() {
  testWidgets('Login screen UI test', (WidgetTester tester) async {
    // Build our app and trigger a frame. We need to wrap LoginScreen
    // in a MaterialApp for the test to work correctly.
    await tester.pumpWidget(const MaterialApp(
      home: LoginScreen(),
    ));

    // Verify that the welcome text is present.
    expect(find.text('Welcome Back'), findsOneWidget);

    // Verify that the Email and Password fields are present.
    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);

    // Verify that the Login button is present.
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
  });
}
