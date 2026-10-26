import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/speech_constants.dart';
import '../../../core/extensions/context_localizations.dart';
import '../../../core/routes/app_router.dart';
import '../../../data/models/exercise_metadata.dart';
import '../../../data/models/exercise_session.dart';
import '../../../data/services/profile_service.dart';
import '../../../data/services/reward_service.dart';
import '../../../data/services/session_service.dart';
import '../../../data/services/speech_model_service.dart';
import '../application/exercise_controller.dart';
import '../application/voice_engine.dart';
import '../application/voice_exercise_session.dart';
import '../models/exercise_config.dart';
import '../models/exercise_question.dart';

/// Builds the speech engines for a voice exercise; widget tests pass fakes.
typedef VoiceEngineFactory =
    ({SpeechSynthesizer synthesizer, SpeechListener listener}) Function(
      String modelDir,
    );

({SpeechSynthesizer synthesizer, SpeechListener listener}) defaultVoiceEngines(
  String modelDir,
) => (
  synthesizer: FlutterTtsSynthesizer(),
  listener: SherpaSpeechListener(modelDir: modelDir),
);

/// Arguments of the voice exercise route.
class VoiceExerciseArgs {
  const VoiceExerciseArgs({required this.config, required this.modelDir});

  final ExerciseConfig config;
  final String modelDir;
}

/// Oral exercise: the app reads each operation, listens to the answer and
/// says whether it is right.
class VoiceExerciseScreen extends StatefulWidget {
  const VoiceExerciseScreen({
    super.key,
    required this.args,
    this.engineFactory = defaultVoiceEngines,
  });

  final VoiceExerciseArgs args;
  final VoiceEngineFactory engineFactory;

  @override
  State<VoiceExerciseScreen> createState() => _VoiceExerciseScreenState();
}

