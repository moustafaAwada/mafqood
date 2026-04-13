import 'package:mafqood/core/database/auth_storage.dart';
import 'package:mafqood/features/auth/data/datasources/auth_local_data_source.dart';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final AuthStorage _authStorage;

  AuthLocalDataSourceImpl({AuthStorage? authStorage})
    : _authStorage = authStorage ?? AuthStorage();

  @override
  Future<bool> isLoggedIn() async => _authStorage.hasValidSession();

  @override
  Future<Map<String, dynamic>?> getStoredUserData() async =>
      _authStorage.getUserData();

  @override
  Future<String?> getAccessToken() async => _authStorage.getToken();

  @override
  Future<String?> getRefreshToken() async => _authStorage.getRefreshToken();

  @override
  Future<DateTime?> getRefreshTokenExpiration() async =>
      _authStorage.getRefreshTokenExpiration();

  @override
  Future<void> saveUserData(Map<String, dynamic> data) async {
    await _authStorage.saveUserData(data);
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
    required DateTime refreshTokenExpiration,
  }) async {
    await _authStorage.saveAuthResponse(
      token: accessToken,
      refreshToken: refreshToken,
      expiresIn: expiresIn,
      refreshTokenExpiration: refreshTokenExpiration,
    );
  }

  @override
  Future<void> clearAll() async {
    await _authStorage.clear();
  }
}
