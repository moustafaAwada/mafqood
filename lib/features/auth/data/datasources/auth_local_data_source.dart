abstract class AuthLocalDataSource {
  Future<bool> isLoggedIn();

  Future<Map<String, dynamic>?> getStoredUserData();

  Future<String?> getAccessToken();

  Future<String?> getRefreshToken();

  Future<DateTime?> getRefreshTokenExpiration();

  Future<void> saveUserData(Map<String, dynamic> data);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
    required DateTime refreshTokenExpiration,
  });

  Future<void> clearAll();
}
