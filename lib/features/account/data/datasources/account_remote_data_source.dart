abstract class AccountRemoteDataSource {
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
  });
}
