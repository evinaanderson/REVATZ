import '../result/result.dart';

/// Contrat commun des cas d'usage.
abstract class UseCase<T, P> {
  Future<Result<T>> call(P params);
}

class NoParams {
  const NoParams();
}
