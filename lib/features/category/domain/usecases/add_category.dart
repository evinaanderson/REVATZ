import '../../../../core/errors/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/id_generator.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class AddCategoryParams {
  final String name;
  final int? colorValue;
  const AddCategoryParams({required this.name, this.colorValue});
}

class AddCategory implements UseCase<Category, AddCategoryParams> {
  final CategoryRepository _repository;
  final IdGenerator _ids;
  AddCategory(this._repository, this._ids);

  @override
  Future<Result<Category>> call(AddCategoryParams p) async {
    final name = p.name.trim();
    if (name.isEmpty) {
      return const Err(ValidationFailure('Le nom de la catégorie est obligatoire'));
    }
    final existing = await _repository.getAll();
    final list = existing.valueOrNull ?? const <Category>[];
    if (list.any((c) => c.name.toLowerCase() == name.toLowerCase())) {
      return const Err(ValidationFailure('Cette catégorie existe déjà'));
    }
    return _repository.add(Category(
      id: _ids.generate(),
      name: name,
      colorValue: p.colorValue,
      createdAt: DateTime.now(),
    ));
  }
}
