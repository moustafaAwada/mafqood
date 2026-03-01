abstract class AuthLocalDataSource {
  Future<bool> isLoggedIn();

  Future<Map<String, dynamic>?> getStoredUserData();

  Future<void> saveUserData(Map<String, dynamic> data);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
    required DateTime refreshTokenExpiration,
  });

  Future<void> clearAll();
}
