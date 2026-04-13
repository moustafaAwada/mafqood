import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'auth_refresh_token';
  static const _refreshTokenExpirationKey = 'auth_refresh_token_expiration';
  static const _userDataKey = 'auth_user_data';

  final FlutterSecureStorage _secureStorage;

  AuthStorage({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  Future<void> saveAuthResponse({
    required String token,
    required String refreshToken,
    required int expiresIn,
    required DateTime refreshTokenExpiration,
  }) async {
    await _secureStorage.write(key: _tokenKey, value: token);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    await _secureStorage.write(
      key: _refreshTokenExpirationKey,
      value: refreshTokenExpiration.toIso8601String(),
    );
  }

  Future<void> saveUserData(Map<String, dynamic> data) async {
    await _secureStorage.write(key: _userDataKey, value: jsonEncode(data));
  }

  Future<String?> getToken() async => _secureStorage.read(key: _tokenKey);

  Future<String?> getRefreshToken() async =>
      _secureStorage.read(key: _refreshTokenKey);

  Future<DateTime?> getRefreshTokenExpiration() async {
    final raw = await _secureStorage.read(key: _refreshTokenExpirationKey);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final raw = await _secureStorage.read(key: _userDataKey);
    if (raw == null || raw.isEmpty) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<bool> hasValidSession() async {
    final token = await getToken();
    final refreshToken = await getRefreshToken();
    return token != null && refreshToken != null;
  }

  Future<void> clear() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _refreshTokenExpirationKey);
    await _secureStorage.delete(key: _userDataKey);
  }
}
