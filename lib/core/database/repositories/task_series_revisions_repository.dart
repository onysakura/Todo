import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_database.dart';
import '../app_database_provider.dart';
import '../database_records.dart';

final taskSeriesRevisionsRepositoryProvider =
    Provider<TaskSeriesRevisionsRepository>((ref) {
      return TaskSeriesRevisionsRepository(ref.watch(appDatabaseProvider));
    });

class TaskSeriesRevisionsRepository {
  TaskSeriesRevisionsRepository(this._database);

  final AppDatabase _database;

  Stream<List<TaskSeriesRevisionRecord>> watchForSeries(String seriesId) {
    return (_database.select(_database.taskSeriesRevisions)
          ..where((revision) => revision.seriesId.equals(seriesId))
          ..orderBy([(revision) => OrderingTerm.asc(revision.effectiveFrom)]))
        .watch();
  }

  Future<List<TaskSeriesRevisionRecord>> getForSeries(String seriesId) {
    return (_database.select(_database.taskSeriesRevisions)
          ..where((revision) => revision.seriesId.equals(seriesId))
          ..orderBy([(revision) => OrderingTerm.asc(revision.effectiveFrom)]))
        .get();
  }

  Future<void> upsert(TaskSeriesRevisionsCompanion companion) async {
    await _database
        .into(_database.taskSeriesRevisions)
        .insertOnConflictUpdate(companion);
  }

  Future<bool> deleteById(String id) {
    return (_database.delete(_database.taskSeriesRevisions)
          ..where((revision) => revision.id.equals(id)))
        .go()
        .then((rows) => rows > 0);
  }

  Future<int> deleteForSeries(String seriesId) {
    return (_database.delete(
      _database.taskSeriesRevisions,
    )..where((revision) => revision.seriesId.equals(seriesId))).go();
  }
}
