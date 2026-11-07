import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../features/category/data/datasources/category_dao.dart';
import '../../features/sermon/data/datasources/sermon_dao.dart';
import 'tables/categories.dart';
import 'tables/sermons.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Categories, Sermons], daos: [CategoryDao, SermonDao])
class AppDatabase extends _$AppDatabase {
  /// En test, passez `NativeDatabase.memory()`.
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'sermons_db'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        // Exemple pour plus tard :
        // onUpgrade: (m, from, to) async { if (from < 2) { ... } },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
