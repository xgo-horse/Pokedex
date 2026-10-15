/// Result type for operations that can fail.
sealed class Either<L, R> {
  const Either();
}

/// Failure branch of [Either].
final class Left<L, R> extends Either<L, R> {
  const Left(this.value);

  final L value;
}

/// Success branch of [Either].
final class Right<L, R> extends Either<L, R> {
  const Right(this.value);

  final R value;
}
