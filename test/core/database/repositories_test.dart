import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/core/database/app_database.dart';
import 'package:todo_app/core/database/repositories/sync_meta_repository.dart';
import 'package:todo_app/core/database/repositories/tags_repository.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('TagsRepository 支持 upsert 与查询', () async {
    final repository = TagsRepository(database);

    await repository.upsert(
      TagsCompanion.insert(id: 'tag-work', name: '工作', colorValue: '#0F766E'),
    );

    final item = await repository.getById('tag-work');

    expect(item, isNotNull);
    expect(item?.name, '工作');
  });

  test('SyncMetaRepository 支持写入与读取', () async {
    final repository = SyncMetaRepository(database);

    await repository.putValue(
      key: 'last_sync_at',
      value: '2026-04-08T16:00:00+08:00',
    );

    final item = await repository.getByKey('last_sync_at');

    expect(item, isNotNull);
    expect(item?.value, '2026-04-08T16:00:00+08:00');
  });
}
