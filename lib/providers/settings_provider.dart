import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../repositories/settings_repository.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repository = SettingsRepository();

  AppSettings _settings = AppSettings();
  bool _loading = true;

  AppSettings get settings => _settings;
  bool get isLoading => _loading;

  Locale get locale => Locale(_settings.languageCode);

  ThemeMode get themeMode {
    switch (_settings.themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _settings = _repository.load();
    _loading = false;
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    if (code != 'en' && code != 'bn') return;
    _settings = _settings.copyWith(languageCode: code);
    await _repository.save(_settings);
    notifyListeners();
  }

  Future<void> setThemeMode(String mode) async {
    if (mode != 'light' && mode != 'dark' && mode != 'system') return;
    _settings = _settings.copyWith(themeMode: mode);
    await _repository.save(_settings);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _settings = _settings.copyWith(notificationsEnabled: enabled);
    await _repository.save(_settings);
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    _settings = AppSettings();
    await _repository.save(_settings);
    notifyListeners();
  }
}