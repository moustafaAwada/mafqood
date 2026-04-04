abstract class AppException implements Exception {
  final String message;

  AppException(this.message);

  @override
  String toString() => message;
}

class ServerException extends AppException {
  ServerException([super.message = 'Server error']);
}

class CacheException extends AppException {
  CacheException([super.message = 'Cache error']);
}
