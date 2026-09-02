import 'package:flutter/material.dart';
import '../storage/token_storage.dart';

class SettingsProvider extends ChangeNotifier {
  final TokenStorage tokenStorage;

  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  SettingsProvider({required this.tokenStorage}) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final savedTheme = await tokenStorage.getThemeMode();
    if (savedTheme != null) {
      switch (savedTheme) {
        case 'dark':
          _themeMode = ThemeMode.dark;
        case 'light':
          _themeMode = ThemeMode.light;
        default:
          _themeMode = ThemeMode.system;
      }
    }

    final savedLang = await tokenStorage.getLanguageCode();
    if (savedLang != null) {
      _locale = Locale(savedLang);
    }

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final String modeStr;
    switch (mode) {
      case ThemeMode.dark:
        modeStr = 'dark';
      case ThemeMode.light:
        modeStr = 'light';
      case ThemeMode.system:
        modeStr = 'system';
    }
    await tokenStorage.saveThemeMode(modeStr);
  }

  Future<void> setLocale(Locale newLocale) async {
    _locale = newLocale;
    notifyListeners();
    await tokenStorage.saveLanguageCode(newLocale.languageCode);
  }

  String get themeModeName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  String get languageName {
    return _locale.languageCode == 'km' ? 'ភាសាខ្មែរ' : 'English';
  }
}
