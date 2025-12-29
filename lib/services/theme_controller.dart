import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeController._internal();
  static final ThemeController instance = ThemeController._internal();

  static const _kThemeKey = 'app_theme_mode'; // light | dark | system

  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;

  String get modeLabel {
    switch (_mode) {
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
      default:
        return 'Light';
    }
  }

  /// Call in main() before runApp()
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final v = (prefs.getString(_kThemeKey) ?? 'light').toLowerCase();
    _mode = _fromString(v);
    notifyListeners();
  }

  /// value: 'Light' | 'Dark' | 'System' (from your dropdown)
  Future<void> setTheme(String value) async {
    final prefs = await SharedPreferences.getInstance();
    final v = value.trim().toLowerCase();

    await prefs.setString(_kThemeKey, v);
    _mode = _fromString(v);
    notifyListeners();
  }

  ThemeMode _fromString(String v) {
    switch (v) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      case 'light':
      default:
        return ThemeMode.light;
    }
  }
}
