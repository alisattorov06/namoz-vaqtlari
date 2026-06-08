import 'package:flutter/material.dart';
import 'package:namoz_vaqtlari/core/services/storage_service.dart';

/// Mavzu boshqaruvchisi
class ThemeProvider extends ChangeNotifier {
  final StorageService _storage;

  ThemeProvider(this._storage) {
    _loadTheme();
  }

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void _loadTheme() {
    final mode = _storage.getThemeMode();
    switch (mode) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    String str;
    switch (mode) {
      case ThemeMode.light:
        str = 'light';
        break;
      case ThemeMode.dark:
        str = 'dark';
        break;
      case ThemeMode.system:
        str = 'system';
    }
    await _storage.setThemeMode(str);
    notifyListeners();
  }
}
