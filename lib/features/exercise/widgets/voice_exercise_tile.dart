import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

import '../../../core/constants/speech_constants.dart';
import '../../../core/extensions/context_localizations.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/services/speech_model_service.dart';
import '../application/voice_engine.dart';
import '../models/exercise_config.dart';
import '../presentation/voice_exercise_screen.dart';

/// Language of the voice mode: the app language, folded to `fr` or `en`.
String voiceLanguageOf(BuildContext context) =>
    voiceLanguageFor(Localizations.localeOf(context).languageCode);

Future<bool> _defaultMicPermission() async {
  final AudioRecorder recorder = AudioRecorder();
  try {
    return await recorder.hasPermission();
  } finally {
    await recorder.dispose();
  }
}

/// True while [openVoiceExercise] runs: a double tap (tile or results
/// screen) must never open two voice sessions on one microphone.
bool _voiceOpening = false;

/// Opens the voice exercise when the model is on the device, an offline
/// voice is installed and the microphone is allowed. Returns `false` when it
/// could not open it.
Future<bool> openVoiceExercise(
  BuildContext context,
  ExerciseConfig config, {
  Future<bool> Function() micPermission = _defaultMicPermission,
  Future<bool> Function(String locale) ttsAvailable =
      FlutterTtsSynthesizer.isVoiceInstalled,
}) async {
  final SpeechModelService service = context.read<SpeechModelService>();
  final String lang = voiceLanguageOf(context);
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  final String micDenied = context.l10n.exerciseVoiceMicDenied;
  final String voiceMissing = context.l10n.exerciseVoiceTtsUnavailable;

  if (_voiceOpening) {
    return false;
  }
  _voiceOpening = true;
  // Hold the model before resolving its folder so a concurrent update check
  // cannot delete it; the voice screen releases it when it closes.
  service.acquire(lang);
  bool opened = false;
  try {
    await service.refresh(lang);
    final String? modelDir = await service.modelDir(lang);
    if (modelDir == null) {
      return false;
    }
    bool voiceInstalled;
    try {
      voiceInstalled = await ttsAvailable(kSpeechTtsLocales[lang]!);
    } catch (_) {
      voiceInstalled = false;
    }
    if (!voiceInstalled) {
      messenger.showSnackBar(SnackBar(content: Text(voiceMissing)));
      return false;
    }
    if (!await micPermission()) {
      messenger.showSnackBar(SnackBar(content: Text(micDenied)));
      return false;
    }
    if (!context.mounted) {
      return false;
    }
    context.push(
      AppRoutePath.exerciseVoice,
      extra: VoiceExerciseArgs(config: config, modelDir: modelDir),
    );
    opened = true;
    return true;
  } finally {
    _voiceOpening = false;
    if (!opened) {
      service.release(lang);
    }
  }
}

/// Fourth exercise format. Inaccessible until the speech model for the app
/// language is fully downloaded and verified, and hidden while no model is on
/// the device and the model host does not answer.
class VoiceExerciseTile extends StatefulWidget {
  const VoiceExerciseTile({
    super.key,
    required this.buildConfig,
    this.micPermission = _defaultMicPermission,
    this.ttsAvailable = FlutterTtsSynthesizer.isVoiceInstalled,
  });

  final ExerciseConfig Function() buildConfig;
  final Future<bool> Function() micPermission;
  final Future<bool> Function(String locale) ttsAvailable;

  @override
  State<VoiceExerciseTile> createState() => _VoiceExerciseTileState();
}

class _VoiceExerciseTileState extends State<VoiceExerciseTile> {
  String? _lang;
  bool? _ttsAvailable;
  bool _opening = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String lang = voiceLanguageOf(context);
    if (lang == _lang) {
      return;
    }
    _lang = lang;
    _ttsAvailable = null;
    final SpeechModelService service = context.read<SpeechModelService>();
    service.checkAvailability(lang);
    service
        .refresh(lang)
        .then((_) => service.checkForUpdate(lang))
        .catchError((Object error) {
          debugPrint('Voice model check failed: $error');
        });
    widget.ttsAvailable(kSpeechTtsLocales[lang]!).then(
      (bool available) {
        if (mounted && _lang == lang) {
          setState(() => _ttsAvailable = available);
        }
      },
      onError: (Object _) {
        if (mounted && _lang == lang) {
          setState(() => _ttsAvailable = false);
        }
      },
    );
  }

  Future<void> _onTap(SpeechModelState state) async {
    final String lang = _lang!;
    final SpeechModelService service = context.read<SpeechModelService>();
    switch (state.status) {
      case SpeechModelStatus.downloading:
        return;
      case SpeechModelStatus.absent:
      case SpeechModelStatus.error:
        await service.download(lang);
        return;
      case SpeechModelStatus.ready:
        if (_opening) {
          return;
        }
        _opening = true;
        try {
          await openVoiceExercise(
            context,
            widget.buildConfig(),
            micPermission: widget.micPermission,
            ttsAvailable: widget.ttsAvailable,
          );
        } finally {
          _opening = false;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String lang = _lang ?? voiceLanguageOf(context);
    final SpeechModelService service = context.watch<SpeechModelService>();
    final SpeechModelState state = service.stateFor(lang);
    // An installed model keeps working offline; otherwise the tile only shows
    // once the host has confirmed it publishes a model to download.
    final bool onDevice =
        state.status == SpeechModelStatus.ready ||
        state.status == SpeechModelStatus.downloading;
    if (!onDevice && service.isPublished(lang) != true) {
      return const SizedBox.shrink();
    }
    final bool ttsMissing = _ttsAvailable == false;
    final bool enabled =
        !ttsMissing && state.status != SpeechModelStatus.downloading;
    const Color color = Colors.orange;

    final String detail;
    Widget? progress;
    if (ttsMissing) {
      detail = context.l10n.exerciseVoiceTtsUnavailable;
    } else {
      switch (state.status) {
        case SpeechModelStatus.absent:
          detail = context.l10n.exerciseVoiceDownloadRequired(
            formatMegabytes(kSpeechModelSizeBytes[lang] ?? 0, lang),
          );
        case SpeechModelStatus.downloading:
          detail = context.l10n.exerciseVoiceDownloading(
            (state.progress * 100).floor(),
          );
          progress = LinearProgressIndicator(
            key: const ValueKey<String>('voice-download-progress'),
            value: state.progress,
            semanticsLabel: detail,
          );
        case SpeechModelStatus.error:
          detail = context.l10n.exerciseVoiceDownloadError;
        case SpeechModelStatus.ready:
          detail = context.l10n.exerciseVoiceDescription;
      }
    }

    // Only the title and icon fade when the tile is unavailable: the detail
    // line explains why and must stay readable.
    final double fade = enabled ? 1 : 0.5;
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      child: InkWell(
        key: const ValueKey<String>('voice-exercise-tile'),
        onTap: enabled ? () => _onTap(state) : null,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: <Widget>[
              Opacity(
                opacity: fade,
                child: CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.2),
                  child: const Icon(Icons.record_voice_over, color: color),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Opacity(
                      opacity: fade,
                      child: Text(
                        context.l10n.exerciseVoiceTitle,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      detail,
                      style: TextStyle(
                        color: state.status == SpeechModelStatus.error
                            ? colors.error
                            : null,
                      ),
                    ),
                    if (progress != null) ...<Widget>[
                      const SizedBox(height: 8),
                      progress,
                    ],
                  ],
                ),
              ),
              Opacity(
                opacity: fade,
                child: Icon(
                  state.status == SpeechModelStatus.ready
                      ? Icons.arrow_forward_ios
                      : Icons.download,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
