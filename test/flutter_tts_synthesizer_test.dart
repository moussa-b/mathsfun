import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mathsfun/features/exercise/application/voice_engine.dart';

/// Captures the handlers the synthesizer installs so a test can play the
/// engine's callbacks in any order.
class _ScriptedTts extends FlutterTts {
  VoidCallback? onStart;
  VoidCallback? onComplete;
  VoidCallback? onCancel;
  ErrorHandler? onError;
  Object? speakResult = 1;

  @override
  void setStartHandler(VoidCallback callback) => onStart = callback;

  @override
  void setCompletionHandler(VoidCallback callback) => onComplete = callback;

  @override
  void setCancelHandler(VoidCallback callback) => onCancel = callback;

  @override
  void setErrorHandler(ErrorHandler handler) => onError = handler;

  @override
  Future<dynamic> speak(String text, {bool focus = false}) async =>
      speakResult;

  @override
  Future<dynamic> stop() async => 1;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // protects=the P20 Lite hang fix: an engine error ends speak() with false
  // instead of waiting forever; fails_when=the error callback is ignored and
  // speak() never completes; no_claim=the real Android TTS error codes
  // (a scripted FlutterTts stands in for the plugin).
  test('an engine error ends speak with false', () async {
    final _ScriptedTts tts = _ScriptedTts();
    final FlutterTtsSynthesizer synthesizer = FlutterTtsSynthesizer(tts: tts);
    final Future<bool> spoken = synthesizer.speak('six fois sept');
    await Future<void>.delayed(Duration.zero);
    tts.onError!('Error from TextToSpeech (speak) - -4');
    expect(await spoken, isFalse);
  });

  // protects=speak() refused by the engine (not started) fails at once;
  // fails_when=a 0 result is treated as speaking; no_claim=none.
  test('a refused speak ends with false', () async {
    final _ScriptedTts tts = _ScriptedTts()..speakResult = 0;
    final FlutterTtsSynthesizer synthesizer = FlutterTtsSynthesizer(tts: tts);
    expect(await synthesizer.speak('six fois sept'), isFalse);
  });

  // protects=the microphone never opens while the app is still speaking: a
  // late cancel from the sentence a replay interrupted must not end the new
  // one (red-team finding); fails_when=the stale cancel completes the new
  // speak() before it even started; no_claim=real callback timing.
  test('a stale cancel does not end the next sentence', () async {
    final _ScriptedTts tts = _ScriptedTts();
    final FlutterTtsSynthesizer synthesizer = FlutterTtsSynthesizer(tts: tts);
    bool done = false;
    final Future<bool> first = synthesizer.speak('six fois sept');
    await synthesizer.stop();
    expect(await first, isTrue);

    final Future<bool> second = synthesizer.speak('six fois sept');
    second.then((_) => done = true);
    await Future<void>.delayed(Duration.zero);
    tts.onCancel!(); // late cancel of the first sentence
    await Future<void>.delayed(Duration.zero);
    expect(done, isFalse);

    tts.onStart!();
    tts.onComplete!();
    expect(await second, isTrue);
  });

  // protects=a newer sentence cutting an older one is not reported as a TTS
  // failure (no false 'I can't speak' banner); fails_when=the superseded
  // speak() returns false; no_claim=none.
  test('a superseded sentence counts as done, not failed', () async {
    final _ScriptedTts tts = _ScriptedTts();
    final FlutterTtsSynthesizer synthesizer = FlutterTtsSynthesizer(tts: tts);
    final Future<bool> first = synthesizer.speak('six fois sept');
    await Future<void>.delayed(Duration.zero);
    final Future<bool> second = synthesizer.speak('Bravo !');
    expect(await first, isTrue);
    tts.onStart!();
    tts.onComplete!();
    expect(await second, isTrue);
  });
}
