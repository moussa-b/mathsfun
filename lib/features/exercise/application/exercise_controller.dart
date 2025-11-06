import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/models/exercise_metadata.dart';
import '../../../data/models/exercise_session.dart';
import '../../../data/services/reward_service.dart';
import '../../../data/services/session_service.dart';
import '../models/exercise_config.dart';
import '../models/exercise_question.dart';
import 'question_generator.dart';

class ExerciseController extends ChangeNotifier {
  ExerciseController({
    required this.profileId,
    required this.config,
    required SessionService sessionService,
    required RewardService rewardService,
    ExerciseQuestionGenerator? generator,
    int? timedSeconds,
  }) : _sessionService = sessionService,
       _rewardService = rewardService,
       _generator = generator ?? ExerciseQuestionGenerator(),
       _timedSeconds = timedSeconds ?? config.timedSeconds,
       _sessionStart = DateTime.now() {
    _questions = _generator.generate(config);
    _questionStart = DateTime.now();
    if (config.isTimed) {
      _startTimer();
    }
  }

  final String profileId;
  final ExerciseConfig config;
  final SessionService _sessionService;
  final RewardService _rewardService;
  final ExerciseQuestionGenerator _generator;
  final int? _timedSeconds;

  late final DateTime _sessionStart;
  late DateTime _questionStart;
  late List<ExerciseQuestion> _questions;
  final List<QuestionResult> _results = <QuestionResult>[];

  int _currentIndex = 0;
  bool _isCompleted = false;
  int? _remainingSeconds;
  Timer? _timer;

  ExerciseQuestion get currentQuestion => _questions[_currentIndex];
  int get totalQuestions => _questions.length;
  int get currentIndex => _currentIndex;
  bool get isCompleted => _isCompleted;
  int? get remainingSeconds => _remainingSeconds;
  List<QuestionResult> get results =>
      List<QuestionResult>.unmodifiable(_results);

  void submitMultipleChoice(int selected) {
    if (_isCompleted) {
      return;
    }
    _recordAnswer(selected);
  }

  void submitDirectAnswer(int input) {
    if (_isCompleted) {
      return;
    }
    _recordAnswer(input);
  }

  Future<ExerciseSession?> finishEarly() async {
    if (_isCompleted) {
      return null;
    }
    _isCompleted = true;
    _timer?.cancel();
    return _persistSession();
  }

  void _recordAnswer(int userAnswer) {
    final ExerciseQuestion question = currentQuestion;
    final DateTime now = DateTime.now();
    final int responseMillis = now.difference(_questionStart).inMilliseconds;
    final bool isCorrect = userAnswer == question.correctAnswer;
    _results.add(
      QuestionResult(
        prompt: question.prompt,
        correctAnswer: question.correctAnswer,
        userAnswer: userAnswer,
        isCorrect: isCorrect,
        responseMillis: responseMillis,
      ),
    );

    if (_currentIndex >= _questions.length - 1) {
      _complete();
    } else {
      _currentIndex += 1;
      _questionStart = DateTime.now();
      notifyListeners();
    }
  }

  void _complete() {
    if (_isCompleted) {
      return;
    }
    _isCompleted = true;
    _timer?.cancel();
    notifyListeners();
  }

  void _startTimer() {
    _remainingSeconds = _timedSeconds ?? config.timedSeconds ?? 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_remainingSeconds == null) {
        timer.cancel();
        return;
      }
      _remainingSeconds = (_remainingSeconds! - 1).clamp(0, 9999);
      if (_remainingSeconds == 0) {
        timer.cancel();
        _complete();
      }
      notifyListeners();
    });
  }

  Future<ExerciseSession> _persistSession() async {
    final int durationMillis = DateTime.now()
        .difference(_sessionStart)
        .inMilliseconds;
    final double sessionAccuracy = accuracy;
    final ExerciseSession session = await _sessionService.recordSession(
      profileId: profileId,
      operation: config.operation,
      mode: config.mode,
      format: config.format,
      questions: _results,
      durationMillis: durationMillis,
      targetTable: config.baseNumber,
      timedSeconds: _timedSeconds,
      startedAt: _sessionStart,
    );
    if (sessionAccuracy >= 80) {
      await _rewardService.award(
        profileId: profileId,
        type: RewardType.star,
        title: 'Brilliant work!',
        description: 'Scored ${sessionAccuracy.toStringAsFixed(0)}% accuracy.',
        value: correctCount,
      );
    }
    return session;
  }

  Future<ExerciseSession?> completeAndPersist() async {
    if (!_isCompleted) {
      _complete();
    }
    return _persistSession();
  }

  int get correctCount =>
      _results.where((QuestionResult result) => result.isCorrect).length;

  int get incorrectCount => _results.length - correctCount;

  double get accuracy =>
      _results.isEmpty ? 0 : correctCount * 100 / _results.length;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
