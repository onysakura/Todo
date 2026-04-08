// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<String> colorValue = GeneratedColumn<String>(
    'color_value',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 32,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    colorValue,
    sortOrder,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_value'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final String id;
  final String name;
  final String colorValue;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Tag({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['color_value'] = Variable<String>(colorValue);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      colorValue: Value(colorValue),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Tag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      colorValue: serializer.fromJson<String>(json['colorValue']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'colorValue': serializer.toJson<String>(colorValue),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Tag copyWith({
    String? id,
    String? name,
    String? colorValue,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Tag(
    id: id ?? this.id,
    name: name ?? this.name,
    colorValue: colorValue ?? this.colorValue,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorValue: $colorValue, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, colorValue, sortOrder, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.name == this.name &&
          other.colorValue == this.colorValue &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> colorValue;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String name,
    required String colorValue,
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       colorValue = Value(colorValue);
  static Insertable<Tag> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? colorValue,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (colorValue != null) 'color_value': colorValue,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? colorValue,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<String>(colorValue.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorValue: $colorValue, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaskSeriesTable extends TaskSeries
    with TableInfo<$TaskSeriesTable, TaskSery> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskSeriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tag_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id)',
    ),
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT \'medium\' CHECK (priority IN (\'low\', \'medium\', \'high\'))',
    defaultValue: const CustomExpression('\'medium\''),
  );
  static const VerificationMeta _allDayMeta = const VerificationMeta('allDay');
  @override
  late final GeneratedColumn<bool> allDay = GeneratedColumn<bool>(
    'all_day',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("all_day" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _startAtMeta = const VerificationMeta(
    'startAt',
  );
  @override
  late final GeneratedColumn<DateTime> startAt = GeneratedColumn<DateTime>(
    'start_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusDefaultMeta = const VerificationMeta(
    'statusDefault',
  );
  @override
  late final GeneratedColumn<String> statusDefault = GeneratedColumn<String>(
    'status_default',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT \'pending\' CHECK (status_default IN (\'pending\', \'completed\', \'cancelled\'))',
    defaultValue: const CustomExpression('\'pending\''),
  );
  static const VerificationMeta _dangerOffsetValueMeta = const VerificationMeta(
    'dangerOffsetValue',
  );
  @override
  late final GeneratedColumn<int> dangerOffsetValue = GeneratedColumn<int>(
    'danger_offset_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dangerOffsetUnitMeta = const VerificationMeta(
    'dangerOffsetUnit',
  );
  @override
  late final GeneratedColumn<String> dangerOffsetUnit = GeneratedColumn<String>(
    'danger_offset_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dangerUseWorkdayMeta = const VerificationMeta(
    'dangerUseWorkday',
  );
  @override
  late final GeneratedColumn<bool> dangerUseWorkday = GeneratedColumn<bool>(
    'danger_use_workday',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("danger_use_workday" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    note,
    tagId,
    priority,
    allDay,
    startAt,
    dueAt,
    statusDefault,
    dangerOffsetValue,
    dangerOffsetUnit,
    dangerUseWorkday,
    createdAt,
    updatedAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_series';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskSery> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('all_day')) {
      context.handle(
        _allDayMeta,
        allDay.isAcceptableOrUnknown(data['all_day']!, _allDayMeta),
      );
    }
    if (data.containsKey('start_at')) {
      context.handle(
        _startAtMeta,
        startAt.isAcceptableOrUnknown(data['start_at']!, _startAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startAtMeta);
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    } else if (isInserting) {
      context.missing(_dueAtMeta);
    }
    if (data.containsKey('status_default')) {
      context.handle(
        _statusDefaultMeta,
        statusDefault.isAcceptableOrUnknown(
          data['status_default']!,
          _statusDefaultMeta,
        ),
      );
    }
    if (data.containsKey('danger_offset_value')) {
      context.handle(
        _dangerOffsetValueMeta,
        dangerOffsetValue.isAcceptableOrUnknown(
          data['danger_offset_value']!,
          _dangerOffsetValueMeta,
        ),
      );
    }
    if (data.containsKey('danger_offset_unit')) {
      context.handle(
        _dangerOffsetUnitMeta,
        dangerOffsetUnit.isAcceptableOrUnknown(
          data['danger_offset_unit']!,
          _dangerOffsetUnitMeta,
        ),
      );
    }
    if (data.containsKey('danger_use_workday')) {
      context.handle(
        _dangerUseWorkdayMeta,
        dangerUseWorkday.isAcceptableOrUnknown(
          data['danger_use_workday']!,
          _dangerUseWorkdayMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskSery map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskSery(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_id'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority'],
      )!,
      allDay: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}all_day'],
      )!,
      startAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_at'],
      )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      )!,
      statusDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status_default'],
      )!,
      dangerOffsetValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}danger_offset_value'],
      ),
      dangerOffsetUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}danger_offset_unit'],
      ),
      dangerUseWorkday: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}danger_use_workday'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
    );
  }

  @override
  $TaskSeriesTable createAlias(String alias) {
    return $TaskSeriesTable(attachedDatabase, alias);
  }
}

class TaskSery extends DataClass implements Insertable<TaskSery> {
  final String id;
  final String title;
  final String? note;
  final String? tagId;
  final String priority;
  final bool allDay;
  final DateTime startAt;
  final DateTime dueAt;
  final String statusDefault;
  final int? dangerOffsetValue;
  final String? dangerOffsetUnit;
  final bool dangerUseWorkday;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;
  const TaskSery({
    required this.id,
    required this.title,
    this.note,
    this.tagId,
    required this.priority,
    required this.allDay,
    required this.startAt,
    required this.dueAt,
    required this.statusDefault,
    this.dangerOffsetValue,
    this.dangerOffsetUnit,
    required this.dangerUseWorkday,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || tagId != null) {
      map['tag_id'] = Variable<String>(tagId);
    }
    map['priority'] = Variable<String>(priority);
    map['all_day'] = Variable<bool>(allDay);
    map['start_at'] = Variable<DateTime>(startAt);
    map['due_at'] = Variable<DateTime>(dueAt);
    map['status_default'] = Variable<String>(statusDefault);
    if (!nullToAbsent || dangerOffsetValue != null) {
      map['danger_offset_value'] = Variable<int>(dangerOffsetValue);
    }
    if (!nullToAbsent || dangerOffsetUnit != null) {
      map['danger_offset_unit'] = Variable<String>(dangerOffsetUnit);
    }
    map['danger_use_workday'] = Variable<bool>(dangerUseWorkday);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    return map;
  }

