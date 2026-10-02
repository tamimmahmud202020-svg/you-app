import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 2)
class AppSettings extends HiveObject {
  @HiveField(0)
  final String languageCode;

  @HiveField(1)
  final String themeMode;

  @HiveField(2)
  final bool notificationsEnabled;

  AppSettings({
    this.languageCode = 'en',
    this.themeMode = 'system',
    this.notificationsEnabled = true,
  });

  AppSettings copyWith({
    String? languageCode,
    String? themeMode,
    bool? notificationsEnabled,
  }) {
    return AppSettings(
      languageCode: languageCode ?? this.languageCode,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}