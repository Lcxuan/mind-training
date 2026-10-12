import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mind_training/app/app_routes.dart';
import 'package:mind_training/features/sequence_memory/models/sequence_memory_result.dart';
import 'package:mind_training/features/sequence_memory/services/sequence_generator.dart';

enum _SequencePhase {
  ready,
  showing,
  gap,
  recalling,
  feedback,
  paused,
  completed,
}

/// 序列工作记忆训练：记住依次闪现的数字，再按原顺序输入。
class SequenceMemoryTrainingScreen extends StatefulWidget {
  const SequenceMemoryTrainingScreen({super.key});

  @override
  State<SequenceMemoryTrainingScreen> createState() =>
      _SequenceMemoryTrainingScreenState();
}

class _SequenceMemoryTrainingScreenState
    extends State<SequenceMemoryTrainingScreen>
    with WidgetsBindingObserver {
  static const _startingLength = 3;
  static const _maxSequenceLength = 9;
  static const _digitDuration = Duration(milliseconds: 700);
  static const _gapDuration = Duration(milliseconds: 250);
  static const _feedbackDuration = Duration(milliseconds: 650);

  final _generator = SequenceGenerator();
  final _roundStopwatch = Stopwatch();
  late List<int> _sequence;
  final List<int> _enteredDigits = [];
  _SequencePhase _phase = _SequencePhase.ready;
  _SequencePhase _phaseBeforePause = _SequencePhase.ready;
  int _roundLength = _startingLength;
  int _shownIndex = 0;
  int _highestCompletedLength = 0;
  int _correctRounds = 0;
  int _attemptedRounds = 0;
  bool? _lastAnswerWasCorrect;
  Timer? _phaseTimer;
  Timer? _uiTicker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sequence = const [];
    _roundStopwatch.start();
    _startUiTicker();

    // 等首帧准备好后开始闪现，确保第一位数字能被用户看到。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _beginRound();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed &&
        _phase != _SequencePhase.paused &&
        _phase != _SequencePhase.ready &&
        _phase != _SequencePhase.completed) {
      // 切到后台时暂停会话；若正在看序列，返回时从当前序列开头重播。
      _phaseBeforePause = _phase;
      _phaseTimer?.cancel();
      _uiTicker?.cancel();
      _roundStopwatch.stop();
      if (mounted) setState(() => _phase = _SequencePhase.paused);
    } else if (state == AppLifecycleState.resumed &&
        _phase == _SequencePhase.paused) {
      _roundStopwatch.start();
      if (_phaseBeforePause == _SequencePhase.showing ||
          _phaseBeforePause == _SequencePhase.gap) {
        setState(() {
          _shownIndex = 0;
          _phase = _SequencePhase.showing;
        });
        _scheduleDigitTimeout();
      } else {
        setState(() => _phase = _phaseBeforePause);
        if (_phaseBeforePause == _SequencePhase.feedback) {
          _phaseTimer = Timer(_feedbackDuration, _advanceAfterFeedback);
        }
      }
      _startUiTicker();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _phaseTimer?.cancel();
    _uiTicker?.cancel();
    _roundStopwatch.stop();
    super.dispose();
  }

  void _beginRound() {
    // 每轮重新生成序列并清空输入；答对后由反馈阶段增加长度再进入下一轮。
    _phaseTimer?.cancel();
    _sequence = _generator.generate(_roundLength);
    _attemptedRounds++;
    _shownIndex = 0;
    _enteredDigits.clear();
    setState(() {
      _lastAnswerWasCorrect = null;
      _phase = _SequencePhase.showing;
    });
    _scheduleDigitTimeout();
  }

  void _scheduleDigitTimeout() {
    _phaseTimer?.cancel();
    _phaseTimer = Timer(_digitDuration, _afterDigitShown);
  }

  void _afterDigitShown() {
    // 最后一位展示结束后进入回忆阶段，其他情况先留出短暂间隔。
    if (_shownIndex == _sequence.length - 1) {
      setState(() => _phase = _SequencePhase.recalling);
      return;
    }

    setState(() => _phase = _SequencePhase.gap);
    _phaseTimer = Timer(_gapDuration, () {
      if (!mounted) return;
      setState(() {
        _shownIndex++;
        _phase = _SequencePhase.showing;
      });
      _scheduleDigitTimeout();
    });
  }

  void _appendDigit(int digit) {
    if (_phase != _SequencePhase.recalling ||
        _enteredDigits.length >= _sequence.length) {
      return;
    }
    setState(() => _enteredDigits.add(digit));
  }

  void _removeLastDigit() {
    if (_phase != _SequencePhase.recalling || _enteredDigits.isEmpty) return;
    setState(() => _enteredDigits.removeLast());
  }

  void _submitSequence() {
    // 只有填满所有输入位后才能提交，避免把未完成的回答计作错误。
    if (_phase != _SequencePhase.recalling ||
        _enteredDigits.length != _sequence.length) {
      return;
    }

    final isCorrect = List.generate(
      _sequence.length,
      (index) => _enteredDigits[index] == _sequence[index],
    ).every((matches) => matches);

    if (isCorrect) {
      _correctRounds++;
      _highestCompletedLength = _roundLength;
    }

    setState(() {
      _lastAnswerWasCorrect = isCorrect;
      _phase = _SequencePhase.feedback;
    });
    _phaseTimer?.cancel();
    _phaseTimer = Timer(_feedbackDuration, _advanceAfterFeedback);
  }

  void _advanceAfterFeedback() {
    // 首次答错或完成上限时结束；答对则增加一位继续挑战。
    _phaseTimer = null;
    if (_lastAnswerWasCorrect != true || _roundLength == _maxSequenceLength) {
      _finishSession();
      return;
    }

    _roundLength++;
    _beginRound();
  }

  void _finishSession() {
    // 完成整组递增挑战后停止计时，并把汇总数据交给结果页保存。
    _phaseTimer?.cancel();
    _uiTicker?.cancel();
    _roundStopwatch.stop();
    setState(() => _phase = _SequencePhase.completed);
    context.pushNamed(
      AppRouteNames.sequenceResult,
      extra: SequenceMemoryResult(
        completedAt: DateTime.now(),
        duration: _roundStopwatch.elapsed,
        highestCompletedLength: _highestCompletedLength,
        correctRounds: _correctRounds,
        attemptedRounds: _attemptedRounds,
        maxSequenceLength: _maxSequenceLength,
      ),
    );
  }

  void _startUiTicker() {
    _uiTicker?.cancel();
    _uiTicker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted && _phase != _SequencePhase.paused) setState(() {});
    });
  }

  Future<void> _confirmExit() async {
    // 主动退出会丢弃未完成的一局，不写入成绩历史。
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
      _phaseTimer?.cancel();
      _uiTicker?.cancel();
      _roundStopwatch.stop();
      context.goNamed(
        AppRouteNames.trainingDetail,
        pathParameters: {'id': 'sequence'},
      );
    }
  }

  String get _elapsedLabel {
    final elapsed = _roundStopwatch.elapsed;
    final minutes = elapsed.inMinutes.toString().padLeft(2, '0');
    final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _buildAnswerSlots(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 7,
      runSpacing: 7,
      children: List.generate(_roundLength, (index) {
        final hasDigit = index < _enteredDigits.length;
        return Container(
          width: 32,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: Text(
            hasDigit ? '${_enteredDigits[index]}' : '·',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        );
      }),
    );
  }

  Widget _buildDigitButton(int digit) {
    final canEnter =
        _phase == _SequencePhase.recalling &&
        _enteredDigits.length < _sequence.length;
    return OutlinedButton(
      onPressed: canEnter ? () => _appendDigit(digit) : null,
      child: Text('$digit', style: const TextStyle(fontSize: 20)),
    );
  }

  Widget _buildKeypad() {
    final canSubmit =
        _phase == _SequencePhase.recalling &&
        _enteredDigits.length == _sequence.length;
    final canDelete =
        _phase == _SequencePhase.recalling && _enteredDigits.isNotEmpty;

    return SizedBox(
      height: 224,
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        crossAxisSpacing: 9,
        mainAxisSpacing: 8,
        childAspectRatio: 2.3,
        children: [
          for (var digit = 1; digit <= 9; digit++) _buildDigitButton(digit),
          OutlinedButton.icon(
            onPressed: canDelete ? _removeLastDigit : null,
            icon: const Icon(Icons.backspace_outlined, size: 18),
            label: const Text('退格'),
          ),
          _buildDigitButton(0),
          FilledButton(
            onPressed: canSubmit ? _submitSequence : null,
            child: const Text('提交'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isShowing = _phase == _SequencePhase.showing;
    final isRecalling = _phase == _SequencePhase.recalling;
    final isFeedback = _phase == _SequencePhase.feedback;
    final isPaused = _phase == _SequencePhase.paused;

    return Scaffold(
      appBar: AppBar(
        title: const Text('序列工作记忆'),
        leading: IconButton(
          tooltip: '退出训练',
          onPressed: _confirmExit,
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '当前长度 $_roundLength 位 · 已通过 $_correctRounds 轮',
                    style: theme.textTheme.titleSmall?.copyWith(
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
                value: _highestCompletedLength / _maxSequenceLength,
                minHeight: 7,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 12),
              Text(
                '记住依次闪现的数字，再按相同顺序输入',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isShowing)
                        Text(
                          '${_sequence[_shownIndex]}',
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontSize: 80,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        )
                      else if (_phase == _SequencePhase.gap)
                        Text(
                          '···',
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: Colors.black26,
                          ),
                        )
                      else if (isRecalling || isFeedback)
                        Column(
                          children: [
                            Text(
                              isFeedback
                                  ? _lastAnswerWasCorrect == true
                                        ? '回答正确'
                                        : '序列不正确'
                                  : '输入刚才的数字顺序',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color:
                                    isFeedback && _lastAnswerWasCorrect != true
                                    ? theme.colorScheme.error
                                    : null,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildAnswerSlots(context),
                            if (isFeedback &&
                                _lastAnswerWasCorrect != true) ...[
                              const SizedBox(height: 12),
                              Text(
                                '正确顺序：${_sequence.join(' ')}',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                            if (isFeedback &&
                                _lastAnswerWasCorrect == true &&
                                _roundLength < _maxSequenceLength) ...[
                              const SizedBox(height: 12),
                              const Text('下一轮会增加一位数字'),
                            ],
                          ],
                        )
                      else if (isPaused)
                        Text(
                          '训练已暂停，返回应用后继续',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.black54,
                          ),
                        )
                      else
                        const CircularProgressIndicator(),
                    ],
                  ),
                ),
              ),
              _buildKeypad(),
            ],
          ),
        ),
      ),
    );
  }
}
