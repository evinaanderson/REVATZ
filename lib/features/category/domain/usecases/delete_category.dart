import '../../../../core/errors/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../sermon/domain/repositories/sermon_repository.dart';
import '../repositories/category_repository.dart';

/// Refuse la suppression si la catégorie contient encore des sermons.
class DeleteCategory implements UseCase<void, String> {
  final CategoryRepository _categories;
  final SermonRepository _sermons;
  DeleteCategory(this._categories, this._sermons);

  @override
  Future<Result<void>> call(String id) async {
    final sermons = await _sermons.getByCategory(id);
    if (sermons.failureOrNull != null) return Err(sermons.failureOrNull!);
    if ((sermons.valueOrNull ?? const []).isNotEmpty) {
      return const Err(ValidationFailure(
          'Déplacez ou supprimez les sermons de cette catégorie d\'abord'));
    }
    return _categories.delete(id);
  }
}
