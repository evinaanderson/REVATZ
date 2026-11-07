// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sermon_dao.dart';

// ignore_for_file: type=lint
mixin _$SermonDaoMixin on DatabaseAccessor<AppDatabase> {
  $CategoriesTable get categories => attachedDatabase.categories;
  $SermonsTable get sermons => attachedDatabase.sermons;
  SermonDaoManager get managers => SermonDaoManager(this);
}

class SermonDaoManager {
  final _$SermonDaoMixin _db;
  SermonDaoManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$SermonsTableTableManager get sermons =>
      $$SermonsTableTableManager(_db.attachedDatabase, _db.sermons);
}
