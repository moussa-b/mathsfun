import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:record/record.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

/// Reads text aloud. Abstracted so the voice screen can be tested without
/// the platform TTS plugin.
abstract class SpeechSynthesizer {
  Future<void> configure(String locale);

  /// Completes once [text] has been spoken or interrupted (`true`), or could
  /// not be spoken (`false`). Never hangs.
  Future<bool> speak(String text);

  Future<void> stop();

  Future<void> dispose();
}

/// Listens to the microphone and reports what the speaker says.
abstract class SpeechListener {
  /// Loads the recognizer. Must complete before [start].
  Future<void> load();

  /// Starts recording. [onSpeech] fires whenever new words are heard,
  /// [onFinalText] each time the speaker pauses, and [onError] if the
  /// microphone stops on its own (call, interruption, revoked permission).
  /// Throws when the microphone cannot start.
  Future<void> start({
    required void Function(String text) onFinalText,
    required void Function() onSpeech,
    required void Function(Object error) onError,
  });

  Future<void> stop();

  bool get isListening;

  Future<void> dispose();
}

/// Converts little-endian PCM 16-bit chunks into normalized float samples,
/// carrying an odd trailing byte over to the next chunk.
class Pcm16Decoder {
  int? _pendingByte;

  Float32List convert(Uint8List bytes) {
    final int offset = _pendingByte == null ? 0 : 1;
    final int available = bytes.length + offset;
    final int sampleCount = available ~/ 2;
    final Float32List samples = Float32List(sampleCount);
    int byteIndex = 0;
    for (int i = 0; i < sampleCount; i++) {
      final int low;
      if (i == 0 && _pendingByte != null) {
        low = _pendingByte!;
        _pendingByte = null;
      } else {
        low = bytes[byteIndex++];
      }
      final int high = bytes[byteIndex++];
      int value = (high << 8) | low;
      if (value >= 0x8000) {
        value -= 0x10000;
      }
      samples[i] = value / 32768.0;
    }
    _pendingByte = byteIndex < bytes.length ? bytes[byteIndex] : _pendingByte;
    return samples;
  }

  void reset() => _pendingByte = null;
}

class FlutterTtsSynthesizer implements SpeechSynthesizer {
  FlutterTtsSynthesizer({FlutterTts? tts}) : _tts = tts ?? shared {
    _tts.setStartHandler(() => _awaitingStart = false);
    _tts.setCompletionHandler(() => _finish(true));
    // A cancel that arrives before the current utterance started belongs to
    // the utterance a previous stop() interrupted: ignore it.
    _tts.setCancelHandler(() {
      if (!_awaitingStart) {
        _finish(true);
      }
    });
    _tts.setErrorHandler((dynamic _) => _finish(false));
  }

  /// One engine for the whole app: every FlutterTts instance re-points the
  /// plugin's single method channel, which would steal the callbacks of a
  /// running session.
  static final FlutterTts shared = FlutterTts();

  /// On Android a language can be "available" through a network-only voice;
  /// the voice mode needs an installed, offline one.
  static Future<bool> isVoiceInstalled(String locale) async {
    final Object? available = Platform.isAndroid
        ? await shared.isLanguageInstalled(locale)
        : await shared.isLanguageAvailable(locale);
    return available == true || available == 1;
  }

  final FlutterTts _tts;
  Completer<bool>? _pending;
  bool _awaitingStart = false;

