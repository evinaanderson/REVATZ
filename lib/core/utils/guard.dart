import '../errors/failures.dart';
import '../result/result.dart';

/// Exécute une opération base de données et convertit toute exception en [Failure].
Future<Result<T>> guardDb<T>(Future<T> Function() body) async {
  try {
    return Success<T>(await body());
  } on Failure catch (f) {
    return Err<T>(f);
  } catch (e) {
    return Err<T>(DatabaseFailure('Erreur de base de données : $e'));
  }
}
