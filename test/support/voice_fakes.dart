import 'dart:async';

import 'package:mathsfun/features/exercise/application/voice_engine.dart';

/// Records what is said and checks the microphone is off while speaking.
class FakeSynthesizer implements SpeechSynthesizer {
  FakeSynthesizer(this.listener);

  final FakeListener listener;
  final List<String> spoken = <String>[];
  int micOnWhileSpeaking = 0;
  bool failSpeech = false;

  @override
  Future<void> configure(String locale) async {}

  @override
  Future<bool> speak(String text) async {
    if (listener.isListening) {
      micOnWhileSpeaking++;
    }
    spoken.add(text);
    await Future<void>.delayed(Duration.zero);
    return !failSpeech;
  }

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}

/// Lets a test play the role of the child: [say] delivers a transcript.
class FakeListener implements SpeechListener {
  void Function(String text)? _onFinalText;
  void Function()? _onSpeech;
  void Function(Object error)? _onError;
  bool _listening = false;
  int starts = 0;
  bool failLoad = false;
  bool failStart = false;

  @override
  bool get isListening => _listening;

  @override
  Future<void> load() async {
    if (failLoad) {
      throw StateError('no model');
    }
  }

  @override
  Future<void> start({
    required void Function(String text) onFinalText,
    required void Function() onSpeech,
    required void Function(Object error) onError,
  }) async {
    if (failStart) {
      throw StateError('microphone busy');
    }
    _onFinalText = onFinalText;
    _onSpeech = onSpeech;
    _onError = onError;
    _listening = true;
    starts++;
  }

  @override
  Future<void> stop() async {
    _listening = false;
  }

  @override
  Future<void> dispose() async {
    _listening = false;
  }

  /// The child starts speaking (words heard, no pause yet).
  void hear() {
    if (_listening) {
      _onSpeech?.call();
    }
  }

  /// The child pauses: [text] is the final transcript.
  void say(String text) {
    if (_listening) {
      _onFinalText?.call(text);
    }
  }

  /// The microphone stops on its own (call, interruption).
  void interrupt() {
    if (_listening) {
      _listening = false;
      _onError?.call(StateError('interrupted'));
    }
  }
}
