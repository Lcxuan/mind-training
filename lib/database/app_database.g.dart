// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TrainingHistoryEntriesTable extends TrainingHistoryEntries
    with TableInfo<$TrainingHistoryEntriesTable, TrainingHistoryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrainingHistoryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trainingIdMeta = const VerificationMeta(
    'trainingId',
  );
  @override
  late final GeneratedColumn<String> trainingId = GeneratedColumn<String>(
    'training_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metricsJsonMeta = const VerificationMeta(
    'metricsJson',
  );
  @override
  late final GeneratedColumn<String> metricsJson = GeneratedColumn<String>(
    'metrics_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    trainingId,
    completedAt,
    durationMs,
    metricsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'training_history_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrainingHistoryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('training_id')) {
      context.handle(
        _trainingIdMeta,
        trainingId.isAcceptableOrUnknown(data['training_id']!, _trainingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trainingIdMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('metrics_json')) {
      context.handle(
        _metricsJsonMeta,
        metricsJson.isAcceptableOrUnknown(
          data['metrics_json']!,
          _metricsJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrainingHistoryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrainingHistoryEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      trainingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}training_id'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      metricsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metrics_json'],
      )!,
    );
  }

  @override
  $TrainingHistoryEntriesTable createAlias(String alias) {
    return $TrainingHistoryEntriesTable(attachedDatabase, alias);
  }
}

