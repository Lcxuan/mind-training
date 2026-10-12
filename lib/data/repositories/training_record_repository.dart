import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:mind_training/data/models/training_record.dart';
import 'package:mind_training/database/app_database.dart';

/// 训练历史存储接口；页面通过接口读写，避免依赖具体数据库实现。
abstract interface class TrainingRecordRepository {
  Stream<List<TrainingRecord>> watchAll();
  Future<void> save(TrainingRecord record);
  Future<void> clear();
}

/// 使用 Drift / SQLite 持久化训练记录。
class DriftTrainingRecordRepository implements TrainingRecordRepository {
  const DriftTrainingRecordRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<List<TrainingRecord>> watchAll() {
    final query = _database.select(_database.trainingHistoryEntries)
      ..orderBy([(row) => OrderingTerm.desc(row.completedAt)]);

    return query.watch().map(
      (rows) => rows
          .map(
            (row) => TrainingRecord(
              id: row.id,
              trainingId: row.trainingId,
              completedAt: row.completedAt,
              duration: Duration(milliseconds: row.durationMs),
              metrics: Map<String, Object?>.from(
                jsonDecode(row.metricsJson) as Map,
              ),
            ),
          )
          .toList(),
    );
  }

  @override
  Future<void> save(TrainingRecord record) async {
    // 以 id 为主键执行 upsert，重复保存同一局不会产生重复记录。
    await _database
        .into(_database.trainingHistoryEntries)
        .insertOnConflictUpdate(
          TrainingHistoryEntriesCompanion.insert(
            id: record.id,
            trainingId: record.trainingId,
            completedAt: record.completedAt,
            durationMs: record.duration.inMilliseconds,
            metricsJson: Value(jsonEncode(record.metrics)),
          ),
        );
  }

  @override
  Future<void> clear() async {
    await _database.delete(_database.trainingHistoryEntries).go();
  }
}
