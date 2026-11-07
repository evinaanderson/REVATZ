import 'package:drift/drift.dart';

import 'categories.dart';

/// Les listes (passages, photos, tags) sont stockées en JSON texte :
/// simple, et elles ne sont jamais interrogées individuellement.
@DataClassName('SermonRow')
@TableIndex(name: 'idx_sermons_category', columns: {#categoryId})
class Sermons extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get categoryId =>
      text().references(Categories, #id, onDelete: KeyAction.restrict)();
  TextColumn get content => text().withDefault(const Constant(''))();
  TextColumn get passagesJson => text().withDefault(const Constant('[]'))();
  TextColumn get photosJson => text().withDefault(const Constant('[]'))();
  TextColumn get tagsJson => text().withDefault(const Constant('[]'))();
  DateTimeColumn get preachedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  /// 0 = pending, 1 = synced (index de l'enum SyncStatus)
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
