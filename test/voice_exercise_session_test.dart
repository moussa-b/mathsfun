import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mathsfun/core/bootstrap.dart';
import 'package:mathsfun/data/local/hive_boxes.dart';
import 'package:mathsfun/data/models/exercise_metadata.dart';
import 'package:mathsfun/data/models/exercise_session.dart';
import 'package:mathsfun/data/services/reward_service.dart';
import 'package:mathsfun/data/services/session_service.dart';
import 'package:mathsfun/features/exercise/application/exercise_controller.dart';
import 'package:mathsfun/features/exercise/application/voice_engine.dart';
import 'package:mathsfun/features/exercise/application/voice_exercise_session.dart';
import 'package:mathsfun/features/exercise/models/exercise_config.dart';
import 'package:mathsfun/features/exercise/models/exercise_question.dart';

import 'support/voice_fakes.dart';

const VoicePhrases _phrases = VoicePhrases(
  readQuestion: _read,
  retry: 'RETRY',
  correct: 'BRAVO',
  incorrect: _incorrect,
);

String _read(ExerciseQuestion q) => 'READ ${q.left} ${q.right}';
String _incorrect(int answer) => 'NO $answer';

ExerciseController _controller({
  int questionCount = 2,
  DifficultyLevel difficulty = DifficultyLevel.easy,
}) => ExerciseController(
  profileId: 'voice-test',
  config: ExerciseConfig(
    operation: OperationKind.multiplication,
    mode: StudyMode.exercise,
    format: ExerciseFormat.voice,
    baseNumber: 3,
    questionCount: questionCount,
    difficultyLevel: difficulty,
  ),
  sessionService: SessionService(),
  rewardService: RewardService(),
  rewardTitle: 'r',
  rewardDescriptionTemplate: '{accuracy}',
);

/// Speaks only when the test calls [release], so a test can act mid-speech.
class _GatedSynthesizer extends FakeSynthesizer {
  _GatedSynthesizer(super.listener);

  Completer<bool>? _gate;

  @override
  Future<bool> speak(String text) {
    spoken.add(text);
    final Completer<bool> gate = Completer<bool>();
    _gate = gate;
    return gate.future;
  }

  void release() => _gate?.complete(true);
}

VoiceExerciseSession _session(
  ExerciseController controller,
  SpeechSynthesizer synthesizer,
  SpeechListener listener,
) => VoiceExerciseSession(
  controller: controller,
  synthesizer: synthesizer,
  listener: listener,
  phrases: _phrases,
  languageCode: 'fr',
  ttsLocale: 'fr-FR',
);

