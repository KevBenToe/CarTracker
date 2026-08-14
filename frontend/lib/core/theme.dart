import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1D3557),
      brightness: Brightness.light,
    );
    return _themeFromScheme(scheme);
  }

  static ThemeData darkTheme() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF7BB6FF),
      brightness: Brightness.dark,
    );
    return _themeFromScheme(scheme);
  }

  static ThemeData _themeFromScheme(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
