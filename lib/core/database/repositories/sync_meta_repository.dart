import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_database.dart';
import '../app_database_provider.dart';
import '../database_records.dart';

final syncMetaRepositoryProvider = Provider<SyncMetaRepository>((ref) {
  return SyncMetaRepository(ref.watch(appDatabaseProvider));
});

class SyncMetaRepository {
  SyncMetaRepository(this._database);

  final AppDatabase _database;

  Future<SyncMetaEntryRecord?> getByKey(String key) {
    return (_database.select(
      _database.syncMetaEntries,
    )..where((entry) => entry.key.equals(key))).getSingleOrNull();
  }

  Future<void> putValue({required String key, required String value}) async {
    await _database
        .into(_database.syncMetaEntries)
        .insertOnConflictUpdate(
          SyncMetaEntriesCompanion.insert(
            key: key,
            value: value,
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<bool> deleteByKey(String key) {
    return (_database.delete(
      _database.syncMetaEntries,
    )..where((entry) => entry.key.equals(key))).go().then((rows) => rows > 0);
  }
}
