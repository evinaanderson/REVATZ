import '../errors/failures.dart';

/// Résultat d'une opération : succès avec une valeur, ou échec avec un [Failure].
sealed class Result<T> {
  const Result();

  R when<R>({
    required R Function(T value) success,
    required R Function(Failure failure) failure,
  }) {
    final self = this;
    return switch (self) {
      Success<T>() => success(self.value),
      Err<T>() => failure(self.failure),
    };
  }

  bool get isSuccess => this is Success<T>;
  T? get valueOrNull => switch (this) {
        Success<T>(:final value) => value,
        Err<T>() => null,
      };
  Failure? get failureOrNull => switch (this) {
        Success<T>() => null,
        Err<T>(:final failure) => failure,
      };
}

final class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

final class Err<T> extends Result<T> {
  final Failure failure;
  const Err(this.failure);
}
