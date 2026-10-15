/// Typed domain/application failure.
sealed class Failure {
  const Failure(this.message);

  final String message;
}

/// Failure caused by network or remote I/O.
final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error']);
}

/// Failure caused by unexpected local/runtime errors.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Unexpected error']);
}
