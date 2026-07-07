// lib/theme/theme_controller.dart
import 'package:flutter/material.dart';

/// Controla el modo de tema (claro/oscuro) de toda la app.
/// MyApp escucha este ValueNotifier y se reconstruye cuando cambia.
class ThemeController {
  static final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.light);

  static void toggle() {
    mode.value =
        mode.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}

/// Paleta de marca: "check-in emocional" — calma, no clínica.
/// Se mantiene consistente entre modo claro y oscuro.
class AppPalette {
  static const indigo = Color(0xFF4B5FD9);
  static const indigoDeep = Color(0xFF3948A6);
  static const periwinkle = Color(0xFFEEF1FC);
  static const sage = Color(0xFF5FAF8D);
  static const amber = Color(0xFFF2A65A);
  static const coral = Color(0xFFE8637A);
  static const navy = Color(0xFF1F2547);
  static const navyCard = Color(0xFF272E58);
  static const navyCardAlt = Color(0xFF2F376B);
}

ThemeData buildLightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppPalette.periwinkle,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppPalette.indigo,
      brightness: Brightness.light,
    ),
  );
}

ThemeData buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppPalette.navy,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppPalette.indigo,
      brightness: Brightness.dark,
    ),
  );
}