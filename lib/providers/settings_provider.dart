import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../repositories/settings_repository.dart';
import '../services/ai_key_storage.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repository = SettingsRepository();

  AppSettings _settings = AppSettings();
  String? _apiKey;
  bool _loading = true;

  AppSettings get settings => _settings;
  bool get isLoading => _loading;
  String? get apiKey => _apiKey;

  bool get isAiConfigured =>
      _settings.aiEnabled &&
      _apiKey != null &&
      _apiKey!.trim().isNotEmpty;

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
    _apiKey = await AiKeyStorage.read();
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

  Future<void> setAiEnabled(bool enabled) async {
    _settings = _settings.copyWith(aiEnabled: enabled);
    await _repository.save(_settings);
    notifyListeners();
  }

  Future<void> setAiProvider(String provider) async {
    _settings = _settings.copyWith(aiProvider: provider);
    await _repository.save(_settings);
    notifyListeners();
  }

  Future<void> setAiModel(String model) async {
    _settings = _settings.copyWith(aiModel: model);
    await _repository.save(_settings);
    notifyListeners();
  }

  Future<void> saveApiKey(String key) async {
    final trimmed = key.trim();
    if (trimmed.isEmpty) {
      await AiKeyStorage.delete();
      _apiKey = null;
    } else {
      await AiKeyStorage.write(trimmed);
      _apiKey = trimmed;
    }
    notifyListeners();
  }

  Future<void> clearApiKey() async {
    await AiKeyStorage.delete();
    _apiKey = null;
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    _settings = AppSettings();
    await _repository.save(_settings);
    await AiKeyStorage.delete();
    _apiKey = null;
    notifyListeners();
  }
}