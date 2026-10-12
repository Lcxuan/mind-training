# 心智训练 App

基于 Flutter 的 iOS / Android 跨平台认知训练 App 基础框架。

## 运行

需要安装 Flutter SDK，并配置对应平台的开发工具（Android Studio / Xcode）。

```sh
flutter pub get
flutter run
```

## 当前包含

- Flutter iOS 与 Android 原生工程骨架。
- Material 3 主题、GoRouter 页面路由和 Riverpod 应用状态容器。
- 首页、训练目录、训练说明、练习记录和设置页面。
- 可配置网格大小（4×4、5×5、6×6）和查找玩法（正序、倒序、两端交替）的舒尔特训练，支持计时、误触反馈、暂停/后台暂停和结果页。
- Drift / SQLite 本地训练记录表，完成一局后保存成绩并实时更新历史页。
- 完整 Stroop 训练：一致/冲突颜色词题目、字体颜色作答、用时与反应速度统计，并将结果保存到本地历史。
- 完整序列工作记忆训练：逐个闪现数字、按序复现、从 3 位逐步挑战至 9 位，并保存最高完成长度和正确率。

舒尔特训练的网格与查找顺序可在开始前选择；更丰富的个人趋势图可在后续迭代。

## 目录结构

```text
lib/
  main.dart                         # Flutter 初始化与 ProviderScope 入口
  app/                              # 应用根组件、集中式 GoRouter 路由与底部导航壳
  core/theme/                       # 全局主题与颜色样式
  core/widgets/                     # 多个功能共用的基础页面组件
  database/                         # Drift 数据库定义、生成代码与数据库 Provider
  data/models/                      # 持久化数据模型
  data/providers/                   # 数据仓储等数据层依赖的 Provider
  data/repositories/                # SQLite 训练记录读写
  features/home/                    # 首页
  features/training_catalog/        # 训练目录、训练说明与训练会话入口
  features/schulte/                 # 舒尔特训练、玩法模型和成绩
  features/stroop/                  # Stroop 训练、题目生成与成绩
  features/sequence_memory/         # 序列工作记忆训练、序列生成与成绩
  features/history/                 # 训练历史页面和状态
  features/settings/                # 设置页面
```

各功能目录内部按职责进一步划分为 `screens/`、`models/`、`services/` 和 `providers/`（只在该功能确实需要时创建）。四个底部标签由 `StatefulShellRoute.indexedStack` 管理各自的导航状态；训练说明、训练过程和结果页由根路由集中配置。

产品范围和详细技术决策见 [手机认知训练 App 方案](手机认知训练App方案.md)。
