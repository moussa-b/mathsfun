// Drives the app through the App Store screens. Each `SHOT:<name>` line tells
// tool/appstore_screenshots.sh to capture the simulator. Run through that
// script, not directly.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'package:mathsfun/core/app.dart';
import 'package:mathsfun/core/bootstrap.dart';
import 'package:mathsfun/core/routes/app_router.dart';
import 'package:mathsfun/data/models/exercise_metadata.dart';
import 'package:mathsfun/data/models/profile.dart';
import 'package:mathsfun/data/services/profile_service.dart';
import 'package:mathsfun/data/services/settings_service.dart';
import 'package:mathsfun/features/exercise/models/exercise_config.dart';

const String _language = String.fromEnvironment(
  'SHOT_LANG',
  defaultValue: 'en',
);

Future<void> _wait([int milliseconds = 1500]) =>
    Future<void>.delayed(Duration(milliseconds: milliseconds));

Future<void> _shot(String name) async {
  await _wait();
  // ignore: avoid_print
  print('SHOT:$name');
  // Leaves the host script time to capture before the next screen.
  await _wait(3000);
}

void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('App Store screenshots', (WidgetTester tester) async {
    await bootstrapApp();
    await tester.pumpWidget(const MathsFunApp());
    await _wait(3000);

    final BuildContext context = tester.element(find.byType(Scaffold).first);
    final ProfileService profiles = context.read<ProfileService>();
    final SettingsService settings = context.read<SettingsService>();
    final GoRouter router = GoRouter.of(context);

    await settings.setLocale(Locale(_language));

    const List<(String, SchoolClass, String)> demoProfiles =
        <(String, SchoolClass, String)>[
          ('Amadou', SchoolClass.cm1, 'astronaut'),
          ('Amina', SchoolClass.ce2, 'dino'),
          ('Céleste', SchoolClass.cp, 'robot'),
        ];
    for (final (String name, SchoolClass schoolClass, String avatar)
        in demoProfiles) {
      if (!profiles.profiles.any((Profile p) => p.nickname == name)) {
        await profiles.createProfile(
          nickname: name,
          schoolClass: schoolClass,
          avatarId: avatar,
        );
        await _wait(500);
      }
    }
    final Profile amadou = profiles.profiles.firstWhere(
      (Profile p) => p.nickname == 'Amadou',
    );
    await profiles.setActiveProfile(amadou.id);

    await settings.setLastExerciseSelectedTables(
      OperationKind.multiplication,
      <int>{7, 8},
    );
    await settings.setLastExerciseDifficultyLevel(
      OperationKind.multiplication,
      DifficultyLevel.easy,
    );

    const ExerciseConfig multiplication = ExerciseConfig(
      operation: OperationKind.multiplication,
      mode: StudyMode.exercise,
      format: ExerciseFormat.multipleChoice,
      baseNumber: 7,
    );

    Future<void> openFromHome(String path, ExerciseConfig config) async {
      router.go(AppRoutePath.exerciseType);
      await _wait(800);
      router.push(path, extra: config);
    }

    router.go(AppRoutePath.profileSelector);
    await _shot('01_profiles');

    router.go(AppRoutePath.exerciseType);
    await _shot('02_adventure');

    await openFromHome(AppRoutePath.modeSelection, multiplication);
    await _shot('03_mode');

    await openFromHome(
      AppRoutePath.revisionFlashCard,
      multiplication.copyWith(
        mode: StudyMode.revision,
        baseNumber: 8,
        revisionFormat: RevisionFormat.flashCard,
      ),
    );
    await _shot('04_flash_cards');

    await openFromHome(AppRoutePath.exerciseModeType, multiplication);
    await _shot('05_exercise_style');

    await openFromHome(
      AppRoutePath.exerciseMultipleChoice,
      multiplication.copyWith(selectedTables: <int>[7], questionCount: 20),
    );
    await _shot('06_multiple_choice');

    await openFromHome(
      AppRoutePath.exerciseDirectInput,
      multiplication.copyWith(
        format: ExerciseFormat.directInput,
        selectedTables: <int>[7],
        questionCount: 24,
      ),
    );
    await _shot('07_direct_input');

    await openFromHome(
      AppRoutePath.exerciseDirectInput,
      multiplication.copyWith(
        format: ExerciseFormat.timedChallenge,
        selectedTables: <int>[7],
        timedSeconds: settings.settings.timedChallengeSeconds,
      ),
    );
    await _shot('08_timed_challenge');

    router.go(AppRoutePath.exerciseType);
    await _wait();
  });
}
