import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_database.dart';
import '../app_database_provider.dart';
import '../database_records.dart';

final taskOccurrenceOverridesRepositoryProvider =
    Provider<TaskOccurrenceOverridesRepository>((ref) {
      return TaskOccurrenceOverridesRepository(ref.watch(appDatabaseProvider));
    });

class TaskOccurrenceOverridesRepository {
  TaskOccurrenceOverridesRepository(this._database);

  final AppDatabase _database;

  Stream<List<TaskOccurrenceOverrideRecord>> watchForSeries(String seriesId) {
    return (_database.select(_database.taskOccurrenceOverrides)
          ..where((entry) => entry.seriesId.equals(seriesId))
          ..orderBy([(entry) => OrderingTerm.asc(entry.createdAt)]))
        .watch();
  }

  Future<TaskOccurrenceOverrideRecord?> getByOccurrence(
    String seriesId,
    String occurrenceKey,
  ) {
    return (_database.select(_database.taskOccurrenceOverrides)..where((entry) {
          return entry.seriesId.equals(seriesId) &
              entry.occurrenceKey.equals(occurrenceKey);
        }))
        .getSingleOrNull();
  }

  Future<void> upsert(TaskOccurrenceOverridesCompanion companion) async {
    await _database
        .into(_database.taskOccurrenceOverrides)
        .insertOnConflictUpdate(companion);
  }

  Future<bool> deleteById(String id) {
    return (_database.delete(
      _database.taskOccurrenceOverrides,
    )..where((entry) => entry.id.equals(id))).go().then((rows) => rows > 0);
  }

  Future<int> deleteForSeries(String seriesId) {
    return (_database.delete(
      _database.taskOccurrenceOverrides,
    )..where((entry) => entry.seriesId.equals(seriesId))).go();
  }
}
