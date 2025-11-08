import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/extensions/context_localizations.dart';
import '../../data/models/exercise_metadata.dart';
import '../../data/models/exercise_session.dart';
import '../../features/exercise/models/exercise_config.dart';
import '../../features/exercise/presentation/direct_input_exercise_screen.dart';
import '../../features/exercise/presentation/exercise_mode_type_selection_screen.dart';
import '../../features/exercise/presentation/multiple_choice_exercise_screen.dart';
import '../../features/exercise_type/presentation/exercise_type_selection_screen.dart';
import '../../features/mode/presentation/mode_selection_screen.dart';
import '../../features/profile/presentation/profile_creation_screen.dart';
import '../../features/parent_dashboard/presentation/parent_dashboard_screen.dart';
import '../../features/profile/presentation/profile_selector_screen.dart';
import '../../features/results/presentation/results_screen.dart';
import '../../features/revision/presentation/flash_card_revision_screen.dart';
import '../../features/revision/presentation/revision_mode_type_selection_screen.dart';
import '../../features/revision/presentation/revision_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/statistics/presentation/statistics_screen.dart';

/// Defines all route paths used across the app.
class AppRoutePath {
  const AppRoutePath._();

  static const String splash = '/';
  static const String profileCreate = '/profiles/create';
  static const String profileEdit = '/profiles/edit';
  static const String profileSelector = '/profiles/select';
  static const String exerciseType = '/exercise-type';
  static const String modeSelection = '/mode';
  static const String revisionModeType = '/revision-mode';
  static const String revision = '/revision';
  static const String revisionFlashCard = '/revision/flash-card';
  static const String exerciseModeType = '/exercise-mode';
  static const String exerciseMultipleChoice = '/exercise/multiple-choice';
  static const String exerciseDirectInput = '/exercise/direct-input';
  static const String results = '/results';
  static const String statistics = '/statistics';
  static const String parentDashboard = '/parent/dashboard';
}

/// Provides the application's central GoRouter configuration.
class AppRouter {
  AppRouter();

  final GoRouter router = GoRouter(
    initialLocation: AppRoutePath.splash,
    debugLogDiagnostics: true,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutePath.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutePath.profileCreate,
        name: 'profile-create',
        builder: (context, state) => const ProfileCreationScreen(),
      ),
      GoRoute(
        path: AppRoutePath.profileEdit,
        name: 'profile-edit',
        builder: (context, state) => const ProfileCreationScreen(isEditMode: true),
      ),
      GoRoute(
        path: AppRoutePath.profileSelector,
        name: 'profile-selector',
        builder: (context, state) => const ProfileSelectorScreen(),
      ),
      GoRoute(
        path: AppRoutePath.exerciseType,
        name: 'exercise-type',
        builder: (context, state) => const ExerciseTypeSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutePath.modeSelection,
        name: 'mode-selection',
        builder: (context, state) {
          final ExerciseConfig config =
              (state.extra as ExerciseConfig?) ??
              const ExerciseConfig(
                operation: OperationKind.multiplication,
                mode: StudyMode.exercise,
                format: ExerciseFormat.multipleChoice,
                difficultyLevel: DifficultyLevel.easy,
              );
          return ModeSelectionScreen(initialConfig: config);
        },
      ),
      GoRoute(
        path: AppRoutePath.revisionModeType,
        name: 'revision-mode-type',
        builder: (context, state) {
          final ExerciseConfig config = state.extra as ExerciseConfig;
          return RevisionModeTypeSelectionScreen(config: config);
        },
      ),
      GoRoute(
        path: AppRoutePath.revision,
        name: 'revision',
        builder: (context, state) {
          final ExerciseConfig config = state.extra as ExerciseConfig;
          return RevisionScreen(config: config);
        },
      ),
      GoRoute(
        path: AppRoutePath.revisionFlashCard,
        name: 'revision-flash-card',
        builder: (context, state) {
          final ExerciseConfig config = state.extra as ExerciseConfig;
          return FlashCardRevisionScreen(config: config);
        },
      ),
      GoRoute(
        path: AppRoutePath.exerciseModeType,
        name: 'exercise-mode-type',
        builder: (context, state) {
          final ExerciseConfig config = state.extra as ExerciseConfig;
          return ExerciseModeTypeSelectionScreen(config: config);
        },
      ),
      GoRoute(
        path: AppRoutePath.exerciseMultipleChoice,
        name: 'exercise-multiple-choice',
        builder: (context, state) {
          final ExerciseConfig config = state.extra as ExerciseConfig;
          return MultipleChoiceExerciseScreen(config: config);
        },
      ),
      GoRoute(
        path: AppRoutePath.exerciseDirectInput,
        name: 'exercise-direct-input',
        builder: (context, state) {
          final ExerciseConfig config = state.extra as ExerciseConfig;
          return DirectInputExerciseScreen(config: config);
        },
      ),
      GoRoute(
        path: AppRoutePath.results,
        name: 'results',
        builder: (context, state) =>
            ResultsScreen(session: state.extra as ExerciseSession?),
      ),
      GoRoute(
        path: AppRoutePath.statistics,
        name: 'statistics',
        builder: (context, state) => const StatisticsScreen(),
      ),
      GoRoute(
        path: AppRoutePath.parentDashboard,
        name: 'parent-dashboard',
        builder: (context, state) => const ParentDashboardScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text(context.l10n.errorRouteNotFound(state.uri.path)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutePath.splash),
              child: Text(context.l10n.resultsBackHome),
            ),
          ],
        ),
      ),
    ),
  );
}
