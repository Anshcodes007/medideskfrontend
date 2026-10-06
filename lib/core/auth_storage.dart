import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user.dart';

class AuthStorage {
  AuthStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'medidesk_token';
  static const _userKey = 'medidesk_user';

  final FlutterSecureStorage _storage;

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<User?> readUser() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUser(User user) =>
      _storage.write(key: _userKey, value: jsonEncode(user.toJson()));

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }
}
