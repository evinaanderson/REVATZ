import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables/sermons.dart';

part 'sermon_dao.g.dart';

@DriftAccessor(tables: [Sermons])
class SermonDao extends DatabaseAccessor<AppDatabase> with _$SermonDaoMixin {
  SermonDao(super.db);

  Future<void> insertSermon(SermonsCompanion c) => into(sermons).insert(c);

  Future<int> updateById(String id, SermonsCompanion c) =>
      (update(sermons)..where((t) => t.id.equals(id))).write(c);

  Future<int> deleteById(String id) =>
      (delete(sermons)..where((t) => t.id.equals(id))).go();

  Future<SermonRow?> getById(String id) =>
      (select(sermons)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<SermonRow>> getAll() => _ordered(select(sermons)).get();

  Stream<List<SermonRow>> watchAll() => _ordered(select(sermons)).watch();

  Future<List<SermonRow>> getByCategory(String categoryId) =>
      _ordered(select(sermons)..where((t) => t.categoryId.equals(categoryId))).get();

  Future<List<SermonRow>> search(String query) {
    final pattern = '%$query%';
    return _ordered(select(sermons)
          ..where((t) =>
              t.title.like(pattern) |
              t.content.like(pattern) |
              t.tagsJson.like(pattern) |
              t.passagesJson.like(pattern)))
        .get();
  }

  Future<void> upsertAll(List<SermonsCompanion> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(sermons, rows));

  /// Les plus récemment modifiés d'abord.
  SimpleSelectStatement<$SermonsTable, SermonRow> _ordered(
          SimpleSelectStatement<$SermonsTable, SermonRow> q) =>
      q..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);
}