  @override
  Future<void> configure(String locale) async {
    // Completion is tracked with the handlers above: flutter_tts never
    // completes an awaited speak() when Android reports an error.
    await _tts.awaitSpeakCompletion(false);
    await _tts.setLanguage(locale);
    await _tts.setSpeechRate(0.45);
    await _selectOfflineVoice(locale);
    // Speaker output while the microphone is in use, not the earpiece.
    await _tts.setSharedInstance(true);
    await _tts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playAndRecord,
      <IosTextToSpeechAudioCategoryOptions>[
        IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
      ],
      IosTextToSpeechAudioMode.defaultMode,
    );
  }

  Future<void> _selectOfflineVoice(String locale) async {
    if (!Platform.isAndroid) {
      return;
    }
    final Object? voices = await _tts.getVoices;
    if (voices is! List<dynamic>) {
      return;
    }
    final String wanted = locale.toLowerCase();
    for (final Object? voice in voices) {
      if (voice is! Map<dynamic, dynamic>) {
        continue;
      }
      final String voiceLocale = '${voice['locale']}'.toLowerCase();
      final String features = '${voice['features']}';
      if (voiceLocale == wanted &&
          voice['network_required'] == '0' &&
          !features.contains('notInstalled')) {
        await _tts.setVoice(<String, String>{
          'name': '${voice['name']}',
          'locale': '${voice['locale']}',
        });
        return;
      }
    }
  }

  /// Returns `false` when the engine reports an error or never finishes. A
  /// sentence cut short by a newer one counts as done, not as a failure.
  @override
  Future<bool> speak(String text) async {
    _finish(true);
    final Completer<bool> pending = Completer<bool>();
    _pending = pending;
    _awaitingStart = true;
    final Object? started = await _tts.speak(text);
    if (started != 1 && started != true && identical(_pending, pending)) {
      _finish(false);
    }
    // Safety net: generous for a short sentence, but never forever. A
    // sentence that overruns is cut, so the microphone never hears it.
    final Duration limit = Duration(milliseconds: 4000 + text.length * 150);
    return pending.future.timeout(
      limit,
      onTimeout: () async {
        if (identical(_pending, pending)) {
          _finish(false);
          await _tts.stop();
        }
        return false;
      },
    );
  }

  void _finish(bool success) {
    final Completer<bool>? pending = _pending;
    _pending = null;
    _awaitingStart = false;
    if (pending != null && !pending.isCompleted) {
      pending.complete(success);
    }
  }

  @override
  Future<void> stop() async {
    _finish(true);
    await _tts.stop();
  }

  @override
  Future<void> dispose() => stop();
}

/// Streams the microphone into a sherpa-onnx streaming transducer.
class SherpaSpeechListener implements SpeechListener {
  SherpaSpeechListener({required this.modelDir, AudioRecorder? recorder})
    : _recorder = recorder ?? AudioRecorder();

  static const int _sampleRate = 16000;

  /// Loaded recognizers, kept for the whole app run: loading one takes
  /// about 20 s on an older phone, so only the first exercise pays it. The
  /// model files are no longer needed once loaded.
  static final Map<String, Future<sherpa.OnlineRecognizer>> _loaded =
      <String, Future<sherpa.OnlineRecognizer>>{};

  /// A recorder that never starts must not block every later stop().
  static const Duration _startTimeout = Duration(seconds: 5);
  static bool _bindingsReady = false;

  final String modelDir;
  final AudioRecorder _recorder;
  final Pcm16Decoder _decoder = Pcm16Decoder();

  sherpa.OnlineRecognizer? _recognizer;
  sherpa.OnlineStream? _stream;
  StreamSubscription<Uint8List>? _subscription;
  bool _active = false;
  bool _recorderStarted = false;
  bool _disposed = false;
  String _lastPartial = '';

  /// Starts and stops run one after the other on the single native recorder.
  Future<void> _queue = Future<void>.value();

  Future<void> _serial(Future<void> Function() action) {
    final Future<void> next = _queue.then((_) => action());
    _queue = next.catchError((Object _) {});
    return next;
  }

  /// Bumped by every start/stop so a start still awaiting the recorder knows
  /// it was cancelled.
  int _generation = 0;

  @override
  bool get isListening => _active;

  @override
  Future<void> load() async {
    if (_recognizer != null || _disposed) {
      return;
    }
    if (!_bindingsReady) {
      sherpa.initBindings();
      _bindingsReady = true;
    }
    final Future<sherpa.OnlineRecognizer> loading = _loaded.putIfAbsent(
      modelDir,
      () => _loadRecognizer(modelDir),
    );
    final sherpa.OnlineRecognizer recognizer;
    try {
      recognizer = await loading;
    } catch (_) {
      _loaded.remove(modelDir);
      rethrow;
    }
    if (_disposed) {
      return;
    }
    _recognizer = recognizer;
    _stream = recognizer.createStream();
  }

