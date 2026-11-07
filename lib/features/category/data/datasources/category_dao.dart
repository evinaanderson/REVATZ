import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables/categories.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase> with _$CategoryDaoMixin {
  CategoryDao(super.db);

  Future<void> insertCategory(CategoriesCompanion c) => into(categories).insert(c);

  Future<int> updateById(String id, CategoriesCompanion c) =>
      (update(categories)..where((t) => t.id.equals(id))).write(c);

  Future<int> deleteById(String id) =>
      (delete(categories)..where((t) => t.id.equals(id))).go();

  Future<CategoryRow?> getById(String id) =>
      (select(categories)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<CategoryRow>> getAll() =>
      (select(categories)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();

  Stream<List<CategoryRow>> watchAll() =>
      (select(categories)..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();

  Future<void> upsertAll(List<CategoriesCompanion> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(categories, rows));
}
