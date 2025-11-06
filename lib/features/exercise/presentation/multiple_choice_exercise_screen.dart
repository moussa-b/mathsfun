import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/context_localizations.dart';
import '../../../core/routes/app_router.dart';
import '../../../data/models/exercise_metadata.dart';
import '../../../data/models/exercise_session.dart';
import '../../../data/services/profile_service.dart';
import '../../../data/services/reward_service.dart';
import '../../../data/services/session_service.dart';
import '../application/exercise_controller.dart';
import '../models/exercise_config.dart';
import '../models/exercise_question.dart';

/// Exercise screen presenting multiple choice questions.
class MultipleChoiceExerciseScreen extends StatefulWidget {
  const MultipleChoiceExerciseScreen({super.key, required this.config});

  final ExerciseConfig config;

  @override
  State<MultipleChoiceExerciseScreen> createState() =>
      _MultipleChoiceExerciseScreenState();
}

class _MultipleChoiceExerciseScreenState
    extends State<MultipleChoiceExerciseScreen> {
  bool _isNavigating = false;

  @override
  Widget build(BuildContext context) {
    final profileService = context.watch<ProfileService>();
    final profile = profileService.activeProfile;
    if (profile == null) {
      return Scaffold(
        body: Center(child: Text(context.l10n.exerciseNoProfile)),
      );
    }

    final ExerciseConfig config = widget.config.copyWith(
      mode: StudyMode.exercise,
      format: ExerciseFormat.multipleChoice,
    );

    return ChangeNotifierProvider<ExerciseController>(
      create: (_) => ExerciseController(
        profileId: profile.id,
        config: config,
        sessionService: context.read<SessionService>(),
        rewardService: context.read<RewardService>(),
        rewardTitle: context.l10n.rewardBrilliantWork,
        rewardDescriptionTemplate: context.l10n.rewardScoredAccuracy(
          '{accuracy}',
        ),
      ),
      child: Consumer<ExerciseController>(
        builder: (BuildContext context, ExerciseController controller, _) {
          _maybeNavigateOnComplete(context, controller);
          final ExerciseQuestion question = controller.currentQuestion;
          return Scaffold(
            appBar: AppBar(
              title: Text(
                context.l10n.exerciseQuestionProgress(
                  controller.currentIndex + 1,
                  controller.totalQuestions,
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(24),
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
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            context.l10n.exerciseSolvePrompt,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            question.prompt,
                            style: Theme.of(context).textTheme.displayMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...question.choices.map(
                    (int choice) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ElevatedButton(
                        onPressed: () => _onChoiceSelected(
                          context,
                          controller,
                          question,
                          choice,
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          textStyle: const TextStyle(fontSize: 20),
                        ),
                        child: Text(choice.toString()),
                      ),
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

  void _onChoiceSelected(
    BuildContext context,
    ExerciseController controller,
    ExerciseQuestion question,
    int choice,
  ) {
    if (controller.isCompleted) {
      return;
    }
    final bool isCorrect = choice == question.correctAnswer;
    controller.submitMultipleChoice(choice);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCorrect
              ? context.l10n.exerciseSnackbarCorrect
              : context.l10n.exerciseSnackbarIncorrect,
        ),
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  void _maybeNavigateOnComplete(
    BuildContext context,
    ExerciseController controller,
  ) {
    if (!controller.isCompleted || _isNavigating) {
      return;
    }
    _isNavigating = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final BuildContext navContext = context;
      final ExerciseSession? session = await controller.completeAndPersist();
      if (!mounted || !navContext.mounted) {
        return;
      }
      navContext.go(AppRoutePath.results, extra: session);
    });
  }
}
