// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maths/main.dart';
import 'package:maths/screens/home_screen.dart';
import 'package:mi_app_flutter/main.dart';


void main() {
  testWidgets('Login flow test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that the login screen is displayed.
    expect(find.text('Inicio de Sesión'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);

    // Enter the correct password.
    await tester.enterText(find.byType(TextField), '12345678');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle(); // Wait for navigation animation to complete

    // Verify that the home screen is displayed.
    expect(find.text('Bienvenido a tu nuevo entorno contable'), findsOneWidget);
  });

  testWidgets('Login flow with incorrect password', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Enter an incorrect password.
    await tester.enterText(find.byType(TextField), 'wrongpassword');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Verify that the error message is displayed.
    expect(find.text('Contraseña incorrecta. Inténtalo de nuevo.'), findsOneWidget);
    expect(find.text('Inicio de Sesión'), findsOneWidget);
  });
}


