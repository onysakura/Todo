import 'package:drift/drift.dart';

import 'tags.dart';

class TaskSeries extends Table {
  TextColumn get id => text()();

  TextColumn get title => text().withLength(min: 1, max: 255)();

  TextColumn get note => text().nullable()();

  TextColumn get tagId => text().nullable().references(Tags, #id)();

  TextColumn get priority => text().customConstraint(
    "NOT NULL DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high'))",
  )();

  BoolColumn get allDay => boolean().withDefault(const Constant(false))();

  DateTimeColumn get startAt => dateTime()();

  DateTimeColumn get dueAt => dateTime()();

  TextColumn get statusDefault => text().customConstraint(
    "NOT NULL DEFAULT 'pending' CHECK (status_default IN ('pending', 'completed', 'cancelled'))",
  )();

  IntColumn get dangerOffsetValue => integer().nullable()();

  TextColumn get dangerOffsetUnit => text().nullable()();

  BoolColumn get dangerUseWorkday =>
      boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();

  DateTimeColumn get updatedAt => dateTime().clientDefault(DateTime.now)();

  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
