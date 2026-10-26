import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mathsfun/core/bootstrap.dart';
import 'package:mathsfun/core/routes/app_router.dart';
import 'package:mathsfun/data/models/exercise_metadata.dart';
import 'package:mathsfun/data/models/profile.dart';
import 'package:mathsfun/data/services/profile_service.dart';
import 'package:mathsfun/data/services/reward_service.dart';
import 'package:mathsfun/data/services/session_service.dart';
import 'package:mathsfun/data/services/speech_model_service.dart';
import 'package:mathsfun/features/exercise/models/exercise_config.dart';
import 'package:mathsfun/features/exercise/presentation/voice_exercise_screen.dart';
import 'package:mathsfun/l10n/app_localizations.dart';

import 'support/voice_fakes.dart';

const ExerciseConfig _config = ExerciseConfig(
  operation: OperationKind.multiplication,
  mode: StudyMode.exercise,
  format: ExerciseFormat.voice,
  baseNumber: 3,
  questionCount: 1,
);

/// Lets the real Hive write of the finished session complete, then settles.
Future<void> _settleWithIo(WidgetTester tester) async {
  for (int i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
  }
  await tester.pumpAndSettle();
}

void main() {
  late ProfileService profiles;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await bootstrapApp();
    profiles = ProfileService();
    await profiles.createProfile(
      nickname: 'Test',
      schoolClass: SchoolClass.ce1,
      avatarId: 'lion',
    );
  });

  Widget app(
    FakeSynthesizer synthesizer,
    FakeListener listener, {
    ExerciseConfig config = _config,
  }) {
    final GoRouter router = GoRouter(
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (_, _) => VoiceExerciseScreen(
            args: VoiceExerciseArgs(config: config, modelDir: '/m'),
            engineFactory: (_) =>
                (synthesizer: synthesizer, listener: listener),
          ),
        ),
        GoRoute(
          path: AppRoutePath.results,
          builder: (_, _) => const Text('RESULTS'),
        ),
        GoRoute(
          path: AppRoutePath.exerciseModeType,
          builder: (_, _) => const Text('MODE'),
        ),
      ],
    );
    return MultiProvider(
      providers: <ChangeNotifierProvider<ChangeNotifier>>[
        ChangeNotifierProvider<ProfileService>.value(value: profiles),
        ChangeNotifierProvider<SessionService>(create: (_) => SessionService()),
        ChangeNotifierProvider<RewardService>(create: (_) => RewardService()),
        ChangeNotifierProvider<SpeechModelService>(
          create: (_) => SpeechModelService(),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }

  // protects=a right answer gets visible feedback and the finished session
  // opens the results screen; fails_when=the screen never navigates or shows
  // no written feedback; no_claim=real TTS/ASR (fakes) and Hive on a device.
  testWidgets('answering opens the results screen', (
    WidgetTester tester,
  ) async {
    final FakeListener listener = FakeListener();
    final FakeSynthesizer synthesizer = FakeSynthesizer(listener);
    await tester.pumpWidget(app(synthesizer, listener));
    await tester.pumpAndSettle();
    expect(find.text("J'écoute…"), findsOneWidget);

    final String answer = RegExp(r'\d+')
        .allMatches(synthesizer.spoken.single)
        .map((RegExpMatch m) => int.parse(m.group(0)!))
        .reduce((int a, int b) => a * b)
        .toString();
    listener.say(answer);
    await _settleWithIo(tester);
    expect(find.text('RESULTS'), findsOneWidget);
  });

  // protects=a device that cannot speak shows why and keeps the exercise
  // usable; fails_when=the banner is missing; no_claim=real TTS failures.
  testWidgets('shows the banner when the device cannot speak', (
    WidgetTester tester,
  ) async {
    final FakeListener listener = FakeListener();
    final FakeSynthesizer synthesizer = FakeSynthesizer(listener)
      ..failSpeech = true;
    await tester.pumpWidget(app(synthesizer, listener));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('voice-tts-failed')),
      findsOneWidget,
    );
    expect(find.text("J'écoute…"), findsOneWidget);
  });

  // protects=the skip button lets a child move on (D1); fails_when=it is
  // missing or does not move to the next question; no_claim=the final save
  // (covered by 'answering opens the results screen').
  testWidgets('skip moves to the next question', (WidgetTester tester) async {
    final FakeListener listener = FakeListener();
    final FakeSynthesizer synthesizer = FakeSynthesizer(listener);
    await tester.pumpWidget(
      app(synthesizer, listener, config: _config.copyWith(questionCount: 2)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Question 1 / 2'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('voice-skip')));
    await tester.pumpAndSettle();
    expect(find.text('Question 2 / 2'), findsOneWidget);
    expect(synthesizer.spoken, hasLength(2));
    expect(listener.isListening, isTrue);
  });

  // protects=leaving the app pauses the microphone at once (privacy);
  // fails_when=the listener keeps running after AppLifecycleState.paused;
  // no_claim=real OS lifecycle events (simulated through the binding).
  testWidgets('going to the background stops the microphone', (
    WidgetTester tester,
  ) async {
    final FakeListener listener = FakeListener();
    final FakeSynthesizer synthesizer = FakeSynthesizer(listener);
    await tester.pumpWidget(app(synthesizer, listener));
    await tester.pumpAndSettle();
    expect(listener.isListening, isTrue);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pumpAndSettle();
    // No frames are drawn while hidden: only the microphone can be checked.
    expect(listener.isListening, isFalse);
    final int readings = synthesizer.spoken.length;

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(listener.isListening, isTrue);
    expect(synthesizer.spoken.length, readings + 1);
  });
}
