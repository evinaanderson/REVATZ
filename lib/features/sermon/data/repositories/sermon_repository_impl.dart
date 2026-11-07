import '../../../../core/errors/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../core/utils/guard.dart';
import '../../domain/entities/sermon.dart';
import '../../domain/repositories/sermon_repository.dart';
import '../datasources/sermon_dao.dart';
import '../models/sermon_model.dart';

class SermonRepositoryImpl implements SermonRepository {
  final SermonDao _dao;
  SermonRepositoryImpl(this._dao);

  List<Sermon> _toEntities(List rows) =>
      rows.map<Sermon>((r) => SermonModel.fromRow(r)).toList();

  @override
  Future<Result<Sermon>> add(Sermon sermon) => guardDb<Sermon>(() async {
        await _dao.insertSermon(SermonModel.fromEntity(sermon).toCompanion());
        return sermon;
      });

  @override
  Future<Result<Sermon>> update(Sermon sermon) => guardDb<Sermon>(() async {
        final n = await _dao.updateById(
            sermon.id, SermonModel.fromEntity(sermon).toCompanion());
        if (n == 0) throw const NotFoundFailure('Sermon introuvable');
        return sermon;
      });

  @override
  Future<Result<void>> delete(String id) => guardDb<void>(() async {
        final n = await _dao.deleteById(id);
        if (n == 0) throw const NotFoundFailure('Sermon introuvable');
      });

  @override
  Future<Result<Sermon>> getById(String id) => guardDb<Sermon>(() async {
        final row = await _dao.getById(id);
        if (row == null) throw const NotFoundFailure('Sermon introuvable');
        return SermonModel.fromRow(row);
      });

  @override
  Future<Result<List<Sermon>>> getAll() =>
      guardDb<List<Sermon>>(() async => _toEntities(await _dao.getAll()));

  @override
  Future<Result<List<Sermon>>> getByCategory(String categoryId) =>
      guardDb<List<Sermon>>(
          () async => _toEntities(await _dao.getByCategory(categoryId)));

  @override
  Future<Result<List<Sermon>>> search(String query) =>
      guardDb<List<Sermon>>(() async => _toEntities(await _dao.search(query)));

  @override
  Future<Result<void>> upsertAll(List<Sermon> sermons) =>
      guardDb<void>(() => _dao.upsertAll(
          sermons.map((s) => SermonModel.fromEntity(s).toCompanion()).toList()));

  @override
  Stream<List<Sermon>> watchAll() =>
      _dao.watchAll().map((rows) => _toEntities(rows));
}
