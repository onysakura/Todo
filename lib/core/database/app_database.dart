import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'app_database_path.dart';
import 'tables/holiday_calendar_entries.dart';
import 'tables/sync_meta_entries.dart';
import 'tables/tags.dart';
import 'tables/task_occurrence_overrides.dart';
import 'tables/task_series.dart';
import 'tables/task_series_revisions.dart';

part 'app_database.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final databasePath = await resolveAppDatabasePath();
    final file = File(databasePath);
    await file.parent.create(recursive: true);
    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(
  tables: [
    Tags,
    TaskSeries,
    TaskSeriesRevisions,
    TaskOccurrenceOverrides,
    HolidayCalendarEntries,
    SyncMetaEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}