class _VoiceExerciseScreenState extends State<VoiceExerciseScreen>
    with WidgetsBindingObserver {
  ExerciseController? _controller;
  VoiceExerciseSession? _session;
  SpeechModelService? _models;
  String? _lang;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_session != null) {
      return;
    }
    final String lang = voiceLanguageFor(
      Localizations.localeOf(context).languageCode,
    );
    // openVoiceExercise acquired the model for this screen; released in
    // dispose, whatever happens next.
    _models ??= context.read<SpeechModelService>();
    _lang ??= lang;
    final profile = context.read<ProfileService>().activeProfile;
    if (profile == null) {
      return;
    }
    final ExerciseController controller = ExerciseController(
      profileId: profile.id,
      config: widget.args.config,
      sessionService: context.read<SessionService>(),
      rewardService: context.read<RewardService>(),
      rewardTitle: context.l10n.rewardBrilliantWork,
      rewardDescriptionTemplate: context.l10n.rewardScoredAccuracy(
        '{accuracy}',
      ),
    );
    final engines = widget.engineFactory(widget.args.modelDir);
    final l10n = context.l10n;
    final VoiceExerciseSession session = VoiceExerciseSession(
      controller: controller,
      synthesizer: engines.synthesizer,
      listener: engines.listener,
      languageCode: lang,
      ttsLocale: kSpeechTtsLocales[lang]!,
      phrases: VoicePhrases(
        readQuestion: (ExerciseQuestion q) =>
            q.operation == OperationKind.multiplication
            ? l10n.voiceReadMultiplication(q.left, q.right)
            : l10n.voiceReadAddition(q.left, q.right),
        retry: l10n.voiceRetry,
        correct: l10n.voiceCorrect,
        incorrect: l10n.voiceIncorrect,
      ),
    )..addListener(_onSessionChanged);
    _controller = controller;
    _session = session;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        session.start();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final VoiceExerciseSession? session = _session;
    if (session == null) {
      return;
    }
    switch (state) {
      case AppLifecycleState.resumed:
        session.resume();
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        // Never keep the microphone or the voice on outside the foreground.
        session.pause();
      case AppLifecycleState.inactive:
        // Transient overlays (notification shade, control centre): keep going.
        break;
    }
  }

  void _onSessionChanged() {
    if (_session?.phase == VoicePhase.finished) {
      _navigateToResults();
    }
  }

  Future<void> _navigateToResults() async {
    if (_isNavigating) {
      return;
    }
    _isNavigating = true;
    ExerciseSession? saved;
    try {
      saved = await _controller!.completeAndPersist();
    } catch (error) {
      debugPrint('Voice session could not be saved: $error');
    }
    if (!mounted) {
      return;
    }
    context.go(AppRoutePath.results, extra: saved);
  }

  void _leave() {
    if (_isNavigating) {
      return;
    }
    _isNavigating = true;
    context.go(AppRoutePath.exerciseModeType, extra: widget.args.config);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _session?.removeListener(_onSessionChanged);
    _session?.dispose();
    _controller?.dispose();
    final String? lang = _lang;
    if (lang != null) {
      _models?.release(lang);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final VoiceExerciseSession? session = _session;
    final ExerciseController? controller = _controller;
    if (session == null || controller == null) {
      return Scaffold(
        body: Center(child: Text(context.l10n.exerciseNoProfile)),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          _leave();
        }
      },
      child: ListenableBuilder(
        listenable: session,
        builder: (BuildContext context, _) {
          final ExerciseQuestion question = controller.currentQuestion;
          final bool canInterrupt = session.canInterrupt;
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(onPressed: _leave),
              title: Text(
                context.l10n.exerciseQuestionProgress(
                  controller.currentIndex + 1,
                  controller.totalQuestions,
                ),
              ),
            ),
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          LinearProgressIndicator(
                            value:
                                (controller.currentIndex + 1) /
                                controller.totalQuestions,
                          ),
                          const SizedBox(height: 24),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Text(
                                    context.l10n.exerciseSolvePrompt,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    question.prompt,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (session.voiceFailed) ...<Widget>[
                            const SizedBox(height: 16),
                            Card(
                              key: const ValueKey<String>('voice-tts-failed'),
                              color: Theme.of(
                                context,
                              ).colorScheme.errorContainer,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(context.l10n.voiceTtsFailed),
                              ),
                            ),
                          ],
                          const SizedBox(height: 32),
                          _VoiceStatus(session: session),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        FilledButton.icon(
                          key: const ValueKey<String>('voice-replay'),
                          onPressed: canInterrupt ? session.replay : null,
                          icon: const Icon(Icons.replay),
                          label: Text(context.l10n.voiceReplay),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          key: const ValueKey<String>('voice-skip'),
                          onPressed: canInterrupt ? session.skip : null,
                          child: Text(context.l10n.exerciseSkip),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _VoiceStatus extends StatelessWidget {
  const _VoiceStatus({required this.session});

  final VoiceExerciseSession session;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextStyle? style = Theme.of(context).textTheme.titleLarge;
    switch (session.phase) {
      case VoicePhase.loading:
        return Column(
          children: <Widget>[
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              context.l10n.voiceLoading,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        );
      case VoicePhase.failed:
        return Text(
          context.l10n.voiceEngineError,
          style: style?.copyWith(color: colors.error),
          textAlign: TextAlign.center,
        );
      case VoicePhase.paused:
        return _StatusLine(
          icon: Icons.pause_circle_outline,
          color: colors.onSurfaceVariant,
          text: context.l10n.voicePaused,
        );
      case VoicePhase.listening:
        return _StatusLine(
          icon: Icons.mic,
          color: colors.primary,
          text: context.l10n.voiceListening,
        );
      case VoicePhase.speakingQuestion:
        return _StatusLine(
          icon: Icons.record_voice_over,
          color: colors.secondary,
          text: context.l10n.voiceSpeaking,
        );
      case VoicePhase.speakingRetry:
        return _StatusLine(
          icon: Icons.hearing,
          color: colors.secondary,
          text: context.l10n.voiceRetry,
        );
      case VoicePhase.speakingFeedback:
      case VoicePhase.finished:
        if (session.lastHeard == null) {
          // Finished by a skip: nothing to judge, the results are coming.
          return const Center(child: CircularProgressIndicator());
        }
        final bool correct = session.lastCorrect ?? false;
        final int? expected = session.lastExpected;
        return Column(
          children: <Widget>[
            Icon(
              correct ? Icons.check_circle : Icons.cancel,
              size: 72,
              color: correct ? Colors.green.shade700 : Colors.red.shade700,
            ),
            const SizedBox(height: 8),
            Text(
              '${session.lastHeard ?? ''}',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              correct || expected == null
                  ? context.l10n.voiceCorrect
                  : context.l10n.voiceIncorrect(expected),
              key: const ValueKey<String>('voice-feedback-text'),
              style: style,
              textAlign: TextAlign.center,
            ),
          ],
        );
    }
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Icon(icon, size: 72, color: color),
        const SizedBox(height: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
