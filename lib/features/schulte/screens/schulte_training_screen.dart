import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mind_training/app/app_routes.dart';
import 'package:mind_training/features/schulte/models/schulte_mode.dart';
import 'package:mind_training/features/schulte/models/schulte_result.dart';

enum _SchultePhase { ready, running, paused, completed }

/// 舒尔特训练：按所选网格和玩法查找数字，并记录完成时长与误触数。
class SchulteTrainingScreen extends StatefulWidget {
  const SchulteTrainingScreen({super.key, this.restartFrom});

  /// 非空时沿用该局设置，并在页面首次显示后立即开始新一局。
  final SchulteResult? restartFrom;

  @override
  State<SchulteTrainingScreen> createState() => _SchulteTrainingScreenState();
}

class _SchulteTrainingScreenState extends State<SchulteTrainingScreen>
    with WidgetsBindingObserver {
  static const _availableGridSizes = [4, 5, 6];

  final _stopwatch = Stopwatch();
  final _random = Random();
  List<int> _numbers = const [];
  List<int> _targetSequence = const [];
  final Set<int> _completedNumbers = {};
  _SchultePhase _phase = _SchultePhase.ready;
  late int _gridSize;
  late SchulteMode _mode;
  // 只控制完成数字的视觉标记，不影响答题判定和进度统计。
  late bool _hideCompletedHighlight;
  int _targetIndex = 0;
  int _errorCount = 0;
  int? _wrongNumber;
  // 进入网格后先等待点击，第一次点击数字时才启动本局计时。
  bool _hasStartedTimer = false;
  Timer? _ticker;
  Timer? _feedbackTimer;

  int get _targetCount => _gridSize * _gridSize;

  int get _currentTarget => _targetSequence[_targetIndex];

  @override
  void initState() {
    super.initState();
    final previousResult = widget.restartFrom;
    _gridSize = previousResult?.gridSize ?? 5;
    _mode = previousResult?.mode ?? SchulteMode.ascending;
    _hideCompletedHighlight = previousResult?.hideCompletedHighlight ?? false;
    WidgetsBinding.instance.addObserver(this);

    if (previousResult != null) {
      // 重练入口自动生成新表，计时仍等待用户第一次点击数字。
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _startOrResume();
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 切到后台时暂停计时，避免用户离开训练时成绩继续增长。
    if (state != AppLifecycleState.resumed && _phase == _SchultePhase.running) {
      _pauseSession();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    _feedbackTimer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  void _startOrResume() {
    if (_phase == _SchultePhase.ready) {
      // 网格始终包含从 1 到 N 的全部数字，只随机改变它们的位置。
      _numbers = List.generate(_targetCount, (index) => index + 1)
        ..shuffle(_random);
      // 玩法只决定查找顺序，网格本身仍使用同一组随机数字。
      _targetSequence = _mode.targetSequence(_targetCount);
      _targetIndex = 0;
      _completedNumbers.clear();
      _errorCount = 0;
      _hasStartedTimer = false;
      _stopwatch
        ..stop()
        ..reset();
    } else if (_hasStartedTimer) {
      _stopwatch.start();
      _startTicker();
    }

    setState(() => _phase = _SchultePhase.running);
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted && _phase == _SchultePhase.running) setState(() {});
    });
  }

  void _pauseSession() {
    _ticker?.cancel();
    _stopwatch.stop();
    if (mounted) setState(() => _phase = _SchultePhase.paused);
  }

  void _onNumberTap(int number) {
    if (_phase != _SchultePhase.running) return;

    if (!_hasStartedTimer) {
      // 首次点击无论答对与否都会启动计时，再按当前目标判定是否误触。
      _hasStartedTimer = true;
      _stopwatch.start();
      _startTicker();
    }

    if (number != _currentTarget) {
      setState(() {
        _errorCount++;
        _wrongNumber = number;
      });
      _feedbackTimer?.cancel();
      _feedbackTimer = Timer(const Duration(milliseconds: 220), () {
        if (mounted) setState(() => _wrongNumber = null);
      });
      return;
    }

    final isFinalTarget = _targetIndex + 1 == _targetCount;
    setState(() {
      _completedNumbers.add(number);
      // 完成本局后保留最后一个有效下标，避免结果页弹出前触发越界重绘。
      if (isFinalTarget) {
        _phase = _SchultePhase.completed;
      } else {
        _targetIndex++;
      }
    });
    if (isFinalTarget) {
      _stopwatch.stop();
      _ticker?.cancel();
      _feedbackTimer?.cancel();
      context.pushNamed(
        AppRouteNames.schulteResult,
        extra: SchulteResult(
          completedAt: DateTime.now(),
          duration: _stopwatch.elapsed,
          errorCount: _errorCount,
          gridSize: _gridSize,
          mode: _mode,
          hideCompletedHighlight: _hideCompletedHighlight,
        ),
      );
      return;
    }
  }

  Future<void> _confirmExit() async {
    if (_phase == _SchultePhase.ready) {
      if (mounted) context.pop();
      return;
    }

    if (_phase == _SchultePhase.completed) {
      if (mounted) context.goNamed(AppRouteNames.home);
      return;
    }

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('结束本次训练？'),
        content: const Text('本次未完成的练习不会保存到记录中。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('继续练习'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('结束'),
          ),
        ],
      ),
    );

    if (shouldExit == true && mounted) {
      _ticker?.cancel();
      _stopwatch.stop();
      // 训练页可能由重练入口直接打开，没有可 pop 的上一页，因此明确返回详情页。
      context.goNamed(
        AppRouteNames.trainingDetail,
        pathParameters: {'id': 'schulte'},
      );
    }
  }

  String get _elapsedLabel {
    final elapsed = _stopwatch.elapsed;
    final minutes = elapsed.inMinutes.toString().padLeft(2, '0');
    final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
    final centiseconds = ((elapsed.inMilliseconds % 1000) ~/ 10)
        .toString()
        .padLeft(2, '0');
    return '$minutes:$seconds.$centiseconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('舒尔特表格'),
        leading: IconButton(
          tooltip: '退出训练',
          onPressed: _confirmExit,
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: _phase == _SchultePhase.ready
              ? _buildInstructions(context)
              : _buildBoard(context),
        ),
      ),
    );
  }

  Widget _buildInstructions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 14),
        Icon(
          Icons.grid_4x4_rounded,
          size: 48,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 12),
        Text(
          _mode.instruction,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          '找到目标数字后继续下一步，完成时会记录用时和误触次数。',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(height: 1.4, color: Colors.black54),
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '网格大小',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                SegmentedButton<int>(
                  segments: _availableGridSizes
                      .map(
                        (size) => ButtonSegment<int>(
                          value: size,
                          label: Text('$size × $size'),
                        ),
                      )
                      .toList(),
                  selected: {_gridSize},
                  onSelectionChanged: (selection) {
                    setState(() => _gridSize = selection.first);
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  '查找玩法',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                SegmentedButton<SchulteMode>(
                  segments: SchulteMode.values
                      .map(
                        (mode) => ButtonSegment<SchulteMode>(
                          value: mode,
                          label: Text(mode.label),
                        ),
                      )
                      .toList(),
                  selected: {_mode},
                  onSelectionChanged: (selection) {
                    setState(() => _mode = selection.first);
                  },
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: const Text('点击后不标记'),
                  subtitle: const Text('正确数字点击后不显示完成高亮'),
                  value: _hideCompletedHighlight,
                  onChanged: (value) {
                    setState(() => _hideCompletedHighlight = value);
                  },
                ),
                const SizedBox(height: 14),
                Text(
                  '首次点击数字时开始计时；误触会计入结果，但不会中断训练。',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        FilledButton.icon(
          onPressed: _startOrResume,
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Text('开始练习'),
          ),
        ),
      ],
    );
  }

  Widget _buildBoard(BuildContext context) {
    final isPaused = _phase == _SchultePhase.paused;
    final isCompleted = _phase == _SchultePhase.completed;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPaused
                        ? '训练已暂停'
                        : isCompleted
                        ? '训练已完成'
                        : '当前目标',
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(color: Colors.black54),
                  ),
                  Text(
                    isPaused
                        ? '准备好后继续'
                        : isCompleted
                        ? '本局已完成'
                        : '$_currentTarget · ${_mode.label}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '用时',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: Colors.black54),
                ),
                Text(
                  _elapsedLabel,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        LinearProgressIndicator(
          value: _completedNumbers.length / _targetCount,
          minHeight: 7,
          borderRadius: BorderRadius.circular(10),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            _hasStartedTimer ? '误触 $_errorCount 次' : '点击数字开始计时',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _numbers.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _gridSize,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                    ),
                    itemBuilder: (context, index) {
                      final number = _numbers[index];
                      final isCompleted = _completedNumbers.contains(number);
                      final showCompletedHighlight =
                          isCompleted && !_hideCompletedHighlight;
                      final isWrong = number == _wrongNumber;
                      final colors = Theme.of(context).colorScheme;
                      return Semantics(
                        button: true,
                        label: '数字 $number${isCompleted ? '，已完成' : ''}',
                        child: Material(
                          color: isWrong
                              ? colors.errorContainer
                              : showCompletedHighlight
                              ? colors.primaryContainer
                              : colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: _phase != _SchultePhase.running
                                ? null
                                : () => _onNumberTap(number),
                            child: Center(
                              child: Text(
                                '$number',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: isWrong
                                          ? colors.onErrorContainer
                                          : showCompletedHighlight
                                          ? colors.primary
                                          : null,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (isCompleted)
          OutlinedButton.icon(
            onPressed: () => context.goNamed(AppRouteNames.home),
            icon: const Icon(Icons.home_rounded),
            label: const Text('返回首页'),
          )
        else
          OutlinedButton.icon(
            onPressed: isPaused ? _startOrResume : _pauseSession,
            icon: Icon(
              isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
            ),
            label: Text(isPaused ? '继续练习' : '暂停'),
          ),
      ],
    );
  }
}
