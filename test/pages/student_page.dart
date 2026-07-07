import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class StudentPage {
  final WidgetTester tester;

  // 1. Define aquí los FINDERS (Localizadores) de tu pantalla de estudiante.
  // Ejemplo: Si tienes un botón de "Ver Perfil" o un texto de bienvenida, agrégalos aquí.
  final Finder welcomeText = find.text("Bienvenido, Estudiante"); // Ajusta al texto real
  final Finder profileButton = find.byIcon(Icons.person); // Ejemplo de selector por icono

  StudentPage(this.tester);

  // 2. Define aquí las ACCIONES que un usuario realiza en esta pantalla.
  
  Future<void> navegarAPerfil() async {
    print("--- Navegando al perfil del estudiante ---");
    await tester.tap(profileButton);
    await tester.pumpAndSettle();
  }

  // Puedes agregar más métodos según las funciones que tenga tu StudentScreen
  // (ej. enviar formulario, cerrar sesión, etc.)
}