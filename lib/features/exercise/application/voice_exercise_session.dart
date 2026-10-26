import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/exercise_question.dart';
import 'exercise_controller.dart';
import 'spoken_number_parser.dart';
import 'voice_engine.dart';

enum VoicePhase {
  loading,
  speakingQuestion,
  listening,
  speakingRetry,
  speakingFeedback,

  /// Microphone and voice stopped (app in background, call, microphone lost);
  /// [VoiceExerciseSession.resume] or replay picks the question up again.
  paused,
  finished,
  failed,
}

/// Sentences the voice mode says, resolved from the app localizations.
@immutable
class VoicePhrases {
  const VoicePhrases({
    required this.readQuestion,
    required this.retry,
    required this.correct,
    required this.incorrect,
  });

  final String Function(ExerciseQuestion question) readQuestion;
  final String retry;
  final String correct;
  final String Function(int answer) incorrect;
}

/// Drives one oral exercise: read the operation, listen, judge, give
/// feedback, move on. The microphone is always off while the app speaks.
class VoiceExerciseSession extends ChangeNotifier {
  VoiceExerciseSession({
    required this.controller,
    required this.synthesizer,
    required this.listener,
    required this.phrases,
    required this.languageCode,
    required this.ttsLocale,
    this.feedbackHold = const Duration(milliseconds: 1500),
    SpokenNumberParser parser = const SpokenNumberParser(),
  }) : _parser = parser;

  final ExerciseController controller;
  final SpeechSynthesizer synthesizer;
  final SpeechListener listener;
  final VoicePhrases phrases;
  final String languageCode;
  final String ttsLocale;

  /// How long the feedback stays on screen when the device cannot speak it.
  final Duration feedbackHold;
  final SpokenNumberParser _parser;

  VoicePhase _phase = VoicePhase.loading;
  int? _lastHeard;
  bool? _lastCorrect;
  bool _presented = false;
  bool _disposed = false;
  bool _voiceFailed = false;
  DateTime? _lastSpeechAt;

  /// Recognizer loaded and voice configured.
  bool _ready = false;

  /// The app is not in the foreground: nothing may be spoken or heard.
  bool _backgrounded = false;

  /// Paused while the feedback of a scored answer was spoken: resuming goes
  /// to the next question instead of asking this one again.
  bool _resumeToNext = false;

  /// Bumped on every transition so a stale async step stops on its own.
  int _epoch = 0;

  static const Set<VoicePhase> _interruptible = <VoicePhase>{
    VoicePhase.speakingQuestion,
    VoicePhase.listening,
    VoicePhase.speakingRetry,
    VoicePhase.paused,
  };

  VoicePhase get phase => _phase;
  int? get lastHeard => _lastHeard;
  bool? get lastCorrect => _lastCorrect;

  /// Answer of the question the last feedback was about.
  int? get lastExpected => _lastExpected;
  int? _lastExpected;

  /// True once the device failed to speak; the exercise goes on, the child
  /// reads the operation on screen.
  bool get voiceFailed => _voiceFailed;

  /// Whether replay and skip are allowed right now.
  bool get canInterrupt => _interruptible.contains(_phase);

  Future<void> start() async {
    try {
      await listener.load();
      if (_disposed) {
        return;
      }
      await synthesizer.configure(ttsLocale);
    } catch (_) {
      if (!_disposed) {
        _setPhase(VoicePhase.failed);
      }
      return;
    }
    _ready = true;
    if (_disposed || _backgrounded) {
      return;
    }
    await _askCurrent();
  }

  /// Reads the current operation again, then listens. The question clock is
  /// not restarted. From a pause, picks the session up again.
  Future<void> replay() async {
    if (_phase == VoicePhase.paused) {
      return resume();
    }
    if (!canInterrupt) {
      return;
    }
    await _askCurrent();
  }

  /// Gives up on the current question: it is recorded as skipped (wrong).
  Future<void> skip() async {
    if (_phase == VoicePhase.paused && _resumeToNext) {
      // The answer is already scored: just move on.
      return resume();
    }
    if (!canInterrupt) {
      return;
    }
    _backgrounded = false;
    final int turn = ++_epoch;
    await _silence();
    if (turn != _epoch || _disposed) {
      return;
    }
    controller.submitDirectAnswer(null);
    await _next(turn);
  }

