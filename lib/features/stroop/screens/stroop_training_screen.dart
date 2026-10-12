import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mind_training/app/app_routes.dart';
import 'package:mind_training/features/stroop/models/stroop_result.dart';
import 'package:mind_training/features/stroop/models/stroop_trial.dart';
import 'package:mind_training/features/stroop/services/stroop_trial_generator.dart';

enum _StroopPhase { answering, feedback, paused, completed }

/// Stroop 训练会话：用户忽略词义，选择文字实际显示的颜色。
class StroopTrainingScreen extends StatefulWidget {
  const StroopTrainingScreen({super.key});

  @override
  State<StroopTrainingScreen> createState() => _StroopTrainingScreenState();
}

class _StroopTrainingScreenState extends State<StroopTrainingScreen>
    with WidgetsBindingObserver {
  static const _trialCount = 20;
  static const _feedbackDuration = Duration(milliseconds: 450);

  final _random = Random();
  final _roundStopwatch = Stopwatch();
  final _responseStopwatch = Stopwatch();
  late final List<StroopTrial> _trials;
  List<StroopColor> _optionOrder = [];
  _StroopPhase _phase = _StroopPhase.answering;
  _StroopPhase _phaseBeforePause = _StroopPhase.answering;
  int _trialIndex = 0;
  int _correctCount = 0;
  int _incorrectCount = 0;
  int _totalReactionTimeMs = 0;
  bool? _lastAnswerWasCorrect;
  Timer? _feedbackTimer;
  Timer? _uiTicker;

  StroopTrial get _currentTrial => _trials[_trialIndex];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _trials = StroopTrialGenerator().generate(count: _trialCount);
    _shuffleOptions();
    _roundStopwatch.start();
    _responseStopwatch.start();
    _startUiTicker();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed &&
        _phase != _StroopPhase.paused &&
        _phase != _StroopPhase.completed) {
      // 切到后台时暂停计时和反馈，避免离开应用也消耗作答时间。
      _phaseBeforePause = _phase;
      _roundStopwatch.stop();
      _responseStopwatch.stop();
      _feedbackTimer?.cancel();
      _uiTicker?.cancel();
      if (mounted) setState(() => _phase = _StroopPhase.paused);
    } else if (state == AppLifecycleState.resumed &&
        _phase == _StroopPhase.paused) {
      _roundStopwatch.start();
      if (_phaseBeforePause == _StroopPhase.answering) {
        _responseStopwatch.start();
      }
      setState(() => _phase = _phaseBeforePause);
      _startUiTicker();
      if (_phaseBeforePause == _StroopPhase.feedback) {
        _feedbackTimer = Timer(_feedbackDuration, _advanceAfterFeedback);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _feedbackTimer?.cancel();
    _uiTicker?.cancel();
    _roundStopwatch.stop();
    _responseStopwatch.stop();
    super.dispose();
  }

  void _shuffleOptions() {
    _optionOrder = StroopColor.values.toList()..shuffle(_random);
  }

  void _startUiTicker() {
    _uiTicker?.cancel();
    _uiTicker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted && _phase != _StroopPhase.paused) setState(() {});
    });
  }

  void _submitAnswer(StroopColor answer) {
    if (_phase != _StroopPhase.answering) return;

    final reactionTimeMs = _responseStopwatch.elapsedMilliseconds;
    _responseStopwatch.stop();
    _totalReactionTimeMs += reactionTimeMs;
    final isCorrect = answer == _currentTrial.fontColor;
    if (isCorrect) {
      _correctCount++;
    } else {
      _incorrectCount++;
    }

    setState(() {
      _lastAnswerWasCorrect = isCorrect;
      _phase = _StroopPhase.feedback;
    });
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(_feedbackDuration, _advanceAfterFeedback);
  }

  void _advanceAfterFeedback() {
    _feedbackTimer = null;
    if (_trialIndex == _trials.length - 1) {
      _roundStopwatch.stop();
      _uiTicker?.cancel();
      setState(() => _phase = _StroopPhase.completed);
      context.pushNamed(
        AppRouteNames.stroopResult,
        extra: StroopResult(
          completedAt: DateTime.now(),
          duration: _roundStopwatch.elapsed,
          totalTrials: _trials.length,
          correctCount: _correctCount,
          incorrectCount: _incorrectCount,
          totalReactionTimeMs: _totalReactionTimeMs,
        ),
      );
      return;
    }

    setState(() {
      _trialIndex++;
      _lastAnswerWasCorrect = null;
      _phase = _StroopPhase.answering;
      _shuffleOptions();
      _responseStopwatch
        ..reset()
        ..start();
    });
  }

  Future<void> _confirmExit() async {
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
      _feedbackTimer?.cancel();
      _uiTicker?.cancel();
      _roundStopwatch.stop();
      _responseStopwatch.stop();
      // 训练路由可能是直接打开的，明确回到训练详情以免返回栈为空。
      context.goNamed(
        AppRouteNames.trainingDetail,
        pathParameters: {'id': 'stroop'},
      );
    }
  }

  String get _elapsedLabel {
    final elapsed = _roundStopwatch.elapsed;
    final minutes = elapsed.inMinutes.toString().padLeft(2, '0');
    final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
    final centiseconds = ((elapsed.inMilliseconds % 1000) ~/ 10)
        .toString()
        .padLeft(2, '0');
    return '$minutes:$seconds.$centiseconds';
  }

  Color _colorFor(StroopColor color) => switch (color) {
    StroopColor.red => const Color(0xFFD32F2F),
    StroopColor.blue => const Color(0xFF1976D2),
    StroopColor.green => const Color(0xFF2E7D32),
    StroopColor.yellow => const Color(0xFFC99700),
  };

  Color _labelColorFor(StroopColor color) =>
      color == StroopColor.yellow ? Colors.black87 : Colors.white;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPaused = _phase == _StroopPhase.paused;
    final isFeedback = _phase == _StroopPhase.feedback;
    final isAnswering = _phase == _StroopPhase.answering;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stroop 训练'),
        leading: IconButton(
          tooltip: '退出训练',
          onPressed: _confirmExit,
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '第 ${_trialIndex + 1} / ${_trials.length} 题',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    _elapsedLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: _trialIndex / _trials.length,
                minHeight: 7,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '正确 $_correctCount 题 · 错误 $_incorrectCount 题',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '忽略文字含义，请按字体颜色作答',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Semantics(
                        label:
                            '${_currentTrial.wordColor.label}二字，字体为${_currentTrial.fontColor.label}',
                        child: Text(
                          _currentTrial.wordColor.label,
                          style: theme.textTheme.displayLarge?.copyWith(
                            color: _colorFor(_currentTrial.fontColor),
                            fontWeight: FontWeight.w900,
                            fontSize: 76,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (isFeedback)
                        Text(
                          _lastAnswerWasCorrect == true
                              ? '回答正确'
                              : '正确颜色是${_currentTrial.fontColor.label}',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: _lastAnswerWasCorrect == true
                                ? theme.colorScheme.primary
                                : theme.colorScheme.error,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      else if (isPaused)
                        Text(
                          '训练已暂停，返回应用后继续',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                          ),
                        )
                      else if (isAnswering)
                        Text(
                          '请选择字体显示的颜色',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 148,
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.6,
                  children: _optionOrder
                      .map(
                        (color) => _ColorOption(
                          color: _colorFor(color),
                          labelColor: _labelColorFor(color),
                          label: color.label,
                          onTap: isAnswering
                              ? () => _submitAnswer(color)
                              : null,
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stroop 答案按钮保留颜色底色，并同时显示颜色名称方便辨认。
class _ColorOption extends StatelessWidget {
  const _ColorOption({
    required this.color,
    required this.labelColor,
    required this.label,
    required this.onTap,
  });

  final Color color;
  final Color labelColor;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: labelColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
