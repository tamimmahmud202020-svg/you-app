import '../models/app_settings.dart';
import '../services/database_service.dart';

class SettingsRepository {
  static const String _key = 'current_settings';

  AppSettings load() {
    final box = DatabaseService.settingsBox;
    final existing = box.get(_key);
    if (existing != null) return existing;
    return AppSettings();
  }

  Future<void> save(AppSettings settings) async {
    await DatabaseService.settingsBox.put(_key, settings);
  }

  Future<void> clear() async {
    await DatabaseService.settingsBox.clear();
  }
}