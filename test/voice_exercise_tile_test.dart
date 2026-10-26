import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mathsfun/core/routes/app_router.dart';
import 'package:mathsfun/data/models/exercise_metadata.dart';
import 'package:mathsfun/data/models/exercise_session.dart';
import 'package:mathsfun/data/services/speech_model_service.dart';
import 'package:mathsfun/features/exercise/models/exercise_config.dart';
import 'package:mathsfun/features/exercise/presentation/voice_exercise_screen.dart';
import 'package:mathsfun/features/exercise/widgets/voice_exercise_tile.dart';
import 'package:mathsfun/features/results/presentation/results_screen.dart';
import 'package:mathsfun/l10n/app_localizations.dart';

/// Model service whose state the test sets by hand.
class _FakeModelService extends SpeechModelService {
  _FakeModelService(this.state);

  SpeechModelState state;
  int downloads = 0;

  @override
  SpeechModelState stateFor(String lang) => state;

  int acquired = 0;
  int acquiredAtRefresh = -1;

  @override
  void acquire(String lang) => acquired++;

  @override
  void release(String lang) => acquired--;

  @override
  Future<void> refresh(String lang) async {
    acquiredAtRefresh = acquired;
  }

  @override
  Future<void> checkForUpdate(String lang) async {}

  @override
  Future<void> download(String lang) async {
    downloads++;
    state = const SpeechModelState(
      status: SpeechModelStatus.downloading,
      progress: 0.37,
    );
    notifyListeners();
  }

  @override
  Future<String?> modelDir(String lang) async =>
      state.status == SpeechModelStatus.ready ? '/models/$lang' : null;
}

const ExerciseConfig _config = ExerciseConfig(
  operation: OperationKind.multiplication,
  mode: StudyMode.exercise,
  format: ExerciseFormat.voice,
);