  /// Stops the microphone and the voice, e.g. when the app leaves the
  /// foreground or the microphone is lost. Works in every phase but the
  /// final ones; [resume] picks up where it makes sense.
  void pause() {
    if (_disposed ||
        _phase == VoicePhase.finished ||
        _phase == VoicePhase.failed ||
        _phase == VoicePhase.paused) {
      return;
    }
    _backgrounded = true;
    _epoch++;
    if (_phase == VoicePhase.speakingFeedback) {
      _resumeToNext = true;
    } else {
      // The question is read again on resume: its clock restarts then, so
      // the time spent away is not counted.
      _presented = false;
    }
    unawaited(listener.stop().catchError((Object _) {}));
    unawaited(synthesizer.stop().catchError((Object _) {}));
    _setPhase(VoicePhase.paused);
  }

  Future<void> resume() async {
    if (_phase != VoicePhase.paused || _disposed) {
      return;
    }
    _backgrounded = false;
    if (!_ready) {
      // start() is still loading and continues on its own.
      _setPhase(VoicePhase.loading);
      return;
    }
    if (_resumeToNext) {
      _resumeToNext = false;
      await _next(++_epoch);
      return;
    }
    await _askCurrent();
  }

  Future<bool> _say(String text) async {
    final bool spoken = await synthesizer.speak(text);
    if (!spoken && !_voiceFailed && !_disposed) {
      _voiceFailed = true;
      notifyListeners();
    }
    return spoken;
  }

  Future<void> _silence() async {
    try {
      await listener.stop();
      await synthesizer.stop();
    } catch (error) {
      debugPrint('Voice engines did not stop cleanly: $error');
    }
  }

  Future<void> _askCurrent() async {
    final int epoch = ++_epoch;
    await _silence();
    if (epoch != _epoch || _disposed) {
      return;
    }
    if (_backgrounded) {
      _setPhase(VoicePhase.paused);
      return;
    }
    _lastHeard = null;
    _lastCorrect = null;
    _setPhase(VoicePhase.speakingQuestion);
    await _say(phrases.readQuestion(controller.currentQuestion));
    if (epoch != _epoch || _disposed) {
      return;
    }
    if (!_presented) {
      _presented = true;
      controller.markQuestionPresented();
    }
    await _listen(epoch);
  }

  Future<void> _listen(int epoch) async {
    if (epoch != _epoch || _disposed) {
      return;
    }
    _lastSpeechAt = null;
    _setPhase(VoicePhase.listening);
    void interrupted(Object _) {
      if (epoch == _epoch && !_disposed) {
        pause();
      }
    }

    try {
      await listener.start(
        onFinalText: (String text) => _onFinalText(text, epoch),
        onSpeech: () {
          if (epoch == _epoch) {
            _lastSpeechAt = DateTime.now();
          }
        },
        onError: interrupted,
      );
      // A start that gave up silently must not leave "Listening…" on a dead
      // microphone.
      if (!listener.isListening) {
        interrupted(StateError('microphone did not start'));
      }
    } catch (error) {
      interrupted(error);
    }
  }

  Future<void> _onFinalText(String text, int epoch) async {
    if (epoch != _epoch || _phase != VoicePhase.listening || _disposed) {
      return;
    }
    // Pure silence: keep listening without nagging the child.
    if (text.trim().isEmpty) {
      return;
    }
    final int? value = _parser.parse(text, languageCode);
    final DateTime answeredAt = _lastSpeechAt ?? DateTime.now();
    final int turn = ++_epoch;
    await listener.stop();
    if (turn != _epoch || _disposed) {
      return;
    }

    if (value == null) {
      _setPhase(VoicePhase.speakingRetry);
      await _say(phrases.retry);
      await _listen(turn);
      return;
    }

    final ExerciseQuestion question = controller.currentQuestion;
    final bool correct = value == question.correctAnswer;
    _lastHeard = value;
    _lastCorrect = correct;
    _lastExpected = question.correctAnswer;
    controller.submitDirectAnswer(value, answeredAt: answeredAt);
    _setPhase(VoicePhase.speakingFeedback);
    await _say(
      correct ? phrases.correct : phrases.incorrect(question.correctAnswer),
    );
    if (turn != _epoch || _disposed) {
      return;
    }
    if (_voiceFailed) {
      // Nothing was heard: leave the written feedback on screen a moment.
      await Future<void>.delayed(feedbackHold);
      if (turn != _epoch || _disposed) {
        return;
      }
    }
    await _next(turn);
  }

  Future<void> _next(int turn) async {
    if (turn != _epoch || _disposed) {
      return;
    }
    if (controller.isCompleted) {
      _setPhase(VoicePhase.finished);
      return;
    }
    _presented = false;
    await _askCurrent();
  }

  void _setPhase(VoicePhase phase) {
    _phase = phase;
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _epoch++;
    unawaited(listener.dispose());
    unawaited(synthesizer.dispose());
    super.dispose();
  }
}
