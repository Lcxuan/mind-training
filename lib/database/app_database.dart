import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// SQLite 中的一条训练完成记录。
class TrainingHistoryEntries extends Table {
  /// 一局训练记录的唯一标识，用作主键。
  TextColumn get id => text()();

  /// 训练类型标识，例如 `schulte`。
  TextColumn get trainingId => text()();

  /// 本局训练完成时间。
  DateTimeColumn get completedAt => dateTime()();

  /// 本局训练用时，单位为毫秒。
  IntColumn get durationMs => integer()();

  /// 不同训练的附加指标以 JSON 保存，避免每增加一种训练就改表结构。
  TextColumn get metricsJson => text().withDefault(const Constant('{}'))();

  /// 以记录 id 保证每局训练只保存一条结果。
  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Drift 数据库入口。首次启动时在应用私有目录创建 SQLite 文件。
@DriftDatabase(tables: [TrainingHistoryEntries])
class AppDatabase extends _$AppDatabase {
  /// 可传入自定义 executor 供测试或特殊运行环境使用；默认使用应用私有 SQLite 文件。
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'mind_training'));

  /// 数据库结构变更时递增版本，并在迁移策略中处理旧数据。
  @override
  int get schemaVersion => 1;
}
