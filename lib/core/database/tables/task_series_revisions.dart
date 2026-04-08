import 'package:drift/drift.dart';

import 'tags.dart';
import 'task_series.dart';

class TaskSeriesRevisions extends Table {
  TextColumn get id => text()();

  TextColumn get seriesId => text().references(TaskSeries, #id)();

  DateTimeColumn get effectiveFrom => dateTime()();

  DateTimeColumn get effectiveUntil => dateTime().nullable()();

  TextColumn get title => text().withLength(min: 1, max: 255)();

  TextColumn get note => text().nullable()();

  TextColumn get tagId => text().nullable().references(Tags, #id)();

  TextColumn get priority => text().customConstraint(
    "NOT NULL DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high'))",
  )();

  BoolColumn get allDay => boolean().withDefault(const Constant(false))();

  IntColumn get startAtTimePart => integer()();

  IntColumn get dueAtTimePart => integer()();

  IntColumn get durationSeconds => integer()();

  TextColumn get recurrenceType => text().nullable()();

  IntColumn get recurrenceInterval => integer().nullable()();

  TextColumn get recurrenceRuleJson => text().nullable()();

  DateTimeColumn get recurrenceUntil => dateTime().nullable()();

  IntColumn get dangerOffsetValue => integer().nullable()();

  TextColumn get dangerOffsetUnit => text().nullable()();

  BoolColumn get dangerUseWorkday =>
      boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();

  DateTimeColumn get updatedAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
