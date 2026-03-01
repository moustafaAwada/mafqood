import 'package:mafqood/features/auth/data/datasources/auth_local_data_source.dart';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final Map<String, dynamic> _userData = {};
  bool _hasValidSession = false;

  @override
  Future<bool> isLoggedIn() async => _hasValidSession;

  @override
  Future<Map<String, dynamic>?> getStoredUserData() async {
    if (_userData.isEmpty) return null;
    return Map<String, dynamic>.from(_userData);
  }

  @override
  Future<void> saveUserData(Map<String, dynamic> data) async {
    _userData.clear();
    _userData.addAll(data);
    _hasValidSession = true;
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
    required DateTime refreshTokenExpiration,
  }) async {
    _hasValidSession = true;
  }

  @override
  Future<void> clearAll() async {
    _userData.clear();
    _hasValidSession = false;
  }
}
