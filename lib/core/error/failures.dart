/// Base class for failures in the application.
/// Used by use cases / repository to represent domain-level failures
/// without depending on specific exceptions (e.g. network, cache).
abstract class Failure {
  final String message;

  const Failure(this.message);
}

/// Server/API related failure (e.g. 4xx, 5xx, timeouts).
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error']);
}

/// Local storage/cache related failure.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error']);
}

/// Validation failure (e.g. invalid input from API).
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation error']);
}
