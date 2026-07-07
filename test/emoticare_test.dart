import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_flutter_ia/screens/login_screen.dart'; 
import 'pages/login_page.dart';
import 'pages/student_page.dart';

void main() {
  
  // --- FLUJO POSITIVO ---
  testWidgets('Flujo completo: Login y navegación a perfil de estudiante', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    final loginPage = LoginPage(tester);
    final studentPage = StudentPage(tester);

    await loginPage.realizarLogin("estudiante@gmail.com", "123456");
    
    print("--- Login completado, ahora voy a navegar ---");
    
    await studentPage.navegarAPerfil();
    
    print("--- Navegación finalizada ---");

    expect(find.text("Evaluación Emocional"), findsOneWidget); 
    expect(find.text("Bienvenido"), findsOneWidget);
  });

  // --- FLUJO NEGATIVO (Validación de errores) ---
  testWidgets('Flujo negativo: Validar mensaje de error con credenciales falsas', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    
    final loginPage = LoginPage(tester);

    // Intentamos login con datos incorrectos
    await loginPage.realizarLogin("usuario_falso@gmail.com", "clave_incorrecta");

    // Validamos que el mensaje de error aparece
    expect(loginPage.errorMessage, findsOneWidget);
    
    // Validamos que NO hemos navegado a la pantalla de estudiante
    expect(find.text("Evaluación Emocional"), findsNothing);
    
    print("--- Prueba negativa finalizada: Error detectado correctamente ---");
  });
}