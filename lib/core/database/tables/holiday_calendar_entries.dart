import 'package:drift/drift.dart';

class HolidayCalendarEntries extends Table {
  TextColumn get date => text()();

  TextColumn get dayType => text().customConstraint(
    "NOT NULL CHECK (day_type IN ('workday', 'holiday', 'weekend_makeup'))",
  )();

  TextColumn get name => text().nullable()();

  TextColumn get source => text().nullable()();

  DateTimeColumn get updatedAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column<Object>> get primaryKey => {date};
}
