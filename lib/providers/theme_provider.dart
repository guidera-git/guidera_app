import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_preference';

  ThemeMode _themeMode = ThemeMode.system;
  String _themePreference = 'System';

  ThemeMode get themeMode => _themeMode;
  String get themePreference => _themePreference;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeKey) ?? 'System';
      await setThemePreference(savedTheme);
    } catch (e) {
      // Handle error silently, use default theme
    }
  }

  Future<void> setThemePreference(String preference) async {
    _themePreference = preference;

    switch (preference) {
      case 'Light':
        _themeMode = ThemeMode.light;
        break;
      case 'Dark':
        _themeMode = ThemeMode.dark;
        break;
      case 'System':
      default:
        _themeMode = ThemeMode.system;
        break;
    }

    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, preference);
    } catch (e) {
      // Handle error silently
    }
  }
}