class TrainingHistoryEntry extends DataClass
    implements Insertable<TrainingHistoryEntry> {
  final String id;
  final String trainingId;
  final DateTime completedAt;
  final int durationMs;

  /// 不同训练的附加指标以 JSON 保存，避免每增加一种训练就改表结构。
  final String metricsJson;
  const TrainingHistoryEntry({
    required this.id,
    required this.trainingId,
    required this.completedAt,
    required this.durationMs,
    required this.metricsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['training_id'] = Variable<String>(trainingId);
    map['completed_at'] = Variable<DateTime>(completedAt);
    map['duration_ms'] = Variable<int>(durationMs);
    map['metrics_json'] = Variable<String>(metricsJson);
    return map;
  }

  TrainingHistoryEntriesCompanion toCompanion(bool nullToAbsent) {
    return TrainingHistoryEntriesCompanion(
      id: Value(id),
      trainingId: Value(trainingId),
      completedAt: Value(completedAt),
      durationMs: Value(durationMs),
      metricsJson: Value(metricsJson),
    );
  }

  factory TrainingHistoryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrainingHistoryEntry(
      id: serializer.fromJson<String>(json['id']),
      trainingId: serializer.fromJson<String>(json['trainingId']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      metricsJson: serializer.fromJson<String>(json['metricsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'trainingId': serializer.toJson<String>(trainingId),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'durationMs': serializer.toJson<int>(durationMs),
      'metricsJson': serializer.toJson<String>(metricsJson),
    };
  }

  TrainingHistoryEntry copyWith({
    String? id,
    String? trainingId,
    DateTime? completedAt,
    int? durationMs,
    String? metricsJson,
  }) => TrainingHistoryEntry(
    id: id ?? this.id,
    trainingId: trainingId ?? this.trainingId,
    completedAt: completedAt ?? this.completedAt,
    durationMs: durationMs ?? this.durationMs,
    metricsJson: metricsJson ?? this.metricsJson,
  );
  TrainingHistoryEntry copyWithCompanion(TrainingHistoryEntriesCompanion data) {
    return TrainingHistoryEntry(
      id: data.id.present ? data.id.value : this.id,
      trainingId: data.trainingId.present
          ? data.trainingId.value
          : this.trainingId,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      metricsJson: data.metricsJson.present
          ? data.metricsJson.value
          : this.metricsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrainingHistoryEntry(')
          ..write('id: $id, ')
          ..write('trainingId: $trainingId, ')
          ..write('completedAt: $completedAt, ')
          ..write('durationMs: $durationMs, ')
          ..write('metricsJson: $metricsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, trainingId, completedAt, durationMs, metricsJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrainingHistoryEntry &&
          other.id == this.id &&
          other.trainingId == this.trainingId &&
          other.completedAt == this.completedAt &&
          other.durationMs == this.durationMs &&
          other.metricsJson == this.metricsJson);
}

class TrainingHistoryEntriesCompanion
    extends UpdateCompanion<TrainingHistoryEntry> {
  final Value<String> id;
  final Value<String> trainingId;
  final Value<DateTime> completedAt;
  final Value<int> durationMs;
  final Value<String> metricsJson;
  final Value<int> rowid;
  const TrainingHistoryEntriesCompanion({
    this.id = const Value.absent(),
    this.trainingId = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.metricsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrainingHistoryEntriesCompanion.insert({
    required String id,
    required String trainingId,
    required DateTime completedAt,
    required int durationMs,
    this.metricsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       trainingId = Value(trainingId),
       completedAt = Value(completedAt),
       durationMs = Value(durationMs);
  static Insertable<TrainingHistoryEntry> custom({
    Expression<String>? id,
    Expression<String>? trainingId,
    Expression<DateTime>? completedAt,
    Expression<int>? durationMs,
    Expression<String>? metricsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trainingId != null) 'training_id': trainingId,
      if (completedAt != null) 'completed_at': completedAt,
      if (durationMs != null) 'duration_ms': durationMs,
      if (metricsJson != null) 'metrics_json': metricsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrainingHistoryEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? trainingId,
    Value<DateTime>? completedAt,
    Value<int>? durationMs,
    Value<String>? metricsJson,
    Value<int>? rowid,
  }) {
    return TrainingHistoryEntriesCompanion(
      id: id ?? this.id,
      trainingId: trainingId ?? this.trainingId,
      completedAt: completedAt ?? this.completedAt,
      durationMs: durationMs ?? this.durationMs,
      metricsJson: metricsJson ?? this.metricsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (trainingId.present) {
      map['training_id'] = Variable<String>(trainingId.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (metricsJson.present) {
      map['metrics_json'] = Variable<String>(metricsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrainingHistoryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('trainingId: $trainingId, ')
          ..write('completedAt: $completedAt, ')
          ..write('durationMs: $durationMs, ')
          ..write('metricsJson: $metricsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TrainingHistoryEntriesTable trainingHistoryEntries =
      $TrainingHistoryEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [trainingHistoryEntries];
}

typedef $$TrainingHistoryEntriesTableCreateCompanionBuilder =
    TrainingHistoryEntriesCompanion Function({
      required String id,
      required String trainingId,
      required DateTime completedAt,
      required int durationMs,
      Value<String> metricsJson,
      Value<int> rowid,
    });
typedef $$TrainingHistoryEntriesTableUpdateCompanionBuilder =
    TrainingHistoryEntriesCompanion Function({
      Value<String> id,
      Value<String> trainingId,
      Value<DateTime> completedAt,
      Value<int> durationMs,
      Value<String> metricsJson,
      Value<int> rowid,
    });

class $$TrainingHistoryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $TrainingHistoryEntriesTable> {
  $$TrainingHistoryEntriesTableFilterComposer({
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

  ColumnFilters<String> get trainingId => $composableBuilder(
    column: $table.trainingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metricsJson => $composableBuilder(
    column: $table.metricsJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TrainingHistoryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $TrainingHistoryEntriesTable> {
  $$TrainingHistoryEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get trainingId => $composableBuilder(
    column: $table.trainingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metricsJson => $composableBuilder(
    column: $table.metricsJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrainingHistoryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrainingHistoryEntriesTable> {
  $$TrainingHistoryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get trainingId => $composableBuilder(
    column: $table.trainingId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metricsJson => $composableBuilder(
    column: $table.metricsJson,
    builder: (column) => column,
  );
}

class $$TrainingHistoryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrainingHistoryEntriesTable,
          TrainingHistoryEntry,
          $$TrainingHistoryEntriesTableFilterComposer,
          $$TrainingHistoryEntriesTableOrderingComposer,
          $$TrainingHistoryEntriesTableAnnotationComposer,
          $$TrainingHistoryEntriesTableCreateCompanionBuilder,
          $$TrainingHistoryEntriesTableUpdateCompanionBuilder,
          (
            TrainingHistoryEntry,
            BaseReferences<
              _$AppDatabase,
              $TrainingHistoryEntriesTable,
              TrainingHistoryEntry
            >,
          ),
          TrainingHistoryEntry,
          PrefetchHooks Function()
        > {
  $$TrainingHistoryEntriesTableTableManager(
    _$AppDatabase db,
    $TrainingHistoryEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrainingHistoryEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TrainingHistoryEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TrainingHistoryEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> trainingId = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<String> metricsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrainingHistoryEntriesCompanion(
                id: id,
                trainingId: trainingId,
                completedAt: completedAt,
                durationMs: durationMs,
                metricsJson: metricsJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String trainingId,
                required DateTime completedAt,
                required int durationMs,
                Value<String> metricsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrainingHistoryEntriesCompanion.insert(
                id: id,
                trainingId: trainingId,
                completedAt: completedAt,
                durationMs: durationMs,
                metricsJson: metricsJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TrainingHistoryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrainingHistoryEntriesTable,
      TrainingHistoryEntry,
      $$TrainingHistoryEntriesTableFilterComposer,
      $$TrainingHistoryEntriesTableOrderingComposer,
      $$TrainingHistoryEntriesTableAnnotationComposer,
      $$TrainingHistoryEntriesTableCreateCompanionBuilder,
      $$TrainingHistoryEntriesTableUpdateCompanionBuilder,
      (
        TrainingHistoryEntry,
        BaseReferences<
          _$AppDatabase,
          $TrainingHistoryEntriesTable,
          TrainingHistoryEntry
        >,
      ),
      TrainingHistoryEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TrainingHistoryEntriesTableTableManager get trainingHistoryEntries =>
      $$TrainingHistoryEntriesTableTableManager(
        _db,
        _db.trainingHistoryEntries,
      );
}
