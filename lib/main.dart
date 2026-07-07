import 'package:flutter/material.dart';
import 'package:proyecto_flutter_ia/theme/theme_controller.dart';
import 'screens/login_screen.dart';
import 'package:proyecto_flutter_ia/services/evaluacion_storage_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.mode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Panel IA Tutor',
          debugShowCheckedModeBanner: false,
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: mode,
          home: const LoginScreen(),
        );
      },
    );
  }
}