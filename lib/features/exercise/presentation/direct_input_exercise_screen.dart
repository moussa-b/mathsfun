import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/context_localizations.dart';
import '../../../core/routes/app_router.dart';
import '../../../data/models/exercise_session.dart';
import '../../../data/services/profile_service.dart';
import '../../../data/services/reward_service.dart';
import '../../../data/services/session_service.dart';
import '../application/exercise_controller.dart';
import '../models/exercise_config.dart';
import '../models/exercise_question.dart';

/// Exercise screen requiring learners to enter the answer directly or play timed challenge.
class DirectInputExerciseScreen extends StatefulWidget {
  const DirectInputExerciseScreen({super.key, required this.config});

  final ExerciseConfig config;

  @override
  State<DirectInputExerciseScreen> createState() =>
      _DirectInputExerciseScreenState();
}

class _DirectInputExerciseScreenState extends State<DirectInputExerciseScreen> {
  final TextEditingController _answerController = TextEditingController();
  bool _isNavigating = false;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileService>().activeProfile;
    if (profile == null) {
      return Scaffold(
        body: Center(child: Text(context.l10n.exerciseNoProfile)),
      );
    }

    return ChangeNotifierProvider<ExerciseController>(
      create: (_) => ExerciseController(
        profileId: profile.id,
        config: widget.config,
        sessionService: context.read<SessionService>(),
        rewardService: context.read<RewardService>(),
      ),
      child: Consumer<ExerciseController>(
        builder: (BuildContext context, ExerciseController controller, _) {
          _maybeNavigateOnComplete(context, controller);
          final ExerciseQuestion question = controller.currentQuestion;
          final bool isTimed = widget.config.isTimed;

          return Scaffold(
            appBar: AppBar(
              title: Text(
                isTimed
                    ? context.l10n.exerciseTimedChallengeTitle
                    : context.l10n.exerciseQuestionProgress(
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
                  if (isTimed)
                    _buildTimerBanner(context, controller)
                  else
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
                            isTimed
                                ? context.l10n.exerciseTimedBanner
                                : context.l10n.exerciseSolvePrompt,
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
                  TextField(
                    controller: _answerController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: context.l10n.exerciseAnswerLabel,
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) =>
                        _submitAnswer(context, controller, question),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: controller.isCompleted
                        ? null
                        : () => _submitAnswer(context, controller, question),
                    child: Text(context.l10n.exerciseSubmit),
                  ),
                  if (!isTimed) ...<Widget>[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: controller.isCompleted
                          ? null
                          : () => _skipQuestion(controller),
                      child: Text(context.l10n.exerciseSkip),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimerBanner(
    BuildContext context,
    ExerciseController controller,
  ) {
    final int? remaining = controller.remainingSeconds;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.timer, color: Colors.redAccent),
          const SizedBox(width: 8),
          Text(
            remaining != null
                ? context.l10n.exerciseTimedCountdown(remaining)
                : context.l10n.exerciseTimedGo,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _submitAnswer(
    BuildContext context,
    ExerciseController controller,
    ExerciseQuestion question,
  ) {
    if (_answerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.exerciseAnswerRequired)),
      );
      return;
    }

    final int? value = int.tryParse(_answerController.text.trim());
    if (value == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.exerciseDigitsOnly)));
      return;
    }

    final bool correct = value == question.correctAnswer;
    controller.submitDirectAnswer(value);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          correct
              ? context.l10n.exerciseSnackbarDirectCorrect
              : context.l10n.exerciseSnackbarDirectIncorrect,
        ),
        duration: const Duration(milliseconds: 800),
      ),
    );
    _answerController.clear();
  }

  void _skipQuestion(ExerciseController controller) {
    controller.submitDirectAnswer(-9999); // intentionally incorrect.
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
      navContext.push(AppRoutePath.results, extra: session);
    });
  }
}
