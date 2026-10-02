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

  @HiveField(3)
  final bool aiEnabled;

  @HiveField(4)
  final String aiProvider;

  @HiveField(5)
  final String aiModel;

  AppSettings({
    this.languageCode = 'en',
    this.themeMode = 'system',
    this.notificationsEnabled = true,
    this.aiEnabled = false,
    this.aiProvider = 'gemini',
    this.aiModel = 'gemini-1.5-flash',
  });

  AppSettings copyWith({
    String? languageCode,
    String? themeMode,
    bool? notificationsEnabled,
    bool? aiEnabled,
    String? aiProvider,
    String? aiModel,
  }) {
    return AppSettings(
      languageCode: languageCode ?? this.languageCode,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      aiEnabled: aiEnabled ?? this.aiEnabled,
      aiProvider: aiProvider ?? this.aiProvider,
      aiModel: aiModel ?? this.aiModel,
    );
  }
}