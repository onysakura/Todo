import 'package:drift/drift.dart';

import 'tags.dart';
import 'task_series.dart';

class TaskOccurrenceOverrides extends Table {
  TextColumn get id => text()();

  TextColumn get seriesId => text().references(TaskSeries, #id)();

  TextColumn get occurrenceKey => text()();

  TextColumn get overrideType => text().customConstraint(
    "NOT NULL DEFAULT 'override' CHECK (override_type IN ('override', 'cancel', 'detach'))",
  )();

  DateTimeColumn get overrideStartAt => dateTime().nullable()();

  DateTimeColumn get overrideDueAt => dateTime().nullable()();

  DateTimeColumn get overrideDangerAt => dateTime().nullable()();

  TextColumn get overrideTitle => text().nullable()();

  TextColumn get overrideNote => text().nullable()();

  TextColumn get overrideTagId => text().nullable().references(Tags, #id)();

  TextColumn get overridePriority => text().nullable()();

  TextColumn get status => text().nullable().customConstraint(
    "CHECK (status IN ('pending', 'completed', 'cancelled'))",
  )();

  BoolColumn get detachedAsSingle =>
      boolean().withDefault(const Constant(false))();

  DateTimeColumn get completedAt => dateTime().nullable()();

  DateTimeColumn get cancelledAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();

  DateTimeColumn get updatedAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {seriesId, occurrenceKey},
  ];
}
