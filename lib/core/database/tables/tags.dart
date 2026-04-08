import 'package:drift/drift.dart';

class Tags extends Table {
  TextColumn get id => text()();

  TextColumn get name => text().withLength(min: 1, max: 64)();

  TextColumn get colorValue => text().withLength(min: 1, max: 32)();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();

  DateTimeColumn get updatedAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
