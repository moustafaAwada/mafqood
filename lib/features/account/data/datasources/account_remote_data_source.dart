import 'dart:io';

abstract class AccountRemoteDataSource {
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
  });

  Future<dynamic> updateUserInfo({required String name, required String phoneNumber});
  
  Future<dynamic> updateProfilePicture(File image);

  /// Get current user profile (GET /me)
  Future<dynamic> getCurrentUserProfile();
}
