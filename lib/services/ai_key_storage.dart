import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AiKeyStorage {
  AiKeyStorage._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String _keyApiKey = 'you_gemini_api_key';

  static Future<String?> read() async {
    try {
      return await _storage.read(key: _keyApiKey);
    } catch (_) {
      return null;
    }
  }

  static Future<void> write(String apiKey) async {
    await _storage.write(key: _keyApiKey, value: apiKey);
  }

  static Future<void> delete() async {
    await _storage.delete(key: _keyApiKey);
  }
}