  /// Loads the model on a background isolate (about 20 s on a Huawei P20
  /// Lite) so the screen stays responsive. The native recognizer has no
  /// finalizer, so its address stays valid on this isolate.
  static Future<sherpa.OnlineRecognizer> _loadRecognizer(
    String modelDir,
  ) async {
    final sherpa.OnlineRecognizerConfig config = _config(modelDir);
    final int address = await Isolate.run(() {
      sherpa.initBindings();
      return sherpa.OnlineRecognizer(config).ptr.address;
    });
    return sherpa.OnlineRecognizer.fromPtr(
      ptr: Pointer.fromAddress(address),
      config: config,
    );
  }

  static sherpa.OnlineRecognizerConfig _config(String modelDir) =>
      sherpa.OnlineRecognizerConfig(
        model: sherpa.OnlineModelConfig(
          transducer: sherpa.OnlineTransducerModelConfig(
            encoder: '$modelDir/encoder.onnx',
            decoder: '$modelDir/decoder.onnx',
            joiner: '$modelDir/joiner.onnx',
          ),
          tokens: '$modelDir/tokens.txt',
          numThreads: 2,
          debug: false,
        ),
        enableEndpoint: true,
        rule1MinTrailingSilence: 2.4,
        rule2MinTrailingSilence: 1.2,
        rule3MinUtteranceLength: 20,
        decodingMethod: 'greedy_search',
      );

  @override
  Future<void> start({
    required void Function(String text) onFinalText,
    required void Function() onSpeech,
    required void Function(Object error) onError,
  }) {
    final int generation = ++_generation;
    return _serial(
      () => _start(generation, onFinalText, onSpeech, onError),
    );
  }

  Future<void> _start(
    int generation,
    void Function(String text) onFinalText,
    void Function() onSpeech,
    void Function(Object error) onError,
  ) async {
    final sherpa.OnlineRecognizer? recognizer = _recognizer;
    final sherpa.OnlineStream? stream = _stream;
    if (recognizer == null ||
        stream == null ||
        _active ||
        _disposed ||
        generation != _generation) {
      return;
    }
    recognizer.reset(stream);
    _decoder.reset();
    _lastPartial = '';
    _active = true;
    final Stream<Uint8List> audio;
    try {
      audio = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: _sampleRate,
          numChannels: 1,
          audioInterruption: AudioInterruptionMode.pauseResume,
        ),
      ).timeout(_startTimeout);
      _recorderStarted = true;
    } catch (_) {
      if (generation == _generation) {
        _active = false;
      }
      rethrow;
    }
    if (generation != _generation || _disposed) {
      // stop() or dispose() ran while the recorder was starting.
      _active = false;
      await _stopRecorder();
      return;
    }
    _subscription = audio.listen(
      (Uint8List bytes) {
        if (generation != _generation) {
          return;
        }
        stream.acceptWaveform(
          samples: _decoder.convert(bytes),
          sampleRate: _sampleRate,
        );
        while (recognizer.isReady(stream)) {
          recognizer.decode(stream);
        }
        final String partial = recognizer.getResult(stream).text;
        if (partial.trim().isNotEmpty && partial != _lastPartial) {
          _lastPartial = partial;
          onSpeech();
        }
        if (recognizer.isEndpoint(stream)) {
          final String text = recognizer.getResult(stream).text;
          recognizer.reset(stream);
          _lastPartial = '';
          onFinalText(text);
        }
      },
      onError: (Object error) {
        if (generation == _generation) {
          _active = false;
          unawaited(_serial(_stopRecorder).catchError((Object _) {}));
          onError(error);
        }
      },
      onDone: () {
        if (generation == _generation && _active) {
          _active = false;
          onError(StateError('microphone stream ended'));
        }
      },
      cancelOnError: true,
    );
  }

  @override
  Future<void> stop() {
    _generation++;
    _active = false;
    return _serial(() async {
      await _subscription?.cancel();
      _subscription = null;
      await _stopRecorder();
    });
  }

  Future<void> _stopRecorder() async {
    if (_recorderStarted) {
      _recorderStarted = false;
      await _recorder.stop();
    }
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    await stop();
    // The recognizer stays loaded for the next exercise; only the stream goes.
    _stream?.free();
    _stream = null;
    _recognizer = null;
    await _recorder.dispose();
  }
}
