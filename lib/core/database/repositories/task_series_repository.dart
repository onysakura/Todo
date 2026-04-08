import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_database.dart';
import '../app_database_provider.dart';
import '../database_records.dart';

final taskSeriesRepositoryProvider = Provider<TaskSeriesRepository>((ref) {
  return TaskSeriesRepository(ref.watch(appDatabaseProvider));
});

class TaskSeriesRepository {
  TaskSeriesRepository(this._database);

  final AppDatabase _database;

  Stream<List<TaskSeriesRecord>> watchAll() {
    return (_database.select(_database.taskSeries)..orderBy([
          (series) => OrderingTerm.asc(series.dueAt),
          (series) => OrderingTerm.asc(series.createdAt),
        ]))
        .watch();
  }

  Future<List<TaskSeriesRecord>> getAll() {
    return (_database.select(_database.taskSeries)..orderBy([
          (series) => OrderingTerm.asc(series.dueAt),
          (series) => OrderingTerm.asc(series.createdAt),
        ]))
        .get();
  }

  Future<TaskSeriesRecord?> getById(String id) {
    return (_database.select(
      _database.taskSeries,
    )..where((series) => series.id.equals(id))).getSingleOrNull();
  }

  Future<void> upsert(TaskSeriesCompanion companion) async {
    await _database
        .into(_database.taskSeries)
        .insertOnConflictUpdate(companion);
  }

  Future<bool> deleteById(String id) {
    return (_database.delete(
      _database.taskSeries,
    )..where((series) => series.id.equals(id))).go().then((rows) => rows > 0);
  }
}
