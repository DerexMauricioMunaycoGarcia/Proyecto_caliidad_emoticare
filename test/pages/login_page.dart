import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class LoginPage {
  final WidgetTester tester;

  final Finder emailField = find.byType(TextField).at(0);
  final Finder passwordField = find.byType(TextField).at(1);
  final Finder loginButton = find.byType(ElevatedButton);
  final Finder errorMessage = find.text("Correo o contraseña incorrectos.");

  LoginPage(this.tester);

  // --- ESTE ES EL MÉTODO QUE TE FALTA ---
  Future<void> realizarLogin(String email, String password) async {
    await ingresarCredenciales(email, password);
    await presionarLogin();
  }

  Future<void> ingresarCredenciales(String email, String password) async {
    await tester.enterText(emailField, email);
    await tester.enterText(passwordField, password);
  }

  Future<void> presionarLogin() async {
    await tester.tap(loginButton);
    await tester.pumpAndSettle(); 
  }
}