
import '../../../../core/result/result.dart';
import 'package:cermum/features/sermum/domain/entities/sermon.dart';

abstract class SermonRepository {
  Future<Result<Sermon>> add(Sermon sermon);
  Future<Result<Sermon>> update(Sermon sermon);
  Future<Result<void>> delete(String id);
  Future<Result<Sermon>> getById(String id);
  Future<Result<List<Sermon>>> getAll();
  Future<Result<List<Sermon>>> getByCategory(String categoryId);
  Future<Result<List<Sermon>>> search(String query);

  /// Insère ou met à jour plusieurs sermons (utilisé par la restauration).
  Future<Result<void>> upsertAll(List<Sermon> sermons);

  /// Flux réactif (Drift) pour rafraîchir l'écran automatiquement.
  Stream<List<Sermon>> watchAll();
}
