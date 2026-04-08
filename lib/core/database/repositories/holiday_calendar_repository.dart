import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_database.dart';
import '../app_database_provider.dart';
import '../database_records.dart';

final holidayCalendarRepositoryProvider = Provider<HolidayCalendarRepository>((
  ref,
) {
  return HolidayCalendarRepository(ref.watch(appDatabaseProvider));
});

class HolidayCalendarRepository {
  HolidayCalendarRepository(this._database);

  final AppDatabase _database;

  Future<HolidayCalendarEntryRecord?> getByDate(String date) {
    return (_database.select(
      _database.holidayCalendarEntries,
    )..where((entry) => entry.date.equals(date))).getSingleOrNull();
  }

  Future<List<HolidayCalendarEntryRecord>> getByDateRange(
    String startDate,
    String endDate,
  ) {
    return (_database.select(_database.holidayCalendarEntries)
          ..where((entry) {
            return entry.date.isBiggerOrEqualValue(startDate) &
                entry.date.isSmallerOrEqualValue(endDate);
          })
          ..orderBy([(entry) => OrderingTerm.asc(entry.date)]))
        .get();
  }

  Future<void> replaceAll(
    Iterable<HolidayCalendarEntriesCompanion> entries,
  ) async {
    await _database.transaction(() async {
      await _database.delete(_database.holidayCalendarEntries).go();
      await _database.batch((batch) {
        batch.insertAll(
          _database.holidayCalendarEntries,
          entries.toList(),
          mode: InsertMode.insertOrReplace,
        );
      });
    });
  }
}
