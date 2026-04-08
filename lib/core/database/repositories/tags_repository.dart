import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_database.dart';
import '../app_database_provider.dart';
import '../database_records.dart';

final tagsRepositoryProvider = Provider<TagsRepository>((ref) {
  return TagsRepository(ref.watch(appDatabaseProvider));
});

class TagsRepository {
  TagsRepository(this._database);

  final AppDatabase _database;

  Stream<List<TagRecord>> watchAll() {
    return (_database.select(_database.tags)..orderBy([
          (tag) => OrderingTerm.asc(tag.sortOrder),
          (tag) => OrderingTerm.asc(tag.name),
        ]))
        .watch();
  }

  Future<List<TagRecord>> getAll() {
    return (_database.select(_database.tags)..orderBy([
          (tag) => OrderingTerm.asc(tag.sortOrder),
          (tag) => OrderingTerm.asc(tag.name),
        ]))
        .get();
  }

  Future<TagRecord?> getById(String id) {
    return (_database.select(
      _database.tags,
    )..where((tag) => tag.id.equals(id))).getSingleOrNull();
  }

  Future<void> upsert(TagsCompanion companion) async {
    await _database.into(_database.tags).insertOnConflictUpdate(companion);
  }

  Future<bool> deleteById(String id) {
    return (_database.delete(
      _database.tags,
    )..where((tag) => tag.id.equals(id))).go().then((rows) => rows > 0);
  }
}