Widget _app(
  _FakeModelService service, {
  bool micAllowed = true,
  bool ttsAvailable = true,
  Widget? home,
}) {
  final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (_, _) =>
            home ??
            Scaffold(
              body: VoiceExerciseTile(
                buildConfig: () => _config,
                micPermission: () async => micAllowed,
                ttsAvailable: (_) async => ttsAvailable,
              ),
            ),
      ),
      GoRoute(
        path: AppRoutePath.exerciseVoice,
        builder: (_, GoRouterState state) => Text(
          'VOICE ${(state.extra! as VoiceExerciseArgs).modelDir}',
        ),
      ),
    ],
  );
  return ChangeNotifierProvider<SpeechModelService>.value(
    value: service,
    child: MaterialApp.router(
      routerConfig: router,
      locale: const Locale('fr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

void main() {
  // protects=model absent → size shown and a tap starts the download (AC2);
  // fails_when=the tap opens the exercise or does not download;
  // no_claim=the real HTTP download (service is faked).
  testWidgets('absent model shows the size and downloads on tap', (
    WidgetTester tester,
  ) async {
    final _FakeModelService service = _FakeModelService(
      const SpeechModelState.absent(),
    );
    await tester.pumpWidget(_app(service));
    await tester.pumpAndSettle();

    expect(find.text('Téléchargement requis (71 Mo)'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('voice-exercise-tile')));
    await tester.pump();
    expect(service.downloads, 1);
    expect(find.textContaining('VOICE'), findsNothing);
  });

  // protects=no access while downloading, with visible progress (AC2);
  // fails_when=tapping during the download opens the exercise or restarts it;
  // no_claim=none beyond protects.
  testWidgets('downloading tile shows progress and ignores taps', (
    WidgetTester tester,
  ) async {
    final _FakeModelService service = _FakeModelService(
      const SpeechModelState(
        status: SpeechModelStatus.downloading,
        progress: 0.37,
      ),
    );
    await tester.pumpWidget(_app(service));
    await tester.pump();

    expect(find.text('Téléchargement… 37 %'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('voice-download-progress')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey<String>('voice-exercise-tile')));
    await tester.pump();
    expect(service.downloads, 0);
    expect(find.textContaining('VOICE'), findsNothing);
  });

  // protects=a failed download can be retried; fails_when=the error state
  // blocks retries; no_claim=none.
  testWidgets('error tile retries the download', (WidgetTester tester) async {
    final _FakeModelService service = _FakeModelService(
      const SpeechModelState(status: SpeechModelStatus.error),
    );
    await tester.pumpWidget(_app(service));
    await tester.pumpAndSettle();

    expect(
      find.text('Échec du téléchargement. Touche pour réessayer.'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey<String>('voice-exercise-tile')));
    await tester.pump();
    expect(service.downloads, 1);
  });

  // protects=ready model + mic allowed opens the voice exercise;
  // fails_when=navigation does not happen or gets the wrong model folder;
  // no_claim=the OS permission prompt.
  testWidgets('ready tile opens the voice exercise', (
    WidgetTester tester,
  ) async {
    final _FakeModelService service = _FakeModelService(
      const SpeechModelState(status: SpeechModelStatus.ready),
    );
    await tester.pumpWidget(_app(service));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('voice-exercise-tile')));
    await tester.pumpAndSettle();
    expect(find.text('VOICE /models/fr'), findsOneWidget);
  });

  // protects=a child tapping the ready tile again while it is opening (e.g.
  // during the microphone permission prompt) opens one exercise only;
  // fails_when=the _opening guard is lost and two voice screens are pushed
  // (two listeners on one microphone); no_claim=the real router stack of the
  // app (a test GoRouter stands in) and taps after the screen is shown;
  // why_new=the existing ready test taps once; seam=none (the tile's existing
  // micPermission parameter holds the first open pending).
  testWidgets('second tap while opening does not open a second exercise', (
    WidgetTester tester,
  ) async {
    final _FakeModelService service = _FakeModelService(
      const SpeechModelState(status: SpeechModelStatus.ready),
    );
    final Completer<bool> permission = Completer<bool>();
    await tester.pumpWidget(
      _app(
        service,
        home: Scaffold(
          body: VoiceExerciseTile(
            buildConfig: () => _config,
            micPermission: () => permission.future,
            ttsAvailable: (_) async => true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final Finder tile = find.byKey(const ValueKey<String>('voice-exercise-tile'));
    await tester.tap(tile);
    await tester.pump();
    await tester.tap(tile);
    await tester.pump();
    permission.complete(true);
    await tester.pumpAndSettle();
    expect(
      find.text('VOICE /models/fr', skipOffstage: false),
      findsOneWidget,
    );
  });

  // protects=mic refused → message, no navigation (AC16);
  // fails_when=the exercise opens without a microphone; no_claim=none.
  testWidgets('refused microphone shows a message', (
    WidgetTester tester,
  ) async {
    final _FakeModelService service = _FakeModelService(
      const SpeechModelState(status: SpeechModelStatus.ready),
    );
    await tester.pumpWidget(_app(service, micAllowed: false));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('voice-exercise-tile')));
    await tester.pumpAndSettle();
    expect(
      find.text("Autorise le micro dans les réglages de l'appareil pour utiliser ce mode."),
      findsOneWidget,
    );
    expect(find.textContaining('VOICE'), findsNothing);
  });

  // protects=no French voice on the device → tile locked with a reason;
  // fails_when=the tile stays usable; no_claim=real TTS voice detection.
  testWidgets('missing TTS voice locks the tile', (WidgetTester tester) async {
    final _FakeModelService service = _FakeModelService(
      const SpeechModelState(status: SpeechModelStatus.ready),
    );
    await tester.pumpWidget(_app(service, ttsAvailable: false));
    await tester.pumpAndSettle();

    expect(
      find.text(
        "La voix française n'est pas installée sur cet appareil : demande à un parent de l'installer dans les réglages de synthèse vocale de l'appareil.",
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey<String>('voice-exercise-tile')));
    await tester.pumpAndSettle();
    expect(find.textContaining('VOICE'), findsNothing);
  });

  ExerciseSession sessionOf(ExerciseFormat format) => ExerciseSession(
    id: 's',
    profileId: 'p',
    operation: OperationKind.multiplication,
    mode: StudyMode.exercise,
    format: format,
    startedAt: DateTime(2026, 10, 25),
    durationMillis: 42000,
    questions: <QuestionResult>[
      QuestionResult(
        prompt: '6 × 7',
        correctAnswer: 42,
        userAnswer: 42,
        isCorrect: true,
        responseMillis: 3240,
      ),
    ],
  );

  // protects=voice results show each answer time (AC13), other formats do
  // not change; fails_when=the time is missing for voice or shown elsewhere;
  // no_claim=none beyond protects.
  testWidgets('results show the answer time for voice sessions only', (
    WidgetTester tester,
  ) async {
    final _FakeModelService service = _FakeModelService(
      const SpeechModelState.absent(),
    );
    await tester.pumpWidget(
      _app(service, home: ResultsScreen(session: sessionOf(ExerciseFormat.voice))),
    );
    await tester.pumpAndSettle();
    expect(find.text('42 · 3,2 s'), findsOneWidget);

    await tester.pumpWidget(
      _app(
        service,
        home: ResultsScreen(session: sessionOf(ExerciseFormat.directInput)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('42 · 3,2 s'), findsNothing);
    expect(find.text('42'), findsOneWidget);
  });

  // protects=the model is held before its folder is resolved, so the update
  // check started by the tile cannot delete it under the opening exercise
  // (review pass 2); fails_when=refresh/modelDir run before acquire, or a
  // failed open leaks the hold; no_claim=the real update-check timing.
  testWidgets('opening holds the model from the first check', (
    WidgetTester tester,
  ) async {
    final _FakeModelService service = _FakeModelService(
      const SpeechModelState(status: SpeechModelStatus.ready),
    );
    await tester.pumpWidget(_app(service));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('voice-exercise-tile')));
    await tester.pumpAndSettle();
    expect(service.acquiredAtRefresh, 1);
    expect(service.acquired, 1); // handed to the voice screen

    final _FakeModelService refused = _FakeModelService(
      const SpeechModelState(status: SpeechModelStatus.ready),
    );
    await tester.pumpWidget(_app(refused, micAllowed: false));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('voice-exercise-tile')));
    await tester.pumpAndSettle();
    expect(refused.acquired, 0);
  });
}

