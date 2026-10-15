import 'failure.dart';

/// Shared sealed UI load state for Cubits.
sealed class LoadState<T> {
  const LoadState();
}

final class LoadInitial<T> extends LoadState<T> {
  const LoadInitial();
}

final class LoadLoading<T> extends LoadState<T> {
  const LoadLoading();
}

final class LoadSuccess<T> extends LoadState<T> {
  const LoadSuccess(this.data);

  final T data;
}

final class LoadFailure<T> extends LoadState<T> {
  const LoadFailure(this.failure);

  final Failure failure;
}
