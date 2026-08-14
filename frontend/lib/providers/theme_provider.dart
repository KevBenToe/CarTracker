import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider({required SharedPreferences sharedPreferences})
      : _sharedPreferences = sharedPreferences {
    _load();
  }

  static const String _themeKey = 'theme_mode';

  final SharedPreferences _sharedPreferences;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void _load() {
    final String? stored = _sharedPreferences.getString(_themeKey);
    switch (stored) {
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      default:
        _themeMode = ThemeMode.system;
        break;
    }
  }

  Future<void> setDarkMode(bool enabled) async {
    _themeMode = enabled ? ThemeMode.dark : ThemeMode.light;
    await _sharedPreferences.setString(_themeKey, enabled ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> toggle() {
    return setDarkMode(!isDarkMode);
  }
}
