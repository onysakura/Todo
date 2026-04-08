import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'app_database_path.dart';

part 'app_database.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final databasePath = await resolveAppDatabasePath();
    final file = File(databasePath);
    await file.parent.create(recursive: true);
    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(tables: [])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}
