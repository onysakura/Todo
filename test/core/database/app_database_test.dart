import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/core/database/app_database.dart';

void main() {
  test('数据库包含核心表结构', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    final result = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name",
        )
        .get();

    final tableNames = result.map((row) => row.read<String>('name')).toSet();

    expect(
      tableNames,
      containsAll({
        'tags',
        'task_series',
        'task_series_revisions',
        'task_occurrence_overrides',
        'holiday_calendar_entries',
        'sync_meta_entries',
      }),
    );
  });
}
