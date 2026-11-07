import '../../../../core/errors/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../core/utils/guard.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_dao.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryDao _dao;
  CategoryRepositoryImpl(this._dao);

  @override
  Future<Result<Category>> add(Category category) => guardDb<Category>(() async {
        await _dao.insertCategory(CategoryModel.fromEntity(category).toCompanion());
        return category;
      });

  @override
  Future<Result<Category>> update(Category category) =>
      guardDb<Category>(() async {
        final n = await _dao.updateById(
            category.id, CategoryModel.fromEntity(category).toCompanion());
        if (n == 0) throw const NotFoundFailure('Catégorie introuvable');
        return category;
      });

  @override
  Future<Result<void>> delete(String id) => guardDb<void>(() async {
        final n = await _dao.deleteById(id);
        if (n == 0) throw const NotFoundFailure('Catégorie introuvable');
      });

  @override
  Future<Result<List<Category>>> getAll() => guardDb<List<Category>>(() async {
        final rows = await _dao.getAll();
        return rows.map<Category>(CategoryModel.fromRow).toList();
      });

  @override
  Future<Result<Category>> getById(String id) => guardDb<Category>(() async {
        final row = await _dao.getById(id);
        if (row == null) throw const NotFoundFailure('Catégorie introuvable');
        return CategoryModel.fromRow(row);
      });

  @override
  Future<Result<void>> upsertAll(List<Category> categories) =>
      guardDb<void>(() => _dao.upsertAll(
          categories.map((c) => CategoryModel.fromEntity(c).toCompanion()).toList()));

  @override
  Stream<List<Category>> watchAll() => _dao
      .watchAll()
      .map((rows) => rows.map<Category>(CategoryModel.fromRow).toList());
}