Future<void> _settle() async {
  for (int i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await bootstrapApp();
  });

  late FakeListener listener;
  late FakeSynthesizer synthesizer;

  setUp(() {
    listener = FakeListener();
    synthesizer = FakeSynthesizer(listener);
  });

  VoiceExerciseSession session(ExerciseController controller) =>
      VoiceExerciseSession(
        controller: controller,
        synthesizer: synthesizer,
        listener: listener,
        phrases: _phrases,
        languageCode: 'fr',
        ttsLocale: 'fr-FR',
      );

  // protects=the read → listen → judge → feedback loop (AC9, AC10);
  // fails_when=a wrong answer is not recorded as wrong, the right one is not
  // praised, or the app moves on without feedback;
  // no_claim=real TTS/ASR (fakes stand in for flutter_tts and sherpa_onnx).
  test('reads, judges right and wrong answers, then finishes', () async {
    final ExerciseController controller = _controller();
    final VoiceExerciseSession voice = session(controller);
    await voice.start();
    await _settle();

    final ExerciseQuestion first = controller.currentQuestion;
    expect(synthesizer.spoken.last, _read(first));
    expect(voice.phase, VoicePhase.listening);

    listener.say('${first.correctAnswer}');
    await _settle();
    expect(synthesizer.spoken, contains('BRAVO'));

    final ExerciseQuestion second = controller.currentQuestion;
    expect(synthesizer.spoken.last, _read(second));
    final int wrong = second.correctAnswer + 1;
    listener.say('je dirais $wrong');
    await _settle();

    expect(synthesizer.spoken.last, 'NO ${second.correctAnswer}');
    expect(voice.phase, VoicePhase.finished);
    expect(controller.results.map((QuestionResult r) => r.isCorrect),
        <bool>[true, false]);
    expect(controller.results.last.userAnswer, wrong);
    voice.dispose();
  });

  // protects=the microphone never records the app's own voice (AC8);
  // fails_when=any speak() happens while the listener is on;
  // no_claim=platform audio routing.
  test('microphone is off whenever the app speaks', () async {
    final ExerciseController controller = _controller(questionCount: 3);
    final VoiceExerciseSession voice = session(controller);
    await voice.start();
    await _settle();
    listener.say('banane');
    await _settle();
    await voice.replay();
    await _settle();
    for (int i = 0; i < 3; i++) {
      listener.say('${controller.currentQuestion.correctAnswer}');
      await _settle();
    }

    expect(synthesizer.micOnWhileSpeaking, 0);
    expect(voice.phase, VoicePhase.finished);
    voice.dispose();
  });

  // protects=an unintelligible answer asks to repeat, without counting it
  // (AC9); silence is not nagged; fails_when=noise becomes an answer or the
  // question advances; no_claim=none beyond protects.
  test('asks to repeat when not understood and ignores silence', () async {
    final ExerciseController controller = _controller();
    final VoiceExerciseSession voice = session(controller);
    await voice.start();
    await _settle();

    listener.say('   ');
    await _settle();
    expect(synthesizer.spoken.where((String s) => s == 'RETRY'), isEmpty);
    expect(voice.phase, VoicePhase.listening);

    listener.say('euh je sais pas');
    await _settle();
    expect(synthesizer.spoken.last, 'RETRY');
    expect(voice.phase, VoicePhase.listening);
    expect(controller.results, isEmpty);
    expect(controller.currentIndex, 0);
    voice.dispose();
  });

  // protects=the "listen again" button re-reads the same operation;
  // fails_when=it skips or changes the question; no_claim=none.
  test('replay reads the same operation again', () async {
    final ExerciseController controller = _controller();
    final VoiceExerciseSession voice = session(controller);
    await voice.start();
    await _settle();
    final String firstReading = synthesizer.spoken.last;

    await voice.replay();
    await _settle();
    expect(synthesizer.spoken.last, firstReading);
    expect(controller.currentIndex, 0);
    expect(voice.phase, VoicePhase.listening);
    voice.dispose();
  });

  // protects=a device that cannot speak (no offline voice, TTS error) still
  // lets the child answer: regression of the P20 Lite hang on 2026-10-26;
  // fails_when=the session stays in speakingQuestion or never listens;
  // no_claim=the real flutter_tts error path (faked here).
  test('keeps going when the device cannot speak', () async {
    synthesizer.failSpeech = true;
    final ExerciseController controller = _controller();
    final VoiceExerciseSession voice = session(controller);
    await voice.start();
    await _settle();

    expect(voice.voiceFailed, isTrue);
    expect(voice.phase, VoicePhase.listening);
    listener.say('${controller.currentQuestion.correctAnswer}');
    await _settle();
    expect(controller.results.single.isCorrect, isTrue);
    voice.dispose();
  });

  // protects=a broken model shows an error instead of hanging;
  // fails_when=phase is not failed; no_claim=none.
  test('reports failure when the recognizer cannot load', () async {
    listener.failLoad = true;
    final VoiceExerciseSession voice = session(_controller());
    await voice.start();
    expect(voice.phase, VoicePhase.failed);
    voice.dispose();
  });

  // protects=no per-question timer in voice mode, even in hard (AC11), on the
  // first question and on every following one;
  // fails_when=a question expires on its own, or the timer comes back once
  // the session advances; no_claim=none; why_new=extended to the
  // next-question branch of _recordAnswer; seam=none.
  test('voice mode has no per-question timer', () async {
    final ExerciseController controller = _controller(
      difficulty: DifficultyLevel.hard,
    );
    expect(controller.questionRemainingSeconds, isNull);
    controller.submitDirectAnswer(controller.currentQuestion.correctAnswer);
    expect(controller.currentIndex, 1);
    expect(controller.questionRemainingSeconds, isNull);
    controller.dispose();
  });

  // protects=leaving the voice screen while the app speaks (question or
  // feedback) stops the session: the microphone is never turned on again and
  // the next operation is not read; fails_when=a reading that completes after
  // dispose() starts listening or reads another question;
  // no_claim=platform TTS/recorder teardown (fakes stand in for them);
  // why_new=existing tests always dispose an idle or finished session;
  // seam=none (test-only gated fake).
  test('leaving mid-speech never turns the microphone back on', () async {
    final ExerciseController first = _controller();
    final _GatedSynthesizer gatedFirst = _GatedSynthesizer(listener);
    final VoiceExerciseSession reading = _session(first, gatedFirst, listener);
    unawaited(reading.start());
    await _settle();
    expect(reading.phase, VoicePhase.speakingQuestion);
    reading.dispose();
    gatedFirst.release();
    await _settle();
    expect(listener.starts, 0);
    expect(listener.isListening, isFalse);
    first.dispose();

    final FakeListener ear = FakeListener();
    final ExerciseController second = _controller();
    final _GatedSynthesizer gatedSecond = _GatedSynthesizer(ear);
    final VoiceExerciseSession feedback = _session(second, gatedSecond, ear);
    unawaited(feedback.start());
    await _settle();
    gatedSecond.release();
    await _settle();
    expect(feedback.phase, VoicePhase.listening);
    ear.say('${second.currentQuestion.correctAnswer}');
    await _settle();
    expect(feedback.phase, VoicePhase.speakingFeedback);
    feedback.dispose();
    gatedSecond.release();
    await _settle();
    expect(gatedSecond.spoken.last, 'BRAVO');
    expect(ear.starts, 1);
    expect(ear.isListening, isFalse);
    second.dispose();
  });

  // protects=answer time is measured from the end of the reading (AC12);
  // fails_when=the reading time is counted; no_claim=wall-clock precision.
  test('markQuestionPresented restarts the answer clock', () async {
    final ExerciseController controller = _controller();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    controller.markQuestionPresented();
    controller.submitDirectAnswer(controller.currentQuestion.correctAnswer);
    expect(controller.results.single.responseMillis, lessThan(250));
    controller.dispose();
  });

  // protects=voice sessions are stored and read back as voice (AC12, AC18);
  // fails_when=the Hive adapter maps the new index to another format;
  // no_claim=reading this data with an older app build.
  test('voice sessions round-trip through Hive', () async {
    final ExerciseController controller = _controller(questionCount: 1);
    controller.submitDirectAnswer(controller.currentQuestion.correctAnswer);
    final ExerciseSession? saved = await controller.completeAndPersist();
    final Box<ExerciseSession> box = Hive.box<ExerciseSession>(
      HiveBoxes.sessions,
    );
    await box.close();
    final Box<ExerciseSession> reopened = await Hive.openBox<ExerciseSession>(
      HiveBoxes.sessions,
    );
    final ExerciseSession reread = reopened.get(saved!.id)!;
    expect(reread.format, ExerciseFormat.voice);
    expect(reread.durationMillis, greaterThanOrEqualTo(0));
    expect(reread.questions.single.responseMillis, greaterThanOrEqualTo(0));
    await reread.delete();
  });

  // protects=microphone bytes become correct samples, including chunks
  // split on an odd byte; fails_when=sign, scale or byte order is wrong;
  // no_claim=what the record plugin actually emits on a device.
  test('Pcm16Decoder converts little-endian samples across chunks', () {
    final Pcm16Decoder decoder = Pcm16Decoder();
    final Float32List whole = decoder.convert(
      Uint8List.fromList(<int>[0x00, 0x00, 0xFF, 0x7F, 0x00, 0x80]),
    );
    expect(whole, <double>[0, 32767 / 32768, -1]);

    final Float32List partA = decoder.convert(Uint8List.fromList(<int>[0x01]));
    final Float32List partB = decoder.convert(
      Uint8List.fromList(<int>[0x00, 0xFF, 0xFF]),
    );
    expect(partA, isEmpty);
    expect(partB, <double>[1 / 32768, -1 / 32768]);
  });

  // protects=a child the recognizer cannot understand can move on (D1, design
  // finding); fails_when=skip does not record a wrong answer or does not read
  // the next question; no_claim=none beyond protects (fakes for TTS/ASR).
  test('skip records the question as wrong and reads the next one', () async {
    final ExerciseController controller = _controller();
    final VoiceExerciseSession voice = session(controller);
    await voice.start();
    await _settle();
    final ExerciseQuestion first = controller.currentQuestion;

    await voice.skip();
    await _settle();
    expect(controller.results.single.userAnswer, isNull);
    expect(controller.results.single.isCorrect, isFalse);
    expect(controller.currentQuestion, isNot(same(first)));
    expect(synthesizer.spoken.last, _read(controller.currentQuestion));
    expect(voice.phase, VoicePhase.listening);
    voice.dispose();
  });

  // protects=a phone call or lost microphone never leaves 'Listening…' on a
  // dead mic; fails_when=the session stays in listening after the stream
  // stops, or resume does not read the question again; no_claim=the real
  // record/iOS interruption events (FakeListener.interrupt stands in).
  test('an interrupted microphone pauses, resume asks again', () async {
    final ExerciseController controller = _controller();
    final VoiceExerciseSession voice = session(controller);
    await voice.start();
    await _settle();
    final int readings = synthesizer.spoken.length;

    listener.interrupt();
    await _settle();
    expect(voice.phase, VoicePhase.paused);
    expect(listener.isListening, isFalse);

    await voice.resume();
    await _settle();
    expect(synthesizer.spoken.length, readings + 1);
    expect(voice.phase, VoicePhase.listening);
    expect(controller.results, isEmpty);
    voice.dispose();
  });

  // protects=the app leaving the foreground stops the microphone at once
  // (children's privacy); fails_when=pause() keeps listening or a late answer
  // is still scored; no_claim=the real AppLifecycleState wiring of the screen.
  test('pause stops listening and ignores late transcripts', () async {
    final ExerciseController controller = _controller();
    final VoiceExerciseSession voice = session(controller);
    await voice.start();
    await _settle();

    voice.pause();
    await _settle();
    expect(listener.isListening, isFalse);
    listener.say('${controller.currentQuestion.correctAnswer}');
    await _settle();
    expect(controller.results, isEmpty);
    expect(voice.phase, VoicePhase.paused);
    voice.dispose();
  });

  // protects=a microphone that cannot start shows a recoverable state instead
  // of an uncaught error; fails_when=start() throws through the session or
  // the phase stays listening; no_claim=real recorder errors (faked).
  test('a microphone that cannot start pauses the session', () async {
    listener.failStart = true;
    final ExerciseController controller = _controller();
    final VoiceExerciseSession voice = session(controller);
    await voice.start();
    await _settle();
    expect(voice.phase, VoicePhase.paused);
    voice.dispose();
  });

  // protects=answer times stop when the child stopped speaking, not after the
  // recognizer's silence window (D4); fails_when=responseMillis includes the
  // wait between the last word and the final transcript; no_claim=real
  // endpoint timings (the gap is simulated with a short delay).
  test('response time stops at the last word heard', () async {
    final ExerciseController controller = _controller();
    final VoiceExerciseSession voice = session(controller);
    await voice.start();
    await _settle();

    listener.hear();
    await Future<void>.delayed(const Duration(milliseconds: 400));
    listener.say('${controller.currentQuestion.correctAnswer}');
    await _settle();
    expect(controller.results.single.responseMillis, lessThan(300));
    voice.dispose();
  });

  // protects=replay cannot interrupt the feedback of an answer already
  // scored; fails_when=replay during feedback re-reads or double-advances;
  // no_claim=none beyond protects.
  test('replay and skip are ignored while feedback is spoken', () async {
    final ExerciseController controller = _controller(questionCount: 3);
    final _GatedSynthesizer gated = _GatedSynthesizer(listener);
    final VoiceExerciseSession voice = _session(controller, gated, listener);
    unawaited(voice.start());
    await _settle();
    gated.release();
    await _settle();
    listener.say('${controller.currentQuestion.correctAnswer}');
    await _settle();
    expect(voice.phase, VoicePhase.speakingFeedback);
    expect(voice.canInterrupt, isFalse);

    await voice.replay();
    await voice.skip();
    expect(controller.results.length, 1);
    expect(voice.phase, VoicePhase.speakingFeedback);
    voice.dispose();
  });

  // protects=leaving the app while the feedback is spoken never reads the
  // next question in the background, and coming back moves on without
  // scoring twice; fails_when=the next question is read while paused or the
  // answer is recorded again; no_claim=real lifecycle events (pause() called).
  test('pausing during feedback resumes on the next question', () async {
    final ExerciseController controller = _controller(questionCount: 3);
    final _GatedSynthesizer gated = _GatedSynthesizer(listener);
    final VoiceExerciseSession voice = _session(controller, gated, listener);
    unawaited(voice.start());
    await _settle();
    gated.release();
    await _settle();
    listener.say('${controller.currentQuestion.correctAnswer}');
    await _settle();
    expect(voice.phase, VoicePhase.speakingFeedback);

    voice.pause();
    gated.release(); // the feedback ends while the app is away
    await _settle();
    expect(voice.phase, VoicePhase.paused);
    expect(listener.isListening, isFalse);
    final int spokenBefore = gated.spoken.length;

    unawaited(voice.resume());
    await _settle();
    expect(controller.results.length, 1);
    expect(controller.currentIndex, 1);
    expect(gated.spoken.length, spokenBefore + 1);
    voice.dispose();
  });

  // protects=leaving the app while the model loads never starts talking in
  // the background; fails_when=the first question is read while paused;
  // no_claim=real model load timing (the fake load is instant).
  test('pausing while loading waits for resume', () async {
    final ExerciseController controller = _controller();
    final VoiceExerciseSession voice = session(controller);
    final Future<void> starting = voice.start();
    voice.pause();
    await starting;
    await _settle();
    expect(synthesizer.spoken, isEmpty);
    expect(voice.phase, VoicePhase.paused);

    await voice.resume();
    await _settle();
    expect(synthesizer.spoken, hasLength(1));
    expect(voice.phase, VoicePhase.listening);
    voice.dispose();
  });

  // protects=time spent away is not counted in the answer time;
  // fails_when=responseMillis includes the pause; no_claim=wall-clock
  // precision (a 400 ms pause stands in).
  test('time spent paused is not counted', () async {
    final ExerciseController controller = _controller();
    final VoiceExerciseSession voice = session(controller);
    await voice.start();
    await _settle();
    voice.pause();
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await voice.resume();
    await _settle();
    listener.say('${controller.currentQuestion.correctAnswer}');
    await _settle();
    expect(controller.results.single.responseMillis, lessThan(300));
    voice.dispose();
  });
}

