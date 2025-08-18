import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorageService {
  static const _storage = FlutterSecureStorage();

  static const _phoneKey = 'phone';
  static const _tokenKey = 'token';

  static Future<void> saveAuth(String phone, String token) async {
    await Future.wait([
      _storage.write(key: _phoneKey, value: phone),
      _storage.write(key: _tokenKey, value: token),
    ]);
  }

  static Future<void> removeAuth() async {
    await Future.wait([
      // _storage.delete(key: _phoneKey),
      _storage.delete(key: _tokenKey),
    ]);
  }

  static Future<String?> getPhone() async {
    final phone = await _storage.read(key: _phoneKey);

    return phone;
  }

  static Future<String?> getToken() async {
    final token = await _storage.read(key: _tokenKey);
    return token;
  }
}
