import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();
  static const _apiKeyKey = 'ai_api_key';

  static Future<String?> getApiKey() => _storage.read(key: _apiKeyKey);
  static Future<void> setApiKey(String key) =>
      _storage.write(key: _apiKeyKey, value: key);
  static Future<void> deleteApiKey() => _storage.delete(key: _apiKeyKey);
}