  TaskSeriesCompanion toCompanion(bool nullToAbsent) {
    return TaskSeriesCompanion(
      id: Value(id),
      title: Value(title),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      tagId: tagId == null && nullToAbsent
          ? const Value.absent()
          : Value(tagId),
      priority: Value(priority),
      allDay: Value(allDay),
      startAt: Value(startAt),
      dueAt: Value(dueAt),
      statusDefault: Value(statusDefault),
      dangerOffsetValue: dangerOffsetValue == null && nullToAbsent
          ? const Value.absent()
          : Value(dangerOffsetValue),
      dangerOffsetUnit: dangerOffsetUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(dangerOffsetUnit),
      dangerUseWorkday: Value(dangerUseWorkday),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory TaskSery.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskSery(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      note: serializer.fromJson<String?>(json['note']),
      tagId: serializer.fromJson<String?>(json['tagId']),
      priority: serializer.fromJson<String>(json['priority']),
      allDay: serializer.fromJson<bool>(json['allDay']),
      startAt: serializer.fromJson<DateTime>(json['startAt']),
      dueAt: serializer.fromJson<DateTime>(json['dueAt']),
      statusDefault: serializer.fromJson<String>(json['statusDefault']),
      dangerOffsetValue: serializer.fromJson<int?>(json['dangerOffsetValue']),
      dangerOffsetUnit: serializer.fromJson<String?>(json['dangerOffsetUnit']),
      dangerUseWorkday: serializer.fromJson<bool>(json['dangerUseWorkday']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'note': serializer.toJson<String?>(note),
      'tagId': serializer.toJson<String?>(tagId),
      'priority': serializer.toJson<String>(priority),
      'allDay': serializer.toJson<bool>(allDay),
      'startAt': serializer.toJson<DateTime>(startAt),
      'dueAt': serializer.toJson<DateTime>(dueAt),
      'statusDefault': serializer.toJson<String>(statusDefault),
      'dangerOffsetValue': serializer.toJson<int?>(dangerOffsetValue),
      'dangerOffsetUnit': serializer.toJson<String?>(dangerOffsetUnit),
      'dangerUseWorkday': serializer.toJson<bool>(dangerUseWorkday),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  TaskSery copyWith({
    String? id,
    String? title,
    Value<String?> note = const Value.absent(),
    Value<String?> tagId = const Value.absent(),
    String? priority,
    bool? allDay,
    DateTime? startAt,
    DateTime? dueAt,
    String? statusDefault,
    Value<int?> dangerOffsetValue = const Value.absent(),
    Value<String?> dangerOffsetUnit = const Value.absent(),
    bool? dangerUseWorkday,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => TaskSery(
    id: id ?? this.id,
    title: title ?? this.title,
    note: note.present ? note.value : this.note,
    tagId: tagId.present ? tagId.value : this.tagId,
    priority: priority ?? this.priority,
    allDay: allDay ?? this.allDay,
    startAt: startAt ?? this.startAt,
    dueAt: dueAt ?? this.dueAt,
    statusDefault: statusDefault ?? this.statusDefault,
    dangerOffsetValue: dangerOffsetValue.present
        ? dangerOffsetValue.value
        : this.dangerOffsetValue,
    dangerOffsetUnit: dangerOffsetUnit.present
        ? dangerOffsetUnit.value
        : this.dangerOffsetUnit,
    dangerUseWorkday: dangerUseWorkday ?? this.dangerUseWorkday,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  TaskSery copyWithCompanion(TaskSeriesCompanion data) {
    return TaskSery(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      note: data.note.present ? data.note.value : this.note,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
      priority: data.priority.present ? data.priority.value : this.priority,
      allDay: data.allDay.present ? data.allDay.value : this.allDay,
      startAt: data.startAt.present ? data.startAt.value : this.startAt,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      statusDefault: data.statusDefault.present
          ? data.statusDefault.value
          : this.statusDefault,
      dangerOffsetValue: data.dangerOffsetValue.present
          ? data.dangerOffsetValue.value
          : this.dangerOffsetValue,
      dangerOffsetUnit: data.dangerOffsetUnit.present
          ? data.dangerOffsetUnit.value
          : this.dangerOffsetUnit,
      dangerUseWorkday: data.dangerUseWorkday.present
          ? data.dangerUseWorkday.value
          : this.dangerUseWorkday,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskSery(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('tagId: $tagId, ')
          ..write('priority: $priority, ')
          ..write('allDay: $allDay, ')
          ..write('startAt: $startAt, ')
          ..write('dueAt: $dueAt, ')
          ..write('statusDefault: $statusDefault, ')
          ..write('dangerOffsetValue: $dangerOffsetValue, ')
          ..write('dangerOffsetUnit: $dangerOffsetUnit, ')
          ..write('dangerUseWorkday: $dangerUseWorkday, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    note,
    tagId,
    priority,
    allDay,
    startAt,
    dueAt,
    statusDefault,
    dangerOffsetValue,
    dangerOffsetUnit,
    dangerUseWorkday,
    createdAt,
    updatedAt,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskSery &&
          other.id == this.id &&
          other.title == this.title &&
          other.note == this.note &&
          other.tagId == this.tagId &&
          other.priority == this.priority &&
          other.allDay == this.allDay &&
          other.startAt == this.startAt &&
          other.dueAt == this.dueAt &&
          other.statusDefault == this.statusDefault &&
          other.dangerOffsetValue == this.dangerOffsetValue &&
          other.dangerOffsetUnit == this.dangerOffsetUnit &&
          other.dangerUseWorkday == this.dangerUseWorkday &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.archivedAt == this.archivedAt);
}

class TaskSeriesCompanion extends UpdateCompanion<TaskSery> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> note;
  final Value<String?> tagId;
  final Value<String> priority;
  final Value<bool> allDay;
  final Value<DateTime> startAt;
  final Value<DateTime> dueAt;
  final Value<String> statusDefault;
  final Value<int?> dangerOffsetValue;
  final Value<String?> dangerOffsetUnit;
  final Value<bool> dangerUseWorkday;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> archivedAt;
  final Value<int> rowid;
  const TaskSeriesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.note = const Value.absent(),
    this.tagId = const Value.absent(),
    this.priority = const Value.absent(),
    this.allDay = const Value.absent(),
    this.startAt = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.statusDefault = const Value.absent(),
    this.dangerOffsetValue = const Value.absent(),
    this.dangerOffsetUnit = const Value.absent(),
    this.dangerUseWorkday = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskSeriesCompanion.insert({
    required String id,
    required String title,
    this.note = const Value.absent(),
    this.tagId = const Value.absent(),
    this.priority = const Value.absent(),
    this.allDay = const Value.absent(),
    required DateTime startAt,
    required DateTime dueAt,
    this.statusDefault = const Value.absent(),
    this.dangerOffsetValue = const Value.absent(),
    this.dangerOffsetUnit = const Value.absent(),
    this.dangerUseWorkday = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       startAt = Value(startAt),
       dueAt = Value(dueAt);
  static Insertable<TaskSery> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? note,
    Expression<String>? tagId,
    Expression<String>? priority,
    Expression<bool>? allDay,
    Expression<DateTime>? startAt,
    Expression<DateTime>? dueAt,
    Expression<String>? statusDefault,
    Expression<int>? dangerOffsetValue,
    Expression<String>? dangerOffsetUnit,
    Expression<bool>? dangerUseWorkday,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (note != null) 'note': note,
      if (tagId != null) 'tag_id': tagId,
      if (priority != null) 'priority': priority,
      if (allDay != null) 'all_day': allDay,
      if (startAt != null) 'start_at': startAt,
      if (dueAt != null) 'due_at': dueAt,
      if (statusDefault != null) 'status_default': statusDefault,
      if (dangerOffsetValue != null) 'danger_offset_value': dangerOffsetValue,
      if (dangerOffsetUnit != null) 'danger_offset_unit': dangerOffsetUnit,
      if (dangerUseWorkday != null) 'danger_use_workday': dangerUseWorkday,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskSeriesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? note,
    Value<String?>? tagId,
    Value<String>? priority,
    Value<bool>? allDay,
    Value<DateTime>? startAt,
    Value<DateTime>? dueAt,
    Value<String>? statusDefault,
    Value<int?>? dangerOffsetValue,
    Value<String?>? dangerOffsetUnit,
    Value<bool>? dangerUseWorkday,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? archivedAt,
    Value<int>? rowid,
  }) {
    return TaskSeriesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      tagId: tagId ?? this.tagId,
      priority: priority ?? this.priority,
      allDay: allDay ?? this.allDay,
      startAt: startAt ?? this.startAt,
      dueAt: dueAt ?? this.dueAt,
      statusDefault: statusDefault ?? this.statusDefault,
      dangerOffsetValue: dangerOffsetValue ?? this.dangerOffsetValue,
      dangerOffsetUnit: dangerOffsetUnit ?? this.dangerOffsetUnit,
      dangerUseWorkday: dangerUseWorkday ?? this.dangerUseWorkday,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (allDay.present) {
      map['all_day'] = Variable<bool>(allDay.value);
    }
    if (startAt.present) {
      map['start_at'] = Variable<DateTime>(startAt.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (statusDefault.present) {
      map['status_default'] = Variable<String>(statusDefault.value);
    }
    if (dangerOffsetValue.present) {
      map['danger_offset_value'] = Variable<int>(dangerOffsetValue.value);
    }
    if (dangerOffsetUnit.present) {
      map['danger_offset_unit'] = Variable<String>(dangerOffsetUnit.value);
    }
    if (dangerUseWorkday.present) {
      map['danger_use_workday'] = Variable<bool>(dangerUseWorkday.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskSeriesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('tagId: $tagId, ')
          ..write('priority: $priority, ')
          ..write('allDay: $allDay, ')
          ..write('startAt: $startAt, ')
          ..write('dueAt: $dueAt, ')
          ..write('statusDefault: $statusDefault, ')
          ..write('dangerOffsetValue: $dangerOffsetValue, ')
          ..write('dangerOffsetUnit: $dangerOffsetUnit, ')
          ..write('dangerUseWorkday: $dangerUseWorkday, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaskSeriesRevisionsTable extends TaskSeriesRevisions
    with TableInfo<$TaskSeriesRevisionsTable, TaskSeriesRevision> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskSeriesRevisionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seriesIdMeta = const VerificationMeta(
    'seriesId',
  );
  @override
  late final GeneratedColumn<String> seriesId = GeneratedColumn<String>(
    'series_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES task_series (id)',
    ),
  );
  static const VerificationMeta _effectiveFromMeta = const VerificationMeta(
    'effectiveFrom',
  );
  @override
  late final GeneratedColumn<DateTime> effectiveFrom =
      GeneratedColumn<DateTime>(
        'effective_from',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _effectiveUntilMeta = const VerificationMeta(
    'effectiveUntil',
  );
  @override
  late final GeneratedColumn<DateTime> effectiveUntil =
      GeneratedColumn<DateTime>(
        'effective_until',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tag_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id)',
    ),
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT \'medium\' CHECK (priority IN (\'low\', \'medium\', \'high\'))',
    defaultValue: const CustomExpression('\'medium\''),
  );
  static const VerificationMeta _allDayMeta = const VerificationMeta('allDay');
  @override
  late final GeneratedColumn<bool> allDay = GeneratedColumn<bool>(
    'all_day',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("all_day" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _startAtTimePartMeta = const VerificationMeta(
    'startAtTimePart',
  );
  @override
  late final GeneratedColumn<int> startAtTimePart = GeneratedColumn<int>(
    'start_at_time_part',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueAtTimePartMeta = const VerificationMeta(
    'dueAtTimePart',
  );
  @override
  late final GeneratedColumn<int> dueAtTimePart = GeneratedColumn<int>(
    'due_at_time_part',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recurrenceTypeMeta = const VerificationMeta(
    'recurrenceType',
  );
  @override
  late final GeneratedColumn<String> recurrenceType = GeneratedColumn<String>(
    'recurrence_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recurrenceIntervalMeta =
      const VerificationMeta('recurrenceInterval');
  @override
  late final GeneratedColumn<int> recurrenceInterval = GeneratedColumn<int>(
    'recurrence_interval',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recurrenceRuleJsonMeta =
      const VerificationMeta('recurrenceRuleJson');
  @override
  late final GeneratedColumn<String> recurrenceRuleJson =
      GeneratedColumn<String>(
        'recurrence_rule_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _recurrenceUntilMeta = const VerificationMeta(
    'recurrenceUntil',
  );
  @override
  late final GeneratedColumn<DateTime> recurrenceUntil =
      GeneratedColumn<DateTime>(
        'recurrence_until',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _dangerOffsetValueMeta = const VerificationMeta(
    'dangerOffsetValue',
  );
  @override
  late final GeneratedColumn<int> dangerOffsetValue = GeneratedColumn<int>(
    'danger_offset_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dangerOffsetUnitMeta = const VerificationMeta(
    'dangerOffsetUnit',
  );
  @override
  late final GeneratedColumn<String> dangerOffsetUnit = GeneratedColumn<String>(
    'danger_offset_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dangerUseWorkdayMeta = const VerificationMeta(
    'dangerUseWorkday',
  );
  @override
  late final GeneratedColumn<bool> dangerUseWorkday = GeneratedColumn<bool>(
    'danger_use_workday',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("danger_use_workday" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    seriesId,
    effectiveFrom,
    effectiveUntil,
    title,
    note,
    tagId,
    priority,
    allDay,
    startAtTimePart,
    dueAtTimePart,
    durationSeconds,
    recurrenceType,
    recurrenceInterval,
    recurrenceRuleJson,
    recurrenceUntil,
    dangerOffsetValue,
    dangerOffsetUnit,
    dangerUseWorkday,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_series_revisions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskSeriesRevision> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('series_id')) {
      context.handle(
        _seriesIdMeta,
        seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_seriesIdMeta);
    }
    if (data.containsKey('effective_from')) {
      context.handle(
        _effectiveFromMeta,
        effectiveFrom.isAcceptableOrUnknown(
          data['effective_from']!,
          _effectiveFromMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectiveFromMeta);
    }
    if (data.containsKey('effective_until')) {
      context.handle(
        _effectiveUntilMeta,
        effectiveUntil.isAcceptableOrUnknown(
          data['effective_until']!,
          _effectiveUntilMeta,
        ),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('all_day')) {
      context.handle(
        _allDayMeta,
        allDay.isAcceptableOrUnknown(data['all_day']!, _allDayMeta),
      );
    }
    if (data.containsKey('start_at_time_part')) {
      context.handle(
        _startAtTimePartMeta,
        startAtTimePart.isAcceptableOrUnknown(
          data['start_at_time_part']!,
          _startAtTimePartMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startAtTimePartMeta);
    }
    if (data.containsKey('due_at_time_part')) {
      context.handle(
        _dueAtTimePartMeta,
        dueAtTimePart.isAcceptableOrUnknown(
          data['due_at_time_part']!,
          _dueAtTimePartMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dueAtTimePartMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('recurrence_type')) {
      context.handle(
        _recurrenceTypeMeta,
        recurrenceType.isAcceptableOrUnknown(
          data['recurrence_type']!,
          _recurrenceTypeMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_interval')) {
      context.handle(
        _recurrenceIntervalMeta,
        recurrenceInterval.isAcceptableOrUnknown(
          data['recurrence_interval']!,
          _recurrenceIntervalMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_rule_json')) {
      context.handle(
        _recurrenceRuleJsonMeta,
        recurrenceRuleJson.isAcceptableOrUnknown(
          data['recurrence_rule_json']!,
          _recurrenceRuleJsonMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_until')) {
      context.handle(
        _recurrenceUntilMeta,
        recurrenceUntil.isAcceptableOrUnknown(
          data['recurrence_until']!,
          _recurrenceUntilMeta,
        ),
      );
    }
    if (data.containsKey('danger_offset_value')) {
      context.handle(
        _dangerOffsetValueMeta,
        dangerOffsetValue.isAcceptableOrUnknown(
          data['danger_offset_value']!,
          _dangerOffsetValueMeta,
        ),
      );
    }
    if (data.containsKey('danger_offset_unit')) {
      context.handle(
        _dangerOffsetUnitMeta,
        dangerOffsetUnit.isAcceptableOrUnknown(
          data['danger_offset_unit']!,
          _dangerOffsetUnitMeta,
        ),
      );
    }
    if (data.containsKey('danger_use_workday')) {
      context.handle(
        _dangerUseWorkdayMeta,
        dangerUseWorkday.isAcceptableOrUnknown(
          data['danger_use_workday']!,
          _dangerUseWorkdayMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskSeriesRevision map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskSeriesRevision(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series_id'],
      )!,
      effectiveFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}effective_from'],
      )!,
      effectiveUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}effective_until'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_id'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority'],
      )!,
      allDay: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}all_day'],
      )!,
      startAtTimePart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_at_time_part'],
      )!,
      dueAtTimePart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_at_time_part'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      recurrenceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_type'],
      ),
      recurrenceInterval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recurrence_interval'],
      ),
      recurrenceRuleJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_rule_json'],
      ),
      recurrenceUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recurrence_until'],
      ),
      dangerOffsetValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}danger_offset_value'],
      ),
      dangerOffsetUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}danger_offset_unit'],
      ),
      dangerUseWorkday: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}danger_use_workday'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TaskSeriesRevisionsTable createAlias(String alias) {
    return $TaskSeriesRevisionsTable(attachedDatabase, alias);
  }
}

class TaskSeriesRevision extends DataClass
    implements Insertable<TaskSeriesRevision> {
  final String id;
  final String seriesId;
  final DateTime effectiveFrom;
  final DateTime? effectiveUntil;
  final String title;
  final String? note;
  final String? tagId;
  final String priority;
  final bool allDay;
  final int startAtTimePart;
  final int dueAtTimePart;
  final int durationSeconds;
  final String? recurrenceType;
  final int? recurrenceInterval;
  final String? recurrenceRuleJson;
  final DateTime? recurrenceUntil;
  final int? dangerOffsetValue;
  final String? dangerOffsetUnit;
  final bool dangerUseWorkday;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TaskSeriesRevision({
    required this.id,
    required this.seriesId,
    required this.effectiveFrom,
    this.effectiveUntil,
    required this.title,
    this.note,
    this.tagId,
    required this.priority,
    required this.allDay,
    required this.startAtTimePart,
    required this.dueAtTimePart,
    required this.durationSeconds,
    this.recurrenceType,
    this.recurrenceInterval,
    this.recurrenceRuleJson,
    this.recurrenceUntil,
    this.dangerOffsetValue,
    this.dangerOffsetUnit,
    required this.dangerUseWorkday,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['series_id'] = Variable<String>(seriesId);
    map['effective_from'] = Variable<DateTime>(effectiveFrom);
    if (!nullToAbsent || effectiveUntil != null) {
      map['effective_until'] = Variable<DateTime>(effectiveUntil);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || tagId != null) {
      map['tag_id'] = Variable<String>(tagId);
    }
    map['priority'] = Variable<String>(priority);
    map['all_day'] = Variable<bool>(allDay);
    map['start_at_time_part'] = Variable<int>(startAtTimePart);
    map['due_at_time_part'] = Variable<int>(dueAtTimePart);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    if (!nullToAbsent || recurrenceType != null) {
      map['recurrence_type'] = Variable<String>(recurrenceType);
    }
    if (!nullToAbsent || recurrenceInterval != null) {
      map['recurrence_interval'] = Variable<int>(recurrenceInterval);
    }
    if (!nullToAbsent || recurrenceRuleJson != null) {
      map['recurrence_rule_json'] = Variable<String>(recurrenceRuleJson);
    }
    if (!nullToAbsent || recurrenceUntil != null) {
      map['recurrence_until'] = Variable<DateTime>(recurrenceUntil);
    }
    if (!nullToAbsent || dangerOffsetValue != null) {
      map['danger_offset_value'] = Variable<int>(dangerOffsetValue);
    }
    if (!nullToAbsent || dangerOffsetUnit != null) {
      map['danger_offset_unit'] = Variable<String>(dangerOffsetUnit);
    }
    map['danger_use_workday'] = Variable<bool>(dangerUseWorkday);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TaskSeriesRevisionsCompanion toCompanion(bool nullToAbsent) {
    return TaskSeriesRevisionsCompanion(
      id: Value(id),
      seriesId: Value(seriesId),
      effectiveFrom: Value(effectiveFrom),
      effectiveUntil: effectiveUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(effectiveUntil),
      title: Value(title),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      tagId: tagId == null && nullToAbsent
          ? const Value.absent()
          : Value(tagId),
      priority: Value(priority),
      allDay: Value(allDay),
      startAtTimePart: Value(startAtTimePart),
      dueAtTimePart: Value(dueAtTimePart),
      durationSeconds: Value(durationSeconds),
      recurrenceType: recurrenceType == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceType),
      recurrenceInterval: recurrenceInterval == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceInterval),
      recurrenceRuleJson: recurrenceRuleJson == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceRuleJson),
      recurrenceUntil: recurrenceUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceUntil),
      dangerOffsetValue: dangerOffsetValue == null && nullToAbsent
          ? const Value.absent()
          : Value(dangerOffsetValue),
      dangerOffsetUnit: dangerOffsetUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(dangerOffsetUnit),
      dangerUseWorkday: Value(dangerUseWorkday),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TaskSeriesRevision.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskSeriesRevision(
      id: serializer.fromJson<String>(json['id']),
      seriesId: serializer.fromJson<String>(json['seriesId']),
      effectiveFrom: serializer.fromJson<DateTime>(json['effectiveFrom']),
      effectiveUntil: serializer.fromJson<DateTime?>(json['effectiveUntil']),
      title: serializer.fromJson<String>(json['title']),
      note: serializer.fromJson<String?>(json['note']),
      tagId: serializer.fromJson<String?>(json['tagId']),
      priority: serializer.fromJson<String>(json['priority']),
      allDay: serializer.fromJson<bool>(json['allDay']),
      startAtTimePart: serializer.fromJson<int>(json['startAtTimePart']),
      dueAtTimePart: serializer.fromJson<int>(json['dueAtTimePart']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      recurrenceType: serializer.fromJson<String?>(json['recurrenceType']),
      recurrenceInterval: serializer.fromJson<int?>(json['recurrenceInterval']),
      recurrenceRuleJson: serializer.fromJson<String?>(
        json['recurrenceRuleJson'],
      ),
      recurrenceUntil: serializer.fromJson<DateTime?>(json['recurrenceUntil']),
      dangerOffsetValue: serializer.fromJson<int?>(json['dangerOffsetValue']),
      dangerOffsetUnit: serializer.fromJson<String?>(json['dangerOffsetUnit']),
      dangerUseWorkday: serializer.fromJson<bool>(json['dangerUseWorkday']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'seriesId': serializer.toJson<String>(seriesId),
      'effectiveFrom': serializer.toJson<DateTime>(effectiveFrom),
      'effectiveUntil': serializer.toJson<DateTime?>(effectiveUntil),
      'title': serializer.toJson<String>(title),
      'note': serializer.toJson<String?>(note),
      'tagId': serializer.toJson<String?>(tagId),
      'priority': serializer.toJson<String>(priority),
      'allDay': serializer.toJson<bool>(allDay),
      'startAtTimePart': serializer.toJson<int>(startAtTimePart),
      'dueAtTimePart': serializer.toJson<int>(dueAtTimePart),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'recurrenceType': serializer.toJson<String?>(recurrenceType),
      'recurrenceInterval': serializer.toJson<int?>(recurrenceInterval),
      'recurrenceRuleJson': serializer.toJson<String?>(recurrenceRuleJson),
      'recurrenceUntil': serializer.toJson<DateTime?>(recurrenceUntil),
      'dangerOffsetValue': serializer.toJson<int?>(dangerOffsetValue),
      'dangerOffsetUnit': serializer.toJson<String?>(dangerOffsetUnit),
      'dangerUseWorkday': serializer.toJson<bool>(dangerUseWorkday),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TaskSeriesRevision copyWith({
    String? id,
    String? seriesId,
    DateTime? effectiveFrom,
    Value<DateTime?> effectiveUntil = const Value.absent(),
    String? title,
    Value<String?> note = const Value.absent(),
    Value<String?> tagId = const Value.absent(),
    String? priority,
    bool? allDay,
    int? startAtTimePart,
    int? dueAtTimePart,
    int? durationSeconds,
    Value<String?> recurrenceType = const Value.absent(),
    Value<int?> recurrenceInterval = const Value.absent(),
    Value<String?> recurrenceRuleJson = const Value.absent(),
    Value<DateTime?> recurrenceUntil = const Value.absent(),
    Value<int?> dangerOffsetValue = const Value.absent(),
    Value<String?> dangerOffsetUnit = const Value.absent(),
    bool? dangerUseWorkday,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TaskSeriesRevision(
    id: id ?? this.id,
    seriesId: seriesId ?? this.seriesId,
    effectiveFrom: effectiveFrom ?? this.effectiveFrom,
    effectiveUntil: effectiveUntil.present
        ? effectiveUntil.value
        : this.effectiveUntil,
    title: title ?? this.title,
    note: note.present ? note.value : this.note,
    tagId: tagId.present ? tagId.value : this.tagId,
    priority: priority ?? this.priority,
    allDay: allDay ?? this.allDay,
    startAtTimePart: startAtTimePart ?? this.startAtTimePart,
    dueAtTimePart: dueAtTimePart ?? this.dueAtTimePart,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    recurrenceType: recurrenceType.present
        ? recurrenceType.value
        : this.recurrenceType,
    recurrenceInterval: recurrenceInterval.present
        ? recurrenceInterval.value
        : this.recurrenceInterval,
    recurrenceRuleJson: recurrenceRuleJson.present
        ? recurrenceRuleJson.value
        : this.recurrenceRuleJson,
    recurrenceUntil: recurrenceUntil.present
        ? recurrenceUntil.value
        : this.recurrenceUntil,
    dangerOffsetValue: dangerOffsetValue.present
        ? dangerOffsetValue.value
        : this.dangerOffsetValue,
    dangerOffsetUnit: dangerOffsetUnit.present
        ? dangerOffsetUnit.value
        : this.dangerOffsetUnit,
    dangerUseWorkday: dangerUseWorkday ?? this.dangerUseWorkday,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TaskSeriesRevision copyWithCompanion(TaskSeriesRevisionsCompanion data) {
    return TaskSeriesRevision(
      id: data.id.present ? data.id.value : this.id,
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      effectiveFrom: data.effectiveFrom.present
          ? data.effectiveFrom.value
          : this.effectiveFrom,
      effectiveUntil: data.effectiveUntil.present
          ? data.effectiveUntil.value
          : this.effectiveUntil,
      title: data.title.present ? data.title.value : this.title,
      note: data.note.present ? data.note.value : this.note,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
      priority: data.priority.present ? data.priority.value : this.priority,
      allDay: data.allDay.present ? data.allDay.value : this.allDay,
      startAtTimePart: data.startAtTimePart.present
          ? data.startAtTimePart.value
          : this.startAtTimePart,
      dueAtTimePart: data.dueAtTimePart.present
          ? data.dueAtTimePart.value
          : this.dueAtTimePart,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      recurrenceType: data.recurrenceType.present
          ? data.recurrenceType.value
          : this.recurrenceType,
      recurrenceInterval: data.recurrenceInterval.present
          ? data.recurrenceInterval.value
          : this.recurrenceInterval,
      recurrenceRuleJson: data.recurrenceRuleJson.present
          ? data.recurrenceRuleJson.value
          : this.recurrenceRuleJson,
      recurrenceUntil: data.recurrenceUntil.present
          ? data.recurrenceUntil.value
          : this.recurrenceUntil,
      dangerOffsetValue: data.dangerOffsetValue.present
          ? data.dangerOffsetValue.value
          : this.dangerOffsetValue,
      dangerOffsetUnit: data.dangerOffsetUnit.present
          ? data.dangerOffsetUnit.value
          : this.dangerOffsetUnit,
      dangerUseWorkday: data.dangerUseWorkday.present
          ? data.dangerUseWorkday.value
          : this.dangerUseWorkday,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskSeriesRevision(')
          ..write('id: $id, ')
          ..write('seriesId: $seriesId, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('effectiveUntil: $effectiveUntil, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('tagId: $tagId, ')
          ..write('priority: $priority, ')
          ..write('allDay: $allDay, ')
          ..write('startAtTimePart: $startAtTimePart, ')
          ..write('dueAtTimePart: $dueAtTimePart, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('recurrenceType: $recurrenceType, ')
          ..write('recurrenceInterval: $recurrenceInterval, ')
          ..write('recurrenceRuleJson: $recurrenceRuleJson, ')
          ..write('recurrenceUntil: $recurrenceUntil, ')
          ..write('dangerOffsetValue: $dangerOffsetValue, ')
          ..write('dangerOffsetUnit: $dangerOffsetUnit, ')
          ..write('dangerUseWorkday: $dangerUseWorkday, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    seriesId,
    effectiveFrom,
    effectiveUntil,
    title,
    note,
    tagId,
    priority,
    allDay,
    startAtTimePart,
    dueAtTimePart,
    durationSeconds,
    recurrenceType,
    recurrenceInterval,
    recurrenceRuleJson,
    recurrenceUntil,
    dangerOffsetValue,
    dangerOffsetUnit,
    dangerUseWorkday,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskSeriesRevision &&
          other.id == this.id &&
          other.seriesId == this.seriesId &&
          other.effectiveFrom == this.effectiveFrom &&
          other.effectiveUntil == this.effectiveUntil &&
          other.title == this.title &&
          other.note == this.note &&
          other.tagId == this.tagId &&
          other.priority == this.priority &&
          other.allDay == this.allDay &&
          other.startAtTimePart == this.startAtTimePart &&
          other.dueAtTimePart == this.dueAtTimePart &&
          other.durationSeconds == this.durationSeconds &&
          other.recurrenceType == this.recurrenceType &&
          other.recurrenceInterval == this.recurrenceInterval &&
          other.recurrenceRuleJson == this.recurrenceRuleJson &&
          other.recurrenceUntil == this.recurrenceUntil &&
          other.dangerOffsetValue == this.dangerOffsetValue &&
          other.dangerOffsetUnit == this.dangerOffsetUnit &&
          other.dangerUseWorkday == this.dangerUseWorkday &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TaskSeriesRevisionsCompanion extends UpdateCompanion<TaskSeriesRevision> {
  final Value<String> id;
  final Value<String> seriesId;
  final Value<DateTime> effectiveFrom;
  final Value<DateTime?> effectiveUntil;
  final Value<String> title;
  final Value<String?> note;
  final Value<String?> tagId;
  final Value<String> priority;
  final Value<bool> allDay;
  final Value<int> startAtTimePart;
  final Value<int> dueAtTimePart;
  final Value<int> durationSeconds;
  final Value<String?> recurrenceType;
  final Value<int?> recurrenceInterval;
  final Value<String?> recurrenceRuleJson;
  final Value<DateTime?> recurrenceUntil;
  final Value<int?> dangerOffsetValue;
  final Value<String?> dangerOffsetUnit;
  final Value<bool> dangerUseWorkday;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TaskSeriesRevisionsCompanion({
    this.id = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.effectiveFrom = const Value.absent(),
    this.effectiveUntil = const Value.absent(),
    this.title = const Value.absent(),
    this.note = const Value.absent(),
    this.tagId = const Value.absent(),
    this.priority = const Value.absent(),
    this.allDay = const Value.absent(),
    this.startAtTimePart = const Value.absent(),
    this.dueAtTimePart = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.recurrenceType = const Value.absent(),
    this.recurrenceInterval = const Value.absent(),
    this.recurrenceRuleJson = const Value.absent(),
    this.recurrenceUntil = const Value.absent(),
    this.dangerOffsetValue = const Value.absent(),
    this.dangerOffsetUnit = const Value.absent(),
    this.dangerUseWorkday = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskSeriesRevisionsCompanion.insert({
    required String id,
    required String seriesId,
    required DateTime effectiveFrom,
    this.effectiveUntil = const Value.absent(),
    required String title,
    this.note = const Value.absent(),
    this.tagId = const Value.absent(),
    this.priority = const Value.absent(),
    this.allDay = const Value.absent(),
    required int startAtTimePart,
    required int dueAtTimePart,
    required int durationSeconds,
    this.recurrenceType = const Value.absent(),
    this.recurrenceInterval = const Value.absent(),
    this.recurrenceRuleJson = const Value.absent(),
    this.recurrenceUntil = const Value.absent(),
    this.dangerOffsetValue = const Value.absent(),
    this.dangerOffsetUnit = const Value.absent(),
    this.dangerUseWorkday = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       seriesId = Value(seriesId),
       effectiveFrom = Value(effectiveFrom),
       title = Value(title),
       startAtTimePart = Value(startAtTimePart),
       dueAtTimePart = Value(dueAtTimePart),
       durationSeconds = Value(durationSeconds);
  static Insertable<TaskSeriesRevision> custom({
    Expression<String>? id,
    Expression<String>? seriesId,
    Expression<DateTime>? effectiveFrom,
    Expression<DateTime>? effectiveUntil,
    Expression<String>? title,
    Expression<String>? note,
    Expression<String>? tagId,
    Expression<String>? priority,
    Expression<bool>? allDay,
    Expression<int>? startAtTimePart,
    Expression<int>? dueAtTimePart,
    Expression<int>? durationSeconds,
    Expression<String>? recurrenceType,
    Expression<int>? recurrenceInterval,
    Expression<String>? recurrenceRuleJson,
    Expression<DateTime>? recurrenceUntil,
    Expression<int>? dangerOffsetValue,
    Expression<String>? dangerOffsetUnit,
    Expression<bool>? dangerUseWorkday,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (seriesId != null) 'series_id': seriesId,
      if (effectiveFrom != null) 'effective_from': effectiveFrom,
      if (effectiveUntil != null) 'effective_until': effectiveUntil,
      if (title != null) 'title': title,
      if (note != null) 'note': note,
      if (tagId != null) 'tag_id': tagId,
      if (priority != null) 'priority': priority,
      if (allDay != null) 'all_day': allDay,
      if (startAtTimePart != null) 'start_at_time_part': startAtTimePart,
      if (dueAtTimePart != null) 'due_at_time_part': dueAtTimePart,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (recurrenceType != null) 'recurrence_type': recurrenceType,
      if (recurrenceInterval != null) 'recurrence_interval': recurrenceInterval,
      if (recurrenceRuleJson != null)
        'recurrence_rule_json': recurrenceRuleJson,
      if (recurrenceUntil != null) 'recurrence_until': recurrenceUntil,
      if (dangerOffsetValue != null) 'danger_offset_value': dangerOffsetValue,
      if (dangerOffsetUnit != null) 'danger_offset_unit': dangerOffsetUnit,
      if (dangerUseWorkday != null) 'danger_use_workday': dangerUseWorkday,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskSeriesRevisionsCompanion copyWith({
    Value<String>? id,
    Value<String>? seriesId,
    Value<DateTime>? effectiveFrom,
    Value<DateTime?>? effectiveUntil,
    Value<String>? title,
    Value<String?>? note,
    Value<String?>? tagId,
    Value<String>? priority,
    Value<bool>? allDay,
    Value<int>? startAtTimePart,
    Value<int>? dueAtTimePart,
    Value<int>? durationSeconds,
    Value<String?>? recurrenceType,
    Value<int?>? recurrenceInterval,
    Value<String?>? recurrenceRuleJson,
    Value<DateTime?>? recurrenceUntil,
    Value<int?>? dangerOffsetValue,
    Value<String?>? dangerOffsetUnit,
    Value<bool>? dangerUseWorkday,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TaskSeriesRevisionsCompanion(
      id: id ?? this.id,
      seriesId: seriesId ?? this.seriesId,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      effectiveUntil: effectiveUntil ?? this.effectiveUntil,
      title: title ?? this.title,
      note: note ?? this.note,
      tagId: tagId ?? this.tagId,
      priority: priority ?? this.priority,
      allDay: allDay ?? this.allDay,
      startAtTimePart: startAtTimePart ?? this.startAtTimePart,
      dueAtTimePart: dueAtTimePart ?? this.dueAtTimePart,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
      recurrenceRuleJson: recurrenceRuleJson ?? this.recurrenceRuleJson,
      recurrenceUntil: recurrenceUntil ?? this.recurrenceUntil,
      dangerOffsetValue: dangerOffsetValue ?? this.dangerOffsetValue,
      dangerOffsetUnit: dangerOffsetUnit ?? this.dangerOffsetUnit,
      dangerUseWorkday: dangerUseWorkday ?? this.dangerUseWorkday,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (seriesId.present) {
      map['series_id'] = Variable<String>(seriesId.value);
    }
    if (effectiveFrom.present) {
      map['effective_from'] = Variable<DateTime>(effectiveFrom.value);
    }
    if (effectiveUntil.present) {
      map['effective_until'] = Variable<DateTime>(effectiveUntil.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (allDay.present) {
      map['all_day'] = Variable<bool>(allDay.value);
    }
    if (startAtTimePart.present) {
      map['start_at_time_part'] = Variable<int>(startAtTimePart.value);
    }
    if (dueAtTimePart.present) {
      map['due_at_time_part'] = Variable<int>(dueAtTimePart.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (recurrenceType.present) {
      map['recurrence_type'] = Variable<String>(recurrenceType.value);
    }
    if (recurrenceInterval.present) {
      map['recurrence_interval'] = Variable<int>(recurrenceInterval.value);
    }
    if (recurrenceRuleJson.present) {
      map['recurrence_rule_json'] = Variable<String>(recurrenceRuleJson.value);
    }
    if (recurrenceUntil.present) {
      map['recurrence_until'] = Variable<DateTime>(recurrenceUntil.value);
    }
    if (dangerOffsetValue.present) {
      map['danger_offset_value'] = Variable<int>(dangerOffsetValue.value);
    }
    if (dangerOffsetUnit.present) {
      map['danger_offset_unit'] = Variable<String>(dangerOffsetUnit.value);
    }
    if (dangerUseWorkday.present) {
      map['danger_use_workday'] = Variable<bool>(dangerUseWorkday.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskSeriesRevisionsCompanion(')
          ..write('id: $id, ')
          ..write('seriesId: $seriesId, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('effectiveUntil: $effectiveUntil, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('tagId: $tagId, ')
          ..write('priority: $priority, ')
          ..write('allDay: $allDay, ')
          ..write('startAtTimePart: $startAtTimePart, ')
          ..write('dueAtTimePart: $dueAtTimePart, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('recurrenceType: $recurrenceType, ')
          ..write('recurrenceInterval: $recurrenceInterval, ')
          ..write('recurrenceRuleJson: $recurrenceRuleJson, ')
          ..write('recurrenceUntil: $recurrenceUntil, ')
          ..write('dangerOffsetValue: $dangerOffsetValue, ')
          ..write('dangerOffsetUnit: $dangerOffsetUnit, ')
          ..write('dangerUseWorkday: $dangerUseWorkday, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaskOccurrenceOverridesTable extends TaskOccurrenceOverrides
    with TableInfo<$TaskOccurrenceOverridesTable, TaskOccurrenceOverride> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskOccurrenceOverridesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seriesIdMeta = const VerificationMeta(
    'seriesId',
  );
  @override
  late final GeneratedColumn<String> seriesId = GeneratedColumn<String>(
    'series_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES task_series (id)',
    ),
  );
  static const VerificationMeta _occurrenceKeyMeta = const VerificationMeta(
    'occurrenceKey',
  );
  @override
  late final GeneratedColumn<String> occurrenceKey = GeneratedColumn<String>(
    'occurrence_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _overrideTypeMeta = const VerificationMeta(
    'overrideType',
  );
  @override
  late final GeneratedColumn<String> overrideType = GeneratedColumn<String>(
    'override_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT \'override\' CHECK (override_type IN (\'override\', \'cancel\', \'detach\'))',
    defaultValue: const CustomExpression('\'override\''),
  );
  static const VerificationMeta _overrideStartAtMeta = const VerificationMeta(
    'overrideStartAt',
  );
  @override
  late final GeneratedColumn<DateTime> overrideStartAt =
      GeneratedColumn<DateTime>(
        'override_start_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _overrideDueAtMeta = const VerificationMeta(
    'overrideDueAt',
  );
  @override
  late final GeneratedColumn<DateTime> overrideDueAt =
      GeneratedColumn<DateTime>(
        'override_due_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _overrideDangerAtMeta = const VerificationMeta(
    'overrideDangerAt',
  );
  @override
  late final GeneratedColumn<DateTime> overrideDangerAt =
      GeneratedColumn<DateTime>(
        'override_danger_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _overrideTitleMeta = const VerificationMeta(
    'overrideTitle',
  );
  @override
  late final GeneratedColumn<String> overrideTitle = GeneratedColumn<String>(
    'override_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _overrideNoteMeta = const VerificationMeta(
    'overrideNote',
  );
  @override
  late final GeneratedColumn<String> overrideNote = GeneratedColumn<String>(
    'override_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _overrideTagIdMeta = const VerificationMeta(
    'overrideTagId',
  );
  @override
  late final GeneratedColumn<String> overrideTagId = GeneratedColumn<String>(
    'override_tag_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id)',
    ),
  );
  static const VerificationMeta _overridePriorityMeta = const VerificationMeta(
    'overridePriority',
  );
  @override
  late final GeneratedColumn<String> overridePriority = GeneratedColumn<String>(
    'override_priority',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'CHECK (status IN (\'pending\', \'completed\', \'cancelled\'))',
  );
  static const VerificationMeta _detachedAsSingleMeta = const VerificationMeta(
    'detachedAsSingle',
  );
  @override
  late final GeneratedColumn<bool> detachedAsSingle = GeneratedColumn<bool>(
    'detached_as_single',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("detached_as_single" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cancelledAtMeta = const VerificationMeta(
    'cancelledAt',
  );
  @override
  late final GeneratedColumn<DateTime> cancelledAt = GeneratedColumn<DateTime>(
    'cancelled_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    seriesId,
    occurrenceKey,
    overrideType,
    overrideStartAt,
    overrideDueAt,
    overrideDangerAt,
    overrideTitle,
    overrideNote,
    overrideTagId,
    overridePriority,
    status,
    detachedAsSingle,
    completedAt,
    cancelledAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_occurrence_overrides';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskOccurrenceOverride> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('series_id')) {
      context.handle(
        _seriesIdMeta,
        seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_seriesIdMeta);
    }
    if (data.containsKey('occurrence_key')) {
      context.handle(
        _occurrenceKeyMeta,
        occurrenceKey.isAcceptableOrUnknown(
          data['occurrence_key']!,
          _occurrenceKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurrenceKeyMeta);
    }
    if (data.containsKey('override_type')) {
      context.handle(
        _overrideTypeMeta,
        overrideType.isAcceptableOrUnknown(
          data['override_type']!,
          _overrideTypeMeta,
        ),
      );
    }
    if (data.containsKey('override_start_at')) {
      context.handle(
        _overrideStartAtMeta,
        overrideStartAt.isAcceptableOrUnknown(
          data['override_start_at']!,
          _overrideStartAtMeta,
        ),
      );
    }
    if (data.containsKey('override_due_at')) {
      context.handle(
        _overrideDueAtMeta,
        overrideDueAt.isAcceptableOrUnknown(
          data['override_due_at']!,
          _overrideDueAtMeta,
        ),
      );
    }
    if (data.containsKey('override_danger_at')) {
      context.handle(
        _overrideDangerAtMeta,
        overrideDangerAt.isAcceptableOrUnknown(
          data['override_danger_at']!,
          _overrideDangerAtMeta,
        ),
      );
    }
    if (data.containsKey('override_title')) {
      context.handle(
        _overrideTitleMeta,
        overrideTitle.isAcceptableOrUnknown(
          data['override_title']!,
          _overrideTitleMeta,
        ),
      );
    }
    if (data.containsKey('override_note')) {
      context.handle(
        _overrideNoteMeta,
        overrideNote.isAcceptableOrUnknown(
          data['override_note']!,
          _overrideNoteMeta,
        ),
      );
    }
    if (data.containsKey('override_tag_id')) {
      context.handle(
        _overrideTagIdMeta,
        overrideTagId.isAcceptableOrUnknown(
          data['override_tag_id']!,
          _overrideTagIdMeta,
        ),
      );
    }
    if (data.containsKey('override_priority')) {
      context.handle(
        _overridePriorityMeta,
        overridePriority.isAcceptableOrUnknown(
          data['override_priority']!,
          _overridePriorityMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('detached_as_single')) {
      context.handle(
        _detachedAsSingleMeta,
        detachedAsSingle.isAcceptableOrUnknown(
          data['detached_as_single']!,
          _detachedAsSingleMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('cancelled_at')) {
      context.handle(
        _cancelledAtMeta,
        cancelledAt.isAcceptableOrUnknown(
          data['cancelled_at']!,
          _cancelledAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {seriesId, occurrenceKey},
  ];
  @override
  TaskOccurrenceOverride map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskOccurrenceOverride(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series_id'],
      )!,
      occurrenceKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}occurrence_key'],
      )!,
      overrideType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}override_type'],
      )!,
      overrideStartAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}override_start_at'],
      ),
      overrideDueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}override_due_at'],
      ),
      overrideDangerAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}override_danger_at'],
      ),
      overrideTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}override_title'],
      ),
      overrideNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}override_note'],
      ),
      overrideTagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}override_tag_id'],
      ),
      overridePriority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}override_priority'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      ),
      detachedAsSingle: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}detached_as_single'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      cancelledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cancelled_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TaskOccurrenceOverridesTable createAlias(String alias) {
    return $TaskOccurrenceOverridesTable(attachedDatabase, alias);
  }
}

class TaskOccurrenceOverride extends DataClass
    implements Insertable<TaskOccurrenceOverride> {
  final String id;
  final String seriesId;
  final String occurrenceKey;
  final String overrideType;
  final DateTime? overrideStartAt;
  final DateTime? overrideDueAt;
  final DateTime? overrideDangerAt;
  final String? overrideTitle;
  final String? overrideNote;
  final String? overrideTagId;
  final String? overridePriority;
  final String? status;
  final bool detachedAsSingle;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TaskOccurrenceOverride({
    required this.id,
    required this.seriesId,
    required this.occurrenceKey,
    required this.overrideType,
    this.overrideStartAt,
    this.overrideDueAt,
    this.overrideDangerAt,
    this.overrideTitle,
    this.overrideNote,
    this.overrideTagId,
    this.overridePriority,
    this.status,
    required this.detachedAsSingle,
    this.completedAt,
    this.cancelledAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['series_id'] = Variable<String>(seriesId);
    map['occurrence_key'] = Variable<String>(occurrenceKey);
    map['override_type'] = Variable<String>(overrideType);
    if (!nullToAbsent || overrideStartAt != null) {
      map['override_start_at'] = Variable<DateTime>(overrideStartAt);
    }
    if (!nullToAbsent || overrideDueAt != null) {
      map['override_due_at'] = Variable<DateTime>(overrideDueAt);
    }
    if (!nullToAbsent || overrideDangerAt != null) {
      map['override_danger_at'] = Variable<DateTime>(overrideDangerAt);
    }
    if (!nullToAbsent || overrideTitle != null) {
      map['override_title'] = Variable<String>(overrideTitle);
    }
    if (!nullToAbsent || overrideNote != null) {
      map['override_note'] = Variable<String>(overrideNote);
    }
    if (!nullToAbsent || overrideTagId != null) {
      map['override_tag_id'] = Variable<String>(overrideTagId);
    }
    if (!nullToAbsent || overridePriority != null) {
      map['override_priority'] = Variable<String>(overridePriority);
    }
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    map['detached_as_single'] = Variable<bool>(detachedAsSingle);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || cancelledAt != null) {
      map['cancelled_at'] = Variable<DateTime>(cancelledAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TaskOccurrenceOverridesCompanion toCompanion(bool nullToAbsent) {
    return TaskOccurrenceOverridesCompanion(
      id: Value(id),
      seriesId: Value(seriesId),
      occurrenceKey: Value(occurrenceKey),
      overrideType: Value(overrideType),
      overrideStartAt: overrideStartAt == null && nullToAbsent
          ? const Value.absent()
          : Value(overrideStartAt),
      overrideDueAt: overrideDueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(overrideDueAt),
      overrideDangerAt: overrideDangerAt == null && nullToAbsent
          ? const Value.absent()
          : Value(overrideDangerAt),
      overrideTitle: overrideTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(overrideTitle),
      overrideNote: overrideNote == null && nullToAbsent
          ? const Value.absent()
          : Value(overrideNote),
      overrideTagId: overrideTagId == null && nullToAbsent
          ? const Value.absent()
          : Value(overrideTagId),
      overridePriority: overridePriority == null && nullToAbsent
          ? const Value.absent()
          : Value(overridePriority),
      status: status == null && nullToAbsent
          ? const Value.absent()
          : Value(status),
      detachedAsSingle: Value(detachedAsSingle),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      cancelledAt: cancelledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(cancelledAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TaskOccurrenceOverride.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskOccurrenceOverride(
      id: serializer.fromJson<String>(json['id']),
      seriesId: serializer.fromJson<String>(json['seriesId']),
      occurrenceKey: serializer.fromJson<String>(json['occurrenceKey']),
      overrideType: serializer.fromJson<String>(json['overrideType']),
      overrideStartAt: serializer.fromJson<DateTime?>(json['overrideStartAt']),
      overrideDueAt: serializer.fromJson<DateTime?>(json['overrideDueAt']),
      overrideDangerAt: serializer.fromJson<DateTime?>(
        json['overrideDangerAt'],
      ),
      overrideTitle: serializer.fromJson<String?>(json['overrideTitle']),
      overrideNote: serializer.fromJson<String?>(json['overrideNote']),
      overrideTagId: serializer.fromJson<String?>(json['overrideTagId']),
      overridePriority: serializer.fromJson<String?>(json['overridePriority']),
      status: serializer.fromJson<String?>(json['status']),
      detachedAsSingle: serializer.fromJson<bool>(json['detachedAsSingle']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      cancelledAt: serializer.fromJson<DateTime?>(json['cancelledAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'seriesId': serializer.toJson<String>(seriesId),
      'occurrenceKey': serializer.toJson<String>(occurrenceKey),
      'overrideType': serializer.toJson<String>(overrideType),
      'overrideStartAt': serializer.toJson<DateTime?>(overrideStartAt),
      'overrideDueAt': serializer.toJson<DateTime?>(overrideDueAt),
      'overrideDangerAt': serializer.toJson<DateTime?>(overrideDangerAt),
      'overrideTitle': serializer.toJson<String?>(overrideTitle),
      'overrideNote': serializer.toJson<String?>(overrideNote),
      'overrideTagId': serializer.toJson<String?>(overrideTagId),
      'overridePriority': serializer.toJson<String?>(overridePriority),
      'status': serializer.toJson<String?>(status),
      'detachedAsSingle': serializer.toJson<bool>(detachedAsSingle),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'cancelledAt': serializer.toJson<DateTime?>(cancelledAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TaskOccurrenceOverride copyWith({
    String? id,
    String? seriesId,
    String? occurrenceKey,
    String? overrideType,
    Value<DateTime?> overrideStartAt = const Value.absent(),
    Value<DateTime?> overrideDueAt = const Value.absent(),
    Value<DateTime?> overrideDangerAt = const Value.absent(),
    Value<String?> overrideTitle = const Value.absent(),
    Value<String?> overrideNote = const Value.absent(),
    Value<String?> overrideTagId = const Value.absent(),
    Value<String?> overridePriority = const Value.absent(),
    Value<String?> status = const Value.absent(),
    bool? detachedAsSingle,
    Value<DateTime?> completedAt = const Value.absent(),
    Value<DateTime?> cancelledAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TaskOccurrenceOverride(
    id: id ?? this.id,
    seriesId: seriesId ?? this.seriesId,
    occurrenceKey: occurrenceKey ?? this.occurrenceKey,
    overrideType: overrideType ?? this.overrideType,
    overrideStartAt: overrideStartAt.present
        ? overrideStartAt.value
        : this.overrideStartAt,
    overrideDueAt: overrideDueAt.present
        ? overrideDueAt.value
        : this.overrideDueAt,
    overrideDangerAt: overrideDangerAt.present
        ? overrideDangerAt.value
        : this.overrideDangerAt,
    overrideTitle: overrideTitle.present
        ? overrideTitle.value
        : this.overrideTitle,
    overrideNote: overrideNote.present ? overrideNote.value : this.overrideNote,
    overrideTagId: overrideTagId.present
        ? overrideTagId.value
        : this.overrideTagId,
    overridePriority: overridePriority.present
        ? overridePriority.value
        : this.overridePriority,
    status: status.present ? status.value : this.status,
    detachedAsSingle: detachedAsSingle ?? this.detachedAsSingle,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    cancelledAt: cancelledAt.present ? cancelledAt.value : this.cancelledAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TaskOccurrenceOverride copyWithCompanion(
    TaskOccurrenceOverridesCompanion data,
  ) {
    return TaskOccurrenceOverride(
      id: data.id.present ? data.id.value : this.id,
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      occurrenceKey: data.occurrenceKey.present
          ? data.occurrenceKey.value
          : this.occurrenceKey,
      overrideType: data.overrideType.present
          ? data.overrideType.value
          : this.overrideType,
      overrideStartAt: data.overrideStartAt.present
          ? data.overrideStartAt.value
          : this.overrideStartAt,
      overrideDueAt: data.overrideDueAt.present
          ? data.overrideDueAt.value
          : this.overrideDueAt,
      overrideDangerAt: data.overrideDangerAt.present
          ? data.overrideDangerAt.value
          : this.overrideDangerAt,
      overrideTitle: data.overrideTitle.present
          ? data.overrideTitle.value
          : this.overrideTitle,
      overrideNote: data.overrideNote.present
          ? data.overrideNote.value
          : this.overrideNote,
      overrideTagId: data.overrideTagId.present
          ? data.overrideTagId.value
          : this.overrideTagId,
      overridePriority: data.overridePriority.present
          ? data.overridePriority.value
          : this.overridePriority,
      status: data.status.present ? data.status.value : this.status,
      detachedAsSingle: data.detachedAsSingle.present
          ? data.detachedAsSingle.value
          : this.detachedAsSingle,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      cancelledAt: data.cancelledAt.present
          ? data.cancelledAt.value
          : this.cancelledAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskOccurrenceOverride(')
          ..write('id: $id, ')
          ..write('seriesId: $seriesId, ')
          ..write('occurrenceKey: $occurrenceKey, ')
          ..write('overrideType: $overrideType, ')
          ..write('overrideStartAt: $overrideStartAt, ')
          ..write('overrideDueAt: $overrideDueAt, ')
          ..write('overrideDangerAt: $overrideDangerAt, ')
          ..write('overrideTitle: $overrideTitle, ')
          ..write('overrideNote: $overrideNote, ')
          ..write('overrideTagId: $overrideTagId, ')
          ..write('overridePriority: $overridePriority, ')
          ..write('status: $status, ')
          ..write('detachedAsSingle: $detachedAsSingle, ')
          ..write('completedAt: $completedAt, ')
          ..write('cancelledAt: $cancelledAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    seriesId,
    occurrenceKey,
    overrideType,
    overrideStartAt,
    overrideDueAt,
    overrideDangerAt,
    overrideTitle,
    overrideNote,
    overrideTagId,
    overridePriority,
    status,
    detachedAsSingle,
    completedAt,
    cancelledAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskOccurrenceOverride &&
          other.id == this.id &&
          other.seriesId == this.seriesId &&
          other.occurrenceKey == this.occurrenceKey &&
          other.overrideType == this.overrideType &&
          other.overrideStartAt == this.overrideStartAt &&
          other.overrideDueAt == this.overrideDueAt &&
          other.overrideDangerAt == this.overrideDangerAt &&
          other.overrideTitle == this.overrideTitle &&
          other.overrideNote == this.overrideNote &&
          other.overrideTagId == this.overrideTagId &&
          other.overridePriority == this.overridePriority &&
          other.status == this.status &&
          other.detachedAsSingle == this.detachedAsSingle &&
          other.completedAt == this.completedAt &&
          other.cancelledAt == this.cancelledAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TaskOccurrenceOverridesCompanion
    extends UpdateCompanion<TaskOccurrenceOverride> {
  final Value<String> id;
  final Value<String> seriesId;
  final Value<String> occurrenceKey;
  final Value<String> overrideType;
  final Value<DateTime?> overrideStartAt;
  final Value<DateTime?> overrideDueAt;
  final Value<DateTime?> overrideDangerAt;
  final Value<String?> overrideTitle;
  final Value<String?> overrideNote;
  final Value<String?> overrideTagId;
  final Value<String?> overridePriority;
  final Value<String?> status;
  final Value<bool> detachedAsSingle;
  final Value<DateTime?> completedAt;
  final Value<DateTime?> cancelledAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TaskOccurrenceOverridesCompanion({
    this.id = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.occurrenceKey = const Value.absent(),
    this.overrideType = const Value.absent(),
    this.overrideStartAt = const Value.absent(),
    this.overrideDueAt = const Value.absent(),
    this.overrideDangerAt = const Value.absent(),
    this.overrideTitle = const Value.absent(),
    this.overrideNote = const Value.absent(),
    this.overrideTagId = const Value.absent(),
    this.overridePriority = const Value.absent(),
    this.status = const Value.absent(),
    this.detachedAsSingle = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.cancelledAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskOccurrenceOverridesCompanion.insert({
    required String id,
    required String seriesId,
    required String occurrenceKey,
    this.overrideType = const Value.absent(),
    this.overrideStartAt = const Value.absent(),
    this.overrideDueAt = const Value.absent(),
    this.overrideDangerAt = const Value.absent(),
    this.overrideTitle = const Value.absent(),
    this.overrideNote = const Value.absent(),
    this.overrideTagId = const Value.absent(),
    this.overridePriority = const Value.absent(),
    this.status = const Value.absent(),
    this.detachedAsSingle = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.cancelledAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       seriesId = Value(seriesId),
       occurrenceKey = Value(occurrenceKey);
  static Insertable<TaskOccurrenceOverride> custom({
    Expression<String>? id,
    Expression<String>? seriesId,
    Expression<String>? occurrenceKey,
    Expression<String>? overrideType,
    Expression<DateTime>? overrideStartAt,
    Expression<DateTime>? overrideDueAt,
    Expression<DateTime>? overrideDangerAt,
    Expression<String>? overrideTitle,
    Expression<String>? overrideNote,
    Expression<String>? overrideTagId,
    Expression<String>? overridePriority,
    Expression<String>? status,
    Expression<bool>? detachedAsSingle,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? cancelledAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (seriesId != null) 'series_id': seriesId,
      if (occurrenceKey != null) 'occurrence_key': occurrenceKey,
      if (overrideType != null) 'override_type': overrideType,
      if (overrideStartAt != null) 'override_start_at': overrideStartAt,
      if (overrideDueAt != null) 'override_due_at': overrideDueAt,
      if (overrideDangerAt != null) 'override_danger_at': overrideDangerAt,
      if (overrideTitle != null) 'override_title': overrideTitle,
      if (overrideNote != null) 'override_note': overrideNote,
      if (overrideTagId != null) 'override_tag_id': overrideTagId,
      if (overridePriority != null) 'override_priority': overridePriority,
      if (status != null) 'status': status,
      if (detachedAsSingle != null) 'detached_as_single': detachedAsSingle,
      if (completedAt != null) 'completed_at': completedAt,
      if (cancelledAt != null) 'cancelled_at': cancelledAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskOccurrenceOverridesCompanion copyWith({
    Value<String>? id,
    Value<String>? seriesId,
    Value<String>? occurrenceKey,
    Value<String>? overrideType,
    Value<DateTime?>? overrideStartAt,
    Value<DateTime?>? overrideDueAt,
    Value<DateTime?>? overrideDangerAt,
    Value<String?>? overrideTitle,
    Value<String?>? overrideNote,
    Value<String?>? overrideTagId,
    Value<String?>? overridePriority,
    Value<String?>? status,
    Value<bool>? detachedAsSingle,
    Value<DateTime?>? completedAt,
    Value<DateTime?>? cancelledAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TaskOccurrenceOverridesCompanion(
      id: id ?? this.id,
      seriesId: seriesId ?? this.seriesId,
      occurrenceKey: occurrenceKey ?? this.occurrenceKey,
      overrideType: overrideType ?? this.overrideType,
      overrideStartAt: overrideStartAt ?? this.overrideStartAt,
      overrideDueAt: overrideDueAt ?? this.overrideDueAt,
      overrideDangerAt: overrideDangerAt ?? this.overrideDangerAt,
      overrideTitle: overrideTitle ?? this.overrideTitle,
      overrideNote: overrideNote ?? this.overrideNote,
      overrideTagId: overrideTagId ?? this.overrideTagId,
      overridePriority: overridePriority ?? this.overridePriority,
      status: status ?? this.status,
      detachedAsSingle: detachedAsSingle ?? this.detachedAsSingle,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (seriesId.present) {
      map['series_id'] = Variable<String>(seriesId.value);
    }
    if (occurrenceKey.present) {
      map['occurrence_key'] = Variable<String>(occurrenceKey.value);
    }
    if (overrideType.present) {
      map['override_type'] = Variable<String>(overrideType.value);
    }
    if (overrideStartAt.present) {
      map['override_start_at'] = Variable<DateTime>(overrideStartAt.value);
    }
    if (overrideDueAt.present) {
      map['override_due_at'] = Variable<DateTime>(overrideDueAt.value);
    }
    if (overrideDangerAt.present) {
      map['override_danger_at'] = Variable<DateTime>(overrideDangerAt.value);
    }
    if (overrideTitle.present) {
      map['override_title'] = Variable<String>(overrideTitle.value);
    }
    if (overrideNote.present) {
      map['override_note'] = Variable<String>(overrideNote.value);
    }
    if (overrideTagId.present) {
      map['override_tag_id'] = Variable<String>(overrideTagId.value);
    }
    if (overridePriority.present) {
      map['override_priority'] = Variable<String>(overridePriority.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (detachedAsSingle.present) {
      map['detached_as_single'] = Variable<bool>(detachedAsSingle.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (cancelledAt.present) {
      map['cancelled_at'] = Variable<DateTime>(cancelledAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskOccurrenceOverridesCompanion(')
          ..write('id: $id, ')
          ..write('seriesId: $seriesId, ')
          ..write('occurrenceKey: $occurrenceKey, ')
          ..write('overrideType: $overrideType, ')
          ..write('overrideStartAt: $overrideStartAt, ')
          ..write('overrideDueAt: $overrideDueAt, ')
          ..write('overrideDangerAt: $overrideDangerAt, ')
          ..write('overrideTitle: $overrideTitle, ')
          ..write('overrideNote: $overrideNote, ')
          ..write('overrideTagId: $overrideTagId, ')
          ..write('overridePriority: $overridePriority, ')
          ..write('status: $status, ')
          ..write('detachedAsSingle: $detachedAsSingle, ')
          ..write('completedAt: $completedAt, ')
          ..write('cancelledAt: $cancelledAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HolidayCalendarEntriesTable extends HolidayCalendarEntries
    with TableInfo<$HolidayCalendarEntriesTable, HolidayCalendarEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HolidayCalendarEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayTypeMeta = const VerificationMeta(
    'dayType',
  );
  @override
  late final GeneratedColumn<String> dayType = GeneratedColumn<String>(
    'day_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (day_type IN (\'workday\', \'holiday\', \'weekend_makeup\'))',
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  @override
  List<GeneratedColumn> get $columns => [
    date,
    dayType,
    name,
    source,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'holiday_calendar_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<HolidayCalendarEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('day_type')) {
      context.handle(
        _dayTypeMeta,
        dayType.isAcceptableOrUnknown(data['day_type']!, _dayTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_dayTypeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  HolidayCalendarEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HolidayCalendarEntry(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      dayType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_type'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $HolidayCalendarEntriesTable createAlias(String alias) {
    return $HolidayCalendarEntriesTable(attachedDatabase, alias);
  }
}

class HolidayCalendarEntry extends DataClass
    implements Insertable<HolidayCalendarEntry> {
  final String date;
  final String dayType;
  final String? name;
  final String? source;
  final DateTime updatedAt;
  const HolidayCalendarEntry({
    required this.date,
    required this.dayType,
    this.name,
    this.source,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    map['day_type'] = Variable<String>(dayType);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  HolidayCalendarEntriesCompanion toCompanion(bool nullToAbsent) {
    return HolidayCalendarEntriesCompanion(
      date: Value(date),
      dayType: Value(dayType),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      source: source == null && nullToAbsent
          ? const Value.absent()
          : Value(source),
      updatedAt: Value(updatedAt),
    );
  }

  factory HolidayCalendarEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HolidayCalendarEntry(
      date: serializer.fromJson<String>(json['date']),
      dayType: serializer.fromJson<String>(json['dayType']),
      name: serializer.fromJson<String?>(json['name']),
      source: serializer.fromJson<String?>(json['source']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'dayType': serializer.toJson<String>(dayType),
      'name': serializer.toJson<String?>(name),
      'source': serializer.toJson<String?>(source),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  HolidayCalendarEntry copyWith({
    String? date,
    String? dayType,
    Value<String?> name = const Value.absent(),
    Value<String?> source = const Value.absent(),
    DateTime? updatedAt,
  }) => HolidayCalendarEntry(
    date: date ?? this.date,
    dayType: dayType ?? this.dayType,
    name: name.present ? name.value : this.name,
    source: source.present ? source.value : this.source,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  HolidayCalendarEntry copyWithCompanion(HolidayCalendarEntriesCompanion data) {
    return HolidayCalendarEntry(
      date: data.date.present ? data.date.value : this.date,
      dayType: data.dayType.present ? data.dayType.value : this.dayType,
      name: data.name.present ? data.name.value : this.name,
      source: data.source.present ? data.source.value : this.source,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HolidayCalendarEntry(')
          ..write('date: $date, ')
          ..write('dayType: $dayType, ')
          ..write('name: $name, ')
          ..write('source: $source, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(date, dayType, name, source, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HolidayCalendarEntry &&
          other.date == this.date &&
          other.dayType == this.dayType &&
          other.name == this.name &&
          other.source == this.source &&
          other.updatedAt == this.updatedAt);
}

class HolidayCalendarEntriesCompanion
    extends UpdateCompanion<HolidayCalendarEntry> {
  final Value<String> date;
  final Value<String> dayType;
  final Value<String?> name;
  final Value<String?> source;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const HolidayCalendarEntriesCompanion({
    this.date = const Value.absent(),
    this.dayType = const Value.absent(),
    this.name = const Value.absent(),
    this.source = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HolidayCalendarEntriesCompanion.insert({
    required String date,
    required String dayType,
    this.name = const Value.absent(),
    this.source = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       dayType = Value(dayType);
  static Insertable<HolidayCalendarEntry> custom({
    Expression<String>? date,
    Expression<String>? dayType,
    Expression<String>? name,
    Expression<String>? source,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (dayType != null) 'day_type': dayType,
      if (name != null) 'name': name,
      if (source != null) 'source': source,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HolidayCalendarEntriesCompanion copyWith({
    Value<String>? date,
    Value<String>? dayType,
    Value<String?>? name,
    Value<String?>? source,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return HolidayCalendarEntriesCompanion(
      date: date ?? this.date,
      dayType: dayType ?? this.dayType,
      name: name ?? this.name,
      source: source ?? this.source,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (dayType.present) {
      map['day_type'] = Variable<String>(dayType.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HolidayCalendarEntriesCompanion(')
          ..write('date: $date, ')
          ..write('dayType: $dayType, ')
          ..write('name: $name, ')
          ..write('source: $source, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncMetaEntriesTable extends SyncMetaEntries
    with TableInfo<$SyncMetaEntriesTable, SyncMetaEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetaEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_meta_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetaEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SyncMetaEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetaEntry(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SyncMetaEntriesTable createAlias(String alias) {
    return $SyncMetaEntriesTable(attachedDatabase, alias);
  }
}

class SyncMetaEntry extends DataClass implements Insertable<SyncMetaEntry> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const SyncMetaEntry({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SyncMetaEntriesCompanion toCompanion(bool nullToAbsent) {
    return SyncMetaEntriesCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncMetaEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetaEntry(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SyncMetaEntry copyWith({String? key, String? value, DateTime? updatedAt}) =>
      SyncMetaEntry(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SyncMetaEntry copyWithCompanion(SyncMetaEntriesCompanion data) {
    return SyncMetaEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaEntry(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetaEntry &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class SyncMetaEntriesCompanion extends UpdateCompanion<SyncMetaEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SyncMetaEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetaEntriesCompanion.insert({
    required String key,
    required String value,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SyncMetaEntry> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetaEntriesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SyncMetaEntriesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $TaskSeriesTable taskSeries = $TaskSeriesTable(this);
  late final $TaskSeriesRevisionsTable taskSeriesRevisions =
      $TaskSeriesRevisionsTable(this);
  late final $TaskOccurrenceOverridesTable taskOccurrenceOverrides =
      $TaskOccurrenceOverridesTable(this);
  late final $HolidayCalendarEntriesTable holidayCalendarEntries =
      $HolidayCalendarEntriesTable(this);
  late final $SyncMetaEntriesTable syncMetaEntries = $SyncMetaEntriesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tags,
    taskSeries,
    taskSeriesRevisions,
    taskOccurrenceOverrides,
    holidayCalendarEntries,
    syncMetaEntries,
  ];
}

typedef $$TagsTableCreateCompanionBuilder =
    TagsCompanion Function({
      required String id,
      required String name,
      required String colorValue,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$TagsTableUpdateCompanionBuilder =
    TagsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> colorValue,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, Tag> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TaskSeriesTable, List<TaskSery>>
  _taskSeriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.taskSeries,
    aliasName: $_aliasNameGenerator(db.tags.id, db.taskSeries.tagId),
  );

  $$TaskSeriesTableProcessedTableManager get taskSeriesRefs {
    final manager = $$TaskSeriesTableTableManager(
      $_db,
      $_db.taskSeries,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_taskSeriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $TaskSeriesRevisionsTable,
    List<TaskSeriesRevision>
  >
  _taskSeriesRevisionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.taskSeriesRevisions,
        aliasName: $_aliasNameGenerator(
          db.tags.id,
          db.taskSeriesRevisions.tagId,
        ),
      );

  $$TaskSeriesRevisionsTableProcessedTableManager get taskSeriesRevisionsRefs {
    final manager = $$TaskSeriesRevisionsTableTableManager(
      $_db,
      $_db.taskSeriesRevisions,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _taskSeriesRevisionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $TaskOccurrenceOverridesTable,
    List<TaskOccurrenceOverride>
  >
  _taskOccurrenceOverridesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.taskOccurrenceOverrides,
        aliasName: $_aliasNameGenerator(
          db.tags.id,
          db.taskOccurrenceOverrides.overrideTagId,
        ),
      );

  $$TaskOccurrenceOverridesTableProcessedTableManager
  get taskOccurrenceOverridesRefs {
    final manager = $$TaskOccurrenceOverridesTableTableManager(
      $_db,
      $_db.taskOccurrenceOverrides,
    ).filter((f) => f.overrideTagId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _taskOccurrenceOverridesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> taskSeriesRefs(
    Expression<bool> Function($$TaskSeriesTableFilterComposer f) f,
  ) {
    final $$TaskSeriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskSeries,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskSeriesTableFilterComposer(
            $db: $db,
            $table: $db.taskSeries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> taskSeriesRevisionsRefs(
    Expression<bool> Function($$TaskSeriesRevisionsTableFilterComposer f) f,
  ) {
    final $$TaskSeriesRevisionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskSeriesRevisions,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskSeriesRevisionsTableFilterComposer(
            $db: $db,
            $table: $db.taskSeriesRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> taskOccurrenceOverridesRefs(
    Expression<bool> Function($$TaskOccurrenceOverridesTableFilterComposer f) f,
  ) {
    final $$TaskOccurrenceOverridesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.taskOccurrenceOverrides,
          getReferencedColumn: (t) => t.overrideTagId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TaskOccurrenceOverridesTableFilterComposer(
                $db: $db,
                $table: $db.taskOccurrenceOverrides,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> taskSeriesRefs<T extends Object>(
    Expression<T> Function($$TaskSeriesTableAnnotationComposer a) f,
  ) {
    final $$TaskSeriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskSeries,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskSeriesTableAnnotationComposer(
            $db: $db,
            $table: $db.taskSeries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> taskSeriesRevisionsRefs<T extends Object>(
    Expression<T> Function($$TaskSeriesRevisionsTableAnnotationComposer a) f,
  ) {
    final $$TaskSeriesRevisionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.taskSeriesRevisions,
          getReferencedColumn: (t) => t.tagId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TaskSeriesRevisionsTableAnnotationComposer(
                $db: $db,
                $table: $db.taskSeriesRevisions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> taskOccurrenceOverridesRefs<T extends Object>(
    Expression<T> Function($$TaskOccurrenceOverridesTableAnnotationComposer a)
    f,
  ) {
    final $$TaskOccurrenceOverridesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.taskOccurrenceOverrides,
          getReferencedColumn: (t) => t.overrideTagId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TaskOccurrenceOverridesTableAnnotationComposer(
                $db: $db,
                $table: $db.taskOccurrenceOverrides,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          Tag,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (Tag, $$TagsTableReferences),
          Tag,
          PrefetchHooks Function({
            bool taskSeriesRefs,
            bool taskSeriesRevisionsRefs,
            bool taskOccurrenceOverridesRefs,
          })
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> colorValue = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion(
                id: id,
                name: name,
                colorValue: colorValue,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String colorValue,
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion.insert(
                id: id,
                name: name,
                colorValue: colorValue,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TagsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                taskSeriesRefs = false,
                taskSeriesRevisionsRefs = false,
                taskOccurrenceOverridesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (taskSeriesRefs) db.taskSeries,
                    if (taskSeriesRevisionsRefs) db.taskSeriesRevisions,
                    if (taskOccurrenceOverridesRefs) db.taskOccurrenceOverrides,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (taskSeriesRefs)
                        await $_getPrefetchedData<Tag, $TagsTable, TaskSery>(
                          currentTable: table,
                          referencedTable: $$TagsTableReferences
                              ._taskSeriesRefsTable(db),
                          managerFromTypedResult: (p0) => $$TagsTableReferences(
                            db,
                            table,
                            p0,
                          ).taskSeriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tagId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (taskSeriesRevisionsRefs)
                        await $_getPrefetchedData<
                          Tag,
                          $TagsTable,
                          TaskSeriesRevision
                        >(
                          currentTable: table,
                          referencedTable: $$TagsTableReferences
                              ._taskSeriesRevisionsRefsTable(db),
                          managerFromTypedResult: (p0) => $$TagsTableReferences(
                            db,
                            table,
                            p0,
                          ).taskSeriesRevisionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tagId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (taskOccurrenceOverridesRefs)
                        await $_getPrefetchedData<
                          Tag,
                          $TagsTable,
                          TaskOccurrenceOverride
                        >(
                          currentTable: table,
                          referencedTable: $$TagsTableReferences
                              ._taskOccurrenceOverridesRefsTable(db),
                          managerFromTypedResult: (p0) => $$TagsTableReferences(
                            db,
                            table,
                            p0,
                          ).taskOccurrenceOverridesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.overrideTagId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      Tag,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (Tag, $$TagsTableReferences),
      Tag,
      PrefetchHooks Function({
        bool taskSeriesRefs,
        bool taskSeriesRevisionsRefs,
        bool taskOccurrenceOverridesRefs,
      })
    >;
typedef $$TaskSeriesTableCreateCompanionBuilder =
    TaskSeriesCompanion Function({
      required String id,
      required String title,
      Value<String?> note,
      Value<String?> tagId,
      Value<String> priority,
      Value<bool> allDay,
      required DateTime startAt,
      required DateTime dueAt,
      Value<String> statusDefault,
      Value<int?> dangerOffsetValue,
      Value<String?> dangerOffsetUnit,
      Value<bool> dangerUseWorkday,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });
typedef $$TaskSeriesTableUpdateCompanionBuilder =
    TaskSeriesCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> note,
      Value<String?> tagId,
      Value<String> priority,
      Value<bool> allDay,
      Value<DateTime> startAt,
      Value<DateTime> dueAt,
      Value<String> statusDefault,
      Value<int?> dangerOffsetValue,
      Value<String?> dangerOffsetUnit,
      Value<bool> dangerUseWorkday,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });

final class $$TaskSeriesTableReferences
    extends BaseReferences<_$AppDatabase, $TaskSeriesTable, TaskSery> {
  $$TaskSeriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TagsTable _tagIdTable(_$AppDatabase db) => db.tags.createAlias(
    $_aliasNameGenerator(db.taskSeries.tagId, db.tags.id),
  );

  $$TagsTableProcessedTableManager? get tagId {
    final $_column = $_itemColumn<String>('tag_id');
    if ($_column == null) return null;
    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $TaskSeriesRevisionsTable,
    List<TaskSeriesRevision>
  >
  _taskSeriesRevisionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.taskSeriesRevisions,
        aliasName: $_aliasNameGenerator(
          db.taskSeries.id,
          db.taskSeriesRevisions.seriesId,
        ),
      );

  $$TaskSeriesRevisionsTableProcessedTableManager get taskSeriesRevisionsRefs {
    final manager = $$TaskSeriesRevisionsTableTableManager(
      $_db,
      $_db.taskSeriesRevisions,
    ).filter((f) => f.seriesId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _taskSeriesRevisionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $TaskOccurrenceOverridesTable,
    List<TaskOccurrenceOverride>
  >
  _taskOccurrenceOverridesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.taskOccurrenceOverrides,
        aliasName: $_aliasNameGenerator(
          db.taskSeries.id,
          db.taskOccurrenceOverrides.seriesId,
        ),
      );

  $$TaskOccurrenceOverridesTableProcessedTableManager
  get taskOccurrenceOverridesRefs {
    final manager = $$TaskOccurrenceOverridesTableTableManager(
      $_db,
      $_db.taskOccurrenceOverrides,
    ).filter((f) => f.seriesId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _taskOccurrenceOverridesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TaskSeriesTableFilterComposer
    extends Composer<_$AppDatabase, $TaskSeriesTable> {
  $$TaskSeriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allDay => $composableBuilder(
    column: $table.allDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statusDefault => $composableBuilder(
    column: $table.statusDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dangerOffsetValue => $composableBuilder(
    column: $table.dangerOffsetValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dangerOffsetUnit => $composableBuilder(
    column: $table.dangerOffsetUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dangerUseWorkday => $composableBuilder(
    column: $table.dangerUseWorkday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> taskSeriesRevisionsRefs(
    Expression<bool> Function($$TaskSeriesRevisionsTableFilterComposer f) f,
  ) {
    final $$TaskSeriesRevisionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskSeriesRevisions,
      getReferencedColumn: (t) => t.seriesId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskSeriesRevisionsTableFilterComposer(
            $db: $db,
            $table: $db.taskSeriesRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> taskOccurrenceOverridesRefs(
    Expression<bool> Function($$TaskOccurrenceOverridesTableFilterComposer f) f,
  ) {
    final $$TaskOccurrenceOverridesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.taskOccurrenceOverrides,
          getReferencedColumn: (t) => t.seriesId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TaskOccurrenceOverridesTableFilterComposer(
                $db: $db,
                $table: $db.taskOccurrenceOverrides,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TaskSeriesTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskSeriesTable> {
  $$TaskSeriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allDay => $composableBuilder(
    column: $table.allDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statusDefault => $composableBuilder(
    column: $table.statusDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dangerOffsetValue => $composableBuilder(
    column: $table.dangerOffsetValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dangerOffsetUnit => $composableBuilder(
    column: $table.dangerOffsetUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dangerUseWorkday => $composableBuilder(
    column: $table.dangerUseWorkday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskSeriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskSeriesTable> {
  $$TaskSeriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<bool> get allDay =>
      $composableBuilder(column: $table.allDay, builder: (column) => column);

  GeneratedColumn<DateTime> get startAt =>
      $composableBuilder(column: $table.startAt, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<String> get statusDefault => $composableBuilder(
    column: $table.statusDefault,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dangerOffsetValue => $composableBuilder(
    column: $table.dangerOffsetValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dangerOffsetUnit => $composableBuilder(
    column: $table.dangerOffsetUnit,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get dangerUseWorkday => $composableBuilder(
    column: $table.dangerUseWorkday,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> taskSeriesRevisionsRefs<T extends Object>(
    Expression<T> Function($$TaskSeriesRevisionsTableAnnotationComposer a) f,
  ) {
    final $$TaskSeriesRevisionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.taskSeriesRevisions,
          getReferencedColumn: (t) => t.seriesId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TaskSeriesRevisionsTableAnnotationComposer(
                $db: $db,
                $table: $db.taskSeriesRevisions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> taskOccurrenceOverridesRefs<T extends Object>(
    Expression<T> Function($$TaskOccurrenceOverridesTableAnnotationComposer a)
    f,
  ) {
    final $$TaskOccurrenceOverridesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.taskOccurrenceOverrides,
          getReferencedColumn: (t) => t.seriesId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TaskOccurrenceOverridesTableAnnotationComposer(
                $db: $db,
                $table: $db.taskOccurrenceOverrides,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TaskSeriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskSeriesTable,
          TaskSery,
          $$TaskSeriesTableFilterComposer,
          $$TaskSeriesTableOrderingComposer,
          $$TaskSeriesTableAnnotationComposer,
          $$TaskSeriesTableCreateCompanionBuilder,
          $$TaskSeriesTableUpdateCompanionBuilder,
          (TaskSery, $$TaskSeriesTableReferences),
          TaskSery,
          PrefetchHooks Function({
            bool tagId,
            bool taskSeriesRevisionsRefs,
            bool taskOccurrenceOverridesRefs,
          })
        > {
  $$TaskSeriesTableTableManager(_$AppDatabase db, $TaskSeriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskSeriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskSeriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskSeriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> tagId = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<bool> allDay = const Value.absent(),
                Value<DateTime> startAt = const Value.absent(),
                Value<DateTime> dueAt = const Value.absent(),
                Value<String> statusDefault = const Value.absent(),
                Value<int?> dangerOffsetValue = const Value.absent(),
                Value<String?> dangerOffsetUnit = const Value.absent(),
                Value<bool> dangerUseWorkday = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskSeriesCompanion(
                id: id,
                title: title,
                note: note,
                tagId: tagId,
                priority: priority,
                allDay: allDay,
                startAt: startAt,
                dueAt: dueAt,
                statusDefault: statusDefault,
                dangerOffsetValue: dangerOffsetValue,
                dangerOffsetUnit: dangerOffsetUnit,
                dangerUseWorkday: dangerUseWorkday,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> note = const Value.absent(),
                Value<String?> tagId = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<bool> allDay = const Value.absent(),
                required DateTime startAt,
                required DateTime dueAt,
                Value<String> statusDefault = const Value.absent(),
                Value<int?> dangerOffsetValue = const Value.absent(),
                Value<String?> dangerOffsetUnit = const Value.absent(),
                Value<bool> dangerUseWorkday = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskSeriesCompanion.insert(
                id: id,
                title: title,
                note: note,
                tagId: tagId,
                priority: priority,
                allDay: allDay,
                startAt: startAt,
                dueAt: dueAt,
                statusDefault: statusDefault,
                dangerOffsetValue: dangerOffsetValue,
                dangerOffsetUnit: dangerOffsetUnit,
                dangerUseWorkday: dangerUseWorkday,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TaskSeriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                tagId = false,
                taskSeriesRevisionsRefs = false,
                taskOccurrenceOverridesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (taskSeriesRevisionsRefs) db.taskSeriesRevisions,
                    if (taskOccurrenceOverridesRefs) db.taskOccurrenceOverrides,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (tagId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.tagId,
                                    referencedTable: $$TaskSeriesTableReferences
                                        ._tagIdTable(db),
                                    referencedColumn:
                                        $$TaskSeriesTableReferences
                                            ._tagIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (taskSeriesRevisionsRefs)
                        await $_getPrefetchedData<
                          TaskSery,
                          $TaskSeriesTable,
                          TaskSeriesRevision
                        >(
                          currentTable: table,
                          referencedTable: $$TaskSeriesTableReferences
                              ._taskSeriesRevisionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TaskSeriesTableReferences(
                                db,
                                table,
                                p0,
                              ).taskSeriesRevisionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.seriesId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (taskOccurrenceOverridesRefs)
                        await $_getPrefetchedData<
                          TaskSery,
                          $TaskSeriesTable,
                          TaskOccurrenceOverride
                        >(
                          currentTable: table,
                          referencedTable: $$TaskSeriesTableReferences
                              ._taskOccurrenceOverridesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TaskSeriesTableReferences(
                                db,
                                table,
                                p0,
                              ).taskOccurrenceOverridesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.seriesId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TaskSeriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskSeriesTable,
      TaskSery,
      $$TaskSeriesTableFilterComposer,
      $$TaskSeriesTableOrderingComposer,
      $$TaskSeriesTableAnnotationComposer,
      $$TaskSeriesTableCreateCompanionBuilder,
      $$TaskSeriesTableUpdateCompanionBuilder,
      (TaskSery, $$TaskSeriesTableReferences),
      TaskSery,
      PrefetchHooks Function({
        bool tagId,
        bool taskSeriesRevisionsRefs,
        bool taskOccurrenceOverridesRefs,
      })
    >;
typedef $$TaskSeriesRevisionsTableCreateCompanionBuilder =
    TaskSeriesRevisionsCompanion Function({
      required String id,
      required String seriesId,
      required DateTime effectiveFrom,
      Value<DateTime?> effectiveUntil,
      required String title,
      Value<String?> note,
      Value<String?> tagId,
      Value<String> priority,
      Value<bool> allDay,
      required int startAtTimePart,
      required int dueAtTimePart,
      required int durationSeconds,
      Value<String?> recurrenceType,
      Value<int?> recurrenceInterval,
      Value<String?> recurrenceRuleJson,
      Value<DateTime?> recurrenceUntil,
      Value<int?> dangerOffsetValue,
      Value<String?> dangerOffsetUnit,
      Value<bool> dangerUseWorkday,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$TaskSeriesRevisionsTableUpdateCompanionBuilder =
    TaskSeriesRevisionsCompanion Function({
      Value<String> id,
      Value<String> seriesId,
      Value<DateTime> effectiveFrom,
      Value<DateTime?> effectiveUntil,
      Value<String> title,
      Value<String?> note,
      Value<String?> tagId,
      Value<String> priority,
      Value<bool> allDay,
      Value<int> startAtTimePart,
      Value<int> dueAtTimePart,
      Value<int> durationSeconds,
      Value<String?> recurrenceType,
      Value<int?> recurrenceInterval,
      Value<String?> recurrenceRuleJson,
      Value<DateTime?> recurrenceUntil,
      Value<int?> dangerOffsetValue,
      Value<String?> dangerOffsetUnit,
      Value<bool> dangerUseWorkday,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$TaskSeriesRevisionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TaskSeriesRevisionsTable,
          TaskSeriesRevision
        > {
  $$TaskSeriesRevisionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TaskSeriesTable _seriesIdTable(_$AppDatabase db) =>
      db.taskSeries.createAlias(
        $_aliasNameGenerator(db.taskSeriesRevisions.seriesId, db.taskSeries.id),
      );

  $$TaskSeriesTableProcessedTableManager get seriesId {
    final $_column = $_itemColumn<String>('series_id')!;

    final manager = $$TaskSeriesTableTableManager(
      $_db,
      $_db.taskSeries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_seriesIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) => db.tags.createAlias(
    $_aliasNameGenerator(db.taskSeriesRevisions.tagId, db.tags.id),
  );

  $$TagsTableProcessedTableManager? get tagId {
    final $_column = $_itemColumn<String>('tag_id');
    if ($_column == null) return null;
    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TaskSeriesRevisionsTableFilterComposer
    extends Composer<_$AppDatabase, $TaskSeriesRevisionsTable> {
  $$TaskSeriesRevisionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get effectiveUntil => $composableBuilder(
    column: $table.effectiveUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allDay => $composableBuilder(
    column: $table.allDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startAtTimePart => $composableBuilder(
    column: $table.startAtTimePart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dueAtTimePart => $composableBuilder(
    column: $table.dueAtTimePart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrenceType => $composableBuilder(
    column: $table.recurrenceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recurrenceInterval => $composableBuilder(
    column: $table.recurrenceInterval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrenceRuleJson => $composableBuilder(
    column: $table.recurrenceRuleJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recurrenceUntil => $composableBuilder(
    column: $table.recurrenceUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dangerOffsetValue => $composableBuilder(
    column: $table.dangerOffsetValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dangerOffsetUnit => $composableBuilder(
    column: $table.dangerOffsetUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dangerUseWorkday => $composableBuilder(
    column: $table.dangerUseWorkday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TaskSeriesTableFilterComposer get seriesId {
    final $$TaskSeriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.taskSeries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskSeriesTableFilterComposer(
            $db: $db,
            $table: $db.taskSeries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskSeriesRevisionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskSeriesRevisionsTable> {
  $$TaskSeriesRevisionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get effectiveUntil => $composableBuilder(
    column: $table.effectiveUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allDay => $composableBuilder(
    column: $table.allDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startAtTimePart => $composableBuilder(
    column: $table.startAtTimePart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueAtTimePart => $composableBuilder(
    column: $table.dueAtTimePart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrenceType => $composableBuilder(
    column: $table.recurrenceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recurrenceInterval => $composableBuilder(
    column: $table.recurrenceInterval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrenceRuleJson => $composableBuilder(
    column: $table.recurrenceRuleJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recurrenceUntil => $composableBuilder(
    column: $table.recurrenceUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dangerOffsetValue => $composableBuilder(
    column: $table.dangerOffsetValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dangerOffsetUnit => $composableBuilder(
    column: $table.dangerOffsetUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dangerUseWorkday => $composableBuilder(
    column: $table.dangerUseWorkday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TaskSeriesTableOrderingComposer get seriesId {
    final $$TaskSeriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.taskSeries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskSeriesTableOrderingComposer(
            $db: $db,
            $table: $db.taskSeries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskSeriesRevisionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskSeriesRevisionsTable> {
  $$TaskSeriesRevisionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get effectiveUntil => $composableBuilder(
    column: $table.effectiveUntil,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<bool> get allDay =>
      $composableBuilder(column: $table.allDay, builder: (column) => column);

  GeneratedColumn<int> get startAtTimePart => $composableBuilder(
    column: $table.startAtTimePart,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dueAtTimePart => $composableBuilder(
    column: $table.dueAtTimePart,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurrenceType => $composableBuilder(
    column: $table.recurrenceType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recurrenceInterval => $composableBuilder(
    column: $table.recurrenceInterval,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurrenceRuleJson => $composableBuilder(
    column: $table.recurrenceRuleJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get recurrenceUntil => $composableBuilder(
    column: $table.recurrenceUntil,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dangerOffsetValue => $composableBuilder(
    column: $table.dangerOffsetValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dangerOffsetUnit => $composableBuilder(
    column: $table.dangerOffsetUnit,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get dangerUseWorkday => $composableBuilder(
    column: $table.dangerUseWorkday,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$TaskSeriesTableAnnotationComposer get seriesId {
    final $$TaskSeriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.taskSeries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskSeriesTableAnnotationComposer(
            $db: $db,
            $table: $db.taskSeries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskSeriesRevisionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskSeriesRevisionsTable,
          TaskSeriesRevision,
          $$TaskSeriesRevisionsTableFilterComposer,
          $$TaskSeriesRevisionsTableOrderingComposer,
          $$TaskSeriesRevisionsTableAnnotationComposer,
          $$TaskSeriesRevisionsTableCreateCompanionBuilder,
          $$TaskSeriesRevisionsTableUpdateCompanionBuilder,
          (TaskSeriesRevision, $$TaskSeriesRevisionsTableReferences),
          TaskSeriesRevision,
          PrefetchHooks Function({bool seriesId, bool tagId})
        > {
  $$TaskSeriesRevisionsTableTableManager(
    _$AppDatabase db,
    $TaskSeriesRevisionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskSeriesRevisionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskSeriesRevisionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TaskSeriesRevisionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> seriesId = const Value.absent(),
                Value<DateTime> effectiveFrom = const Value.absent(),
                Value<DateTime?> effectiveUntil = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> tagId = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<bool> allDay = const Value.absent(),
                Value<int> startAtTimePart = const Value.absent(),
                Value<int> dueAtTimePart = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<String?> recurrenceType = const Value.absent(),
                Value<int?> recurrenceInterval = const Value.absent(),
                Value<String?> recurrenceRuleJson = const Value.absent(),
                Value<DateTime?> recurrenceUntil = const Value.absent(),
                Value<int?> dangerOffsetValue = const Value.absent(),
                Value<String?> dangerOffsetUnit = const Value.absent(),
                Value<bool> dangerUseWorkday = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskSeriesRevisionsCompanion(
                id: id,
                seriesId: seriesId,
                effectiveFrom: effectiveFrom,
                effectiveUntil: effectiveUntil,
                title: title,
                note: note,
                tagId: tagId,
                priority: priority,
                allDay: allDay,
                startAtTimePart: startAtTimePart,
                dueAtTimePart: dueAtTimePart,
                durationSeconds: durationSeconds,
                recurrenceType: recurrenceType,
                recurrenceInterval: recurrenceInterval,
                recurrenceRuleJson: recurrenceRuleJson,
                recurrenceUntil: recurrenceUntil,
                dangerOffsetValue: dangerOffsetValue,
                dangerOffsetUnit: dangerOffsetUnit,
                dangerUseWorkday: dangerUseWorkday,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String seriesId,
                required DateTime effectiveFrom,
                Value<DateTime?> effectiveUntil = const Value.absent(),
                required String title,
                Value<String?> note = const Value.absent(),
                Value<String?> tagId = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<bool> allDay = const Value.absent(),
                required int startAtTimePart,
                required int dueAtTimePart,
                required int durationSeconds,
                Value<String?> recurrenceType = const Value.absent(),
                Value<int?> recurrenceInterval = const Value.absent(),
                Value<String?> recurrenceRuleJson = const Value.absent(),
                Value<DateTime?> recurrenceUntil = const Value.absent(),
                Value<int?> dangerOffsetValue = const Value.absent(),
                Value<String?> dangerOffsetUnit = const Value.absent(),
                Value<bool> dangerUseWorkday = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskSeriesRevisionsCompanion.insert(
                id: id,
                seriesId: seriesId,
                effectiveFrom: effectiveFrom,
                effectiveUntil: effectiveUntil,
                title: title,
                note: note,
                tagId: tagId,
                priority: priority,
                allDay: allDay,
                startAtTimePart: startAtTimePart,
                dueAtTimePart: dueAtTimePart,
                durationSeconds: durationSeconds,
                recurrenceType: recurrenceType,
                recurrenceInterval: recurrenceInterval,
                recurrenceRuleJson: recurrenceRuleJson,
                recurrenceUntil: recurrenceUntil,
                dangerOffsetValue: dangerOffsetValue,
                dangerOffsetUnit: dangerOffsetUnit,
                dangerUseWorkday: dangerUseWorkday,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TaskSeriesRevisionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({seriesId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (seriesId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.seriesId,
                                referencedTable:
                                    $$TaskSeriesRevisionsTableReferences
                                        ._seriesIdTable(db),
                                referencedColumn:
                                    $$TaskSeriesRevisionsTableReferences
                                        ._seriesIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (tagId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tagId,
                                referencedTable:
                                    $$TaskSeriesRevisionsTableReferences
                                        ._tagIdTable(db),
                                referencedColumn:
                                    $$TaskSeriesRevisionsTableReferences
                                        ._tagIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TaskSeriesRevisionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskSeriesRevisionsTable,
      TaskSeriesRevision,
      $$TaskSeriesRevisionsTableFilterComposer,
      $$TaskSeriesRevisionsTableOrderingComposer,
      $$TaskSeriesRevisionsTableAnnotationComposer,
      $$TaskSeriesRevisionsTableCreateCompanionBuilder,
      $$TaskSeriesRevisionsTableUpdateCompanionBuilder,
      (TaskSeriesRevision, $$TaskSeriesRevisionsTableReferences),
      TaskSeriesRevision,
      PrefetchHooks Function({bool seriesId, bool tagId})
    >;
typedef $$TaskOccurrenceOverridesTableCreateCompanionBuilder =
    TaskOccurrenceOverridesCompanion Function({
      required String id,
      required String seriesId,
      required String occurrenceKey,
      Value<String> overrideType,
      Value<DateTime?> overrideStartAt,
      Value<DateTime?> overrideDueAt,
      Value<DateTime?> overrideDangerAt,
      Value<String?> overrideTitle,
      Value<String?> overrideNote,
      Value<String?> overrideTagId,
      Value<String?> overridePriority,
      Value<String?> status,
      Value<bool> detachedAsSingle,
      Value<DateTime?> completedAt,
      Value<DateTime?> cancelledAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$TaskOccurrenceOverridesTableUpdateCompanionBuilder =
    TaskOccurrenceOverridesCompanion Function({
      Value<String> id,
      Value<String> seriesId,
      Value<String> occurrenceKey,
      Value<String> overrideType,
      Value<DateTime?> overrideStartAt,
      Value<DateTime?> overrideDueAt,
      Value<DateTime?> overrideDangerAt,
      Value<String?> overrideTitle,
      Value<String?> overrideNote,
      Value<String?> overrideTagId,
      Value<String?> overridePriority,
      Value<String?> status,
      Value<bool> detachedAsSingle,
      Value<DateTime?> completedAt,
      Value<DateTime?> cancelledAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$TaskOccurrenceOverridesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TaskOccurrenceOverridesTable,
          TaskOccurrenceOverride
        > {
  $$TaskOccurrenceOverridesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TaskSeriesTable _seriesIdTable(_$AppDatabase db) =>
      db.taskSeries.createAlias(
        $_aliasNameGenerator(
          db.taskOccurrenceOverrides.seriesId,
          db.taskSeries.id,
        ),
      );

  $$TaskSeriesTableProcessedTableManager get seriesId {
    final $_column = $_itemColumn<String>('series_id')!;

    final manager = $$TaskSeriesTableTableManager(
      $_db,
      $_db.taskSeries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_seriesIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _overrideTagIdTable(_$AppDatabase db) =>
      db.tags.createAlias(
        $_aliasNameGenerator(
          db.taskOccurrenceOverrides.overrideTagId,
          db.tags.id,
        ),
      );

  $$TagsTableProcessedTableManager? get overrideTagId {
    final $_column = $_itemColumn<String>('override_tag_id');
    if ($_column == null) return null;
    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_overrideTagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TaskOccurrenceOverridesTableFilterComposer
    extends Composer<_$AppDatabase, $TaskOccurrenceOverridesTable> {
  $$TaskOccurrenceOverridesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get occurrenceKey => $composableBuilder(
    column: $table.occurrenceKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get overrideType => $composableBuilder(
    column: $table.overrideType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get overrideStartAt => $composableBuilder(
    column: $table.overrideStartAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get overrideDueAt => $composableBuilder(
    column: $table.overrideDueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get overrideDangerAt => $composableBuilder(
    column: $table.overrideDangerAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get overrideTitle => $composableBuilder(
    column: $table.overrideTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get overrideNote => $composableBuilder(
    column: $table.overrideNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get overridePriority => $composableBuilder(
    column: $table.overridePriority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get detachedAsSingle => $composableBuilder(
    column: $table.detachedAsSingle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TaskSeriesTableFilterComposer get seriesId {
    final $$TaskSeriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.taskSeries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskSeriesTableFilterComposer(
            $db: $db,
            $table: $db.taskSeries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get overrideTagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.overrideTagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskOccurrenceOverridesTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskOccurrenceOverridesTable> {
  $$TaskOccurrenceOverridesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get occurrenceKey => $composableBuilder(
    column: $table.occurrenceKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get overrideType => $composableBuilder(
    column: $table.overrideType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get overrideStartAt => $composableBuilder(
    column: $table.overrideStartAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get overrideDueAt => $composableBuilder(
    column: $table.overrideDueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get overrideDangerAt => $composableBuilder(
    column: $table.overrideDangerAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get overrideTitle => $composableBuilder(
    column: $table.overrideTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get overrideNote => $composableBuilder(
    column: $table.overrideNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get overridePriority => $composableBuilder(
    column: $table.overridePriority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get detachedAsSingle => $composableBuilder(
    column: $table.detachedAsSingle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TaskSeriesTableOrderingComposer get seriesId {
    final $$TaskSeriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.taskSeries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskSeriesTableOrderingComposer(
            $db: $db,
            $table: $db.taskSeries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get overrideTagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.overrideTagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskOccurrenceOverridesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskOccurrenceOverridesTable> {
  $$TaskOccurrenceOverridesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get occurrenceKey => $composableBuilder(
    column: $table.occurrenceKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get overrideType => $composableBuilder(
    column: $table.overrideType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get overrideStartAt => $composableBuilder(
    column: $table.overrideStartAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get overrideDueAt => $composableBuilder(
    column: $table.overrideDueAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get overrideDangerAt => $composableBuilder(
    column: $table.overrideDangerAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get overrideTitle => $composableBuilder(
    column: $table.overrideTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get overrideNote => $composableBuilder(
    column: $table.overrideNote,
    builder: (column) => column,
  );

  GeneratedColumn<String> get overridePriority => $composableBuilder(
    column: $table.overridePriority,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get detachedAsSingle => $composableBuilder(
    column: $table.detachedAsSingle,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$TaskSeriesTableAnnotationComposer get seriesId {
    final $$TaskSeriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.taskSeries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskSeriesTableAnnotationComposer(
            $db: $db,
            $table: $db.taskSeries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get overrideTagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.overrideTagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskOccurrenceOverridesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskOccurrenceOverridesTable,
          TaskOccurrenceOverride,
          $$TaskOccurrenceOverridesTableFilterComposer,
          $$TaskOccurrenceOverridesTableOrderingComposer,
          $$TaskOccurrenceOverridesTableAnnotationComposer,
          $$TaskOccurrenceOverridesTableCreateCompanionBuilder,
          $$TaskOccurrenceOverridesTableUpdateCompanionBuilder,
          (TaskOccurrenceOverride, $$TaskOccurrenceOverridesTableReferences),
          TaskOccurrenceOverride,
          PrefetchHooks Function({bool seriesId, bool overrideTagId})
        > {
  $$TaskOccurrenceOverridesTableTableManager(
    _$AppDatabase db,
    $TaskOccurrenceOverridesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskOccurrenceOverridesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TaskOccurrenceOverridesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TaskOccurrenceOverridesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> seriesId = const Value.absent(),
                Value<String> occurrenceKey = const Value.absent(),
                Value<String> overrideType = const Value.absent(),
                Value<DateTime?> overrideStartAt = const Value.absent(),
                Value<DateTime?> overrideDueAt = const Value.absent(),
                Value<DateTime?> overrideDangerAt = const Value.absent(),
                Value<String?> overrideTitle = const Value.absent(),
                Value<String?> overrideNote = const Value.absent(),
                Value<String?> overrideTagId = const Value.absent(),
                Value<String?> overridePriority = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<bool> detachedAsSingle = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime?> cancelledAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskOccurrenceOverridesCompanion(
                id: id,
                seriesId: seriesId,
                occurrenceKey: occurrenceKey,
                overrideType: overrideType,
                overrideStartAt: overrideStartAt,
                overrideDueAt: overrideDueAt,
                overrideDangerAt: overrideDangerAt,
                overrideTitle: overrideTitle,
                overrideNote: overrideNote,
                overrideTagId: overrideTagId,
                overridePriority: overridePriority,
                status: status,
                detachedAsSingle: detachedAsSingle,
                completedAt: completedAt,
                cancelledAt: cancelledAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String seriesId,
                required String occurrenceKey,
                Value<String> overrideType = const Value.absent(),
                Value<DateTime?> overrideStartAt = const Value.absent(),
                Value<DateTime?> overrideDueAt = const Value.absent(),
                Value<DateTime?> overrideDangerAt = const Value.absent(),
                Value<String?> overrideTitle = const Value.absent(),
                Value<String?> overrideNote = const Value.absent(),
                Value<String?> overrideTagId = const Value.absent(),
                Value<String?> overridePriority = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<bool> detachedAsSingle = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime?> cancelledAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskOccurrenceOverridesCompanion.insert(
                id: id,
                seriesId: seriesId,
                occurrenceKey: occurrenceKey,
                overrideType: overrideType,
                overrideStartAt: overrideStartAt,
                overrideDueAt: overrideDueAt,
                overrideDangerAt: overrideDangerAt,
                overrideTitle: overrideTitle,
                overrideNote: overrideNote,
                overrideTagId: overrideTagId,
                overridePriority: overridePriority,
                status: status,
                detachedAsSingle: detachedAsSingle,
                completedAt: completedAt,
                cancelledAt: cancelledAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TaskOccurrenceOverridesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({seriesId = false, overrideTagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (seriesId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.seriesId,
                                referencedTable:
                                    $$TaskOccurrenceOverridesTableReferences
                                        ._seriesIdTable(db),
                                referencedColumn:
                                    $$TaskOccurrenceOverridesTableReferences
                                        ._seriesIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (overrideTagId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.overrideTagId,
                                referencedTable:
                                    $$TaskOccurrenceOverridesTableReferences
                                        ._overrideTagIdTable(db),
                                referencedColumn:
                                    $$TaskOccurrenceOverridesTableReferences
                                        ._overrideTagIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TaskOccurrenceOverridesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskOccurrenceOverridesTable,
      TaskOccurrenceOverride,
      $$TaskOccurrenceOverridesTableFilterComposer,
      $$TaskOccurrenceOverridesTableOrderingComposer,
      $$TaskOccurrenceOverridesTableAnnotationComposer,
      $$TaskOccurrenceOverridesTableCreateCompanionBuilder,
      $$TaskOccurrenceOverridesTableUpdateCompanionBuilder,
      (TaskOccurrenceOverride, $$TaskOccurrenceOverridesTableReferences),
      TaskOccurrenceOverride,
      PrefetchHooks Function({bool seriesId, bool overrideTagId})
    >;
typedef $$HolidayCalendarEntriesTableCreateCompanionBuilder =
    HolidayCalendarEntriesCompanion Function({
      required String date,
      required String dayType,
      Value<String?> name,
      Value<String?> source,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$HolidayCalendarEntriesTableUpdateCompanionBuilder =
    HolidayCalendarEntriesCompanion Function({
      Value<String> date,
      Value<String> dayType,
      Value<String?> name,
      Value<String?> source,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$HolidayCalendarEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $HolidayCalendarEntriesTable> {
  $$HolidayCalendarEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dayType => $composableBuilder(
    column: $table.dayType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HolidayCalendarEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $HolidayCalendarEntriesTable> {
  $$HolidayCalendarEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dayType => $composableBuilder(
    column: $table.dayType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HolidayCalendarEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HolidayCalendarEntriesTable> {
  $$HolidayCalendarEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get dayType =>
      $composableBuilder(column: $table.dayType, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$HolidayCalendarEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HolidayCalendarEntriesTable,
          HolidayCalendarEntry,
          $$HolidayCalendarEntriesTableFilterComposer,
          $$HolidayCalendarEntriesTableOrderingComposer,
          $$HolidayCalendarEntriesTableAnnotationComposer,
          $$HolidayCalendarEntriesTableCreateCompanionBuilder,
          $$HolidayCalendarEntriesTableUpdateCompanionBuilder,
          (
            HolidayCalendarEntry,
            BaseReferences<
              _$AppDatabase,
              $HolidayCalendarEntriesTable,
              HolidayCalendarEntry
            >,
          ),
          HolidayCalendarEntry,
          PrefetchHooks Function()
        > {
  $$HolidayCalendarEntriesTableTableManager(
    _$AppDatabase db,
    $HolidayCalendarEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HolidayCalendarEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$HolidayCalendarEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$HolidayCalendarEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> date = const Value.absent(),
                Value<String> dayType = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HolidayCalendarEntriesCompanion(
                date: date,
                dayType: dayType,
                name: name,
                source: source,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String date,
                required String dayType,
                Value<String?> name = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HolidayCalendarEntriesCompanion.insert(
                date: date,
                dayType: dayType,
                name: name,
                source: source,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HolidayCalendarEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HolidayCalendarEntriesTable,
      HolidayCalendarEntry,
      $$HolidayCalendarEntriesTableFilterComposer,
      $$HolidayCalendarEntriesTableOrderingComposer,
      $$HolidayCalendarEntriesTableAnnotationComposer,
      $$HolidayCalendarEntriesTableCreateCompanionBuilder,
      $$HolidayCalendarEntriesTableUpdateCompanionBuilder,
      (
        HolidayCalendarEntry,
        BaseReferences<
          _$AppDatabase,
          $HolidayCalendarEntriesTable,
          HolidayCalendarEntry
        >,
      ),
      HolidayCalendarEntry,
      PrefetchHooks Function()
    >;
typedef $$SyncMetaEntriesTableCreateCompanionBuilder =
    SyncMetaEntriesCompanion Function({
      required String key,
      required String value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$SyncMetaEntriesTableUpdateCompanionBuilder =
    SyncMetaEntriesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SyncMetaEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetaEntriesTable> {
  $$SyncMetaEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetaEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetaEntriesTable> {
  $$SyncMetaEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetaEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetaEntriesTable> {
  $$SyncMetaEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SyncMetaEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetaEntriesTable,
          SyncMetaEntry,
          $$SyncMetaEntriesTableFilterComposer,
          $$SyncMetaEntriesTableOrderingComposer,
          $$SyncMetaEntriesTableAnnotationComposer,
          $$SyncMetaEntriesTableCreateCompanionBuilder,
          $$SyncMetaEntriesTableUpdateCompanionBuilder,
          (
            SyncMetaEntry,
            BaseReferences<_$AppDatabase, $SyncMetaEntriesTable, SyncMetaEntry>,
          ),
          SyncMetaEntry,
          PrefetchHooks Function()
        > {
  $$SyncMetaEntriesTableTableManager(
    _$AppDatabase db,
    $SyncMetaEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetaEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetaEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetaEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetaEntriesCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetaEntriesCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetaEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetaEntriesTable,
      SyncMetaEntry,
      $$SyncMetaEntriesTableFilterComposer,
      $$SyncMetaEntriesTableOrderingComposer,
      $$SyncMetaEntriesTableAnnotationComposer,
      $$SyncMetaEntriesTableCreateCompanionBuilder,
      $$SyncMetaEntriesTableUpdateCompanionBuilder,
      (
        SyncMetaEntry,
        BaseReferences<_$AppDatabase, $SyncMetaEntriesTable, SyncMetaEntry>,
      ),
      SyncMetaEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$TaskSeriesTableTableManager get taskSeries =>
      $$TaskSeriesTableTableManager(_db, _db.taskSeries);
  $$TaskSeriesRevisionsTableTableManager get taskSeriesRevisions =>
      $$TaskSeriesRevisionsTableTableManager(_db, _db.taskSeriesRevisions);
  $$TaskOccurrenceOverridesTableTableManager get taskOccurrenceOverrides =>
      $$TaskOccurrenceOverridesTableTableManager(
        _db,
        _db.taskOccurrenceOverrides,
      );
  $$HolidayCalendarEntriesTableTableManager get holidayCalendarEntries =>
      $$HolidayCalendarEntriesTableTableManager(
        _db,
        _db.holidayCalendarEntries,
      );
  $$SyncMetaEntriesTableTableManager get syncMetaEntries =>
      $$SyncMetaEntriesTableTableManager(_db, _db.syncMetaEntries);
}
