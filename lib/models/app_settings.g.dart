// GENERATED FILE — manually written adapter for Hive.

part of 'app_settings.dart';

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 2;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      languageCode: (fields[0] as String?) ?? 'en',
      themeMode: (fields[1] as String?) ?? 'system',
      notificationsEnabled: (fields[2] as bool?) ?? true,
      aiEnabled: (fields[3] as bool?) ?? false,
      aiProvider: (fields[4] as String?) ?? 'gemini',
      aiModel: (fields[5] as String?) ?? 'gemini-1.5-flash',
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.languageCode)
      ..writeByte(1)
      ..write(obj.themeMode)
      ..writeByte(2)
      ..write(obj.notificationsEnabled)
      ..writeByte(3)
      ..write(obj.aiEnabled)
      ..writeByte(4)
      ..write(obj.aiProvider)
      ..writeByte(5)
      ..write(obj.aiModel);
  }
}