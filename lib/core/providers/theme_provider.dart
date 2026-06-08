import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  final StorageService _storage;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider(this._storage) {
    _load();
  }

  ThemeMode get themeMode => _themeMode;

  String get themeModeLabel {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Yorug\' rejim';
      case ThemeMode.dark:
        return 'Qorong\'u rejim';
      case ThemeMode.system:
        return 'Tizim sozlamasi';
    }
  }

  void _load() {
    final saved = _storage.getThemeMode();
    switch (saved) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    String modeStr;
    switch (mode) {
      case ThemeMode.light:
        modeStr = 'light';
        break;
      case ThemeMode.dark:
        modeStr = 'dark';
        break;
      default:
        modeStr = 'system';
    }
    await _storage.setThemeMode(modeStr);
    notifyListeners();
  }
}
