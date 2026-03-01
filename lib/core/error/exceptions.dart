/// Base exception for app-level errors.
/// Data layer throws these; repository impl maps them to [Failure] for domain.
abstract class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => message;
}

/// Thrown when remote API call fails (network, 4xx/5xx, etc.).
class ServerException extends AppException {
  const ServerException([super.message = 'Server error']);
}

/// Thrown when local storage/cache operation fails.
class CacheException extends AppException {
  const CacheException([super.message = 'Cache error']);
}
