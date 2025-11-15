import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_localizations.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/exercise_metadata.dart';
import '../../../data/models/exercise_session.dart';
import '../../exercise/models/exercise_config.dart';

/// Displays the outcome summary after completing an exercise session.
class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key, this.session});

  final ExerciseSession? session;

  @override
  Widget build(BuildContext context) {
    if (session == null) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(context.l10n.resultsTitle),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(context.l10n.resultsNoSession),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  // Create a default config for navigation
                  final ExerciseConfig defaultConfig = const ExerciseConfig(
                    operation: OperationKind.multiplication,
                    mode: StudyMode.exercise,
                    format: ExerciseFormat.multipleChoice,
                  );
                  context.push(AppRoutePath.exerciseModeType, extra: defaultConfig);
                },
                child: Text(context.l10n.resultsBackHome),
              ),
            ],
          ),
        ),
      );
    }

    final ExerciseSession current = session!;
    final Duration duration = Duration(milliseconds: current.durationMillis);
    final int total = current.totalQuestions;
    final int correct = current.correctCount;
    final int mistakes = current.incorrectCount;
    final double accuracy = current.accuracy;
    final ExerciseConfig replayConfig = ExerciseConfig(
      operation: current.operation,
      mode: current.mode,
      format: current.format,
      baseNumber: current.targetTable ?? 2,
      questionCount: current.questions.length,
      timedSeconds: current.timedSeconds,
    );
    final ExerciseConfig backConfig = ExerciseConfig(
      operation: current.operation,
      mode: StudyMode.exercise,
      format: ExerciseFormat.multipleChoice, // Default format, will be changed in selection screen
      baseNumber: current.targetTable ?? 2,
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(context.l10n.resultsTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                context.l10n.resultsHeading,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              _SummaryRow(
                icon: Icons.emoji_events,
                label: context.l10n.resultsAccuracy,
                value: '${accuracy.toStringAsFixed(0)}%',
              ),
              _SummaryRow(
                icon: Icons.check_circle_outline,
                label: context.l10n.resultsCorrect,
                value: '$correct / $total',
              ),
              _SummaryRow(
                icon: Icons.close_rounded,
                label: context.l10n.resultsMistakes,
                value: mistakes.toString(),
              ),
              _SummaryRow(
                icon: Icons.timer,
                label: context.l10n.resultsTime,
                value: formatDuration(duration),
              ),
              if (current.timedSeconds != null)
                _SummaryRow(
                  icon: Icons.flash_on,
                  label: context.l10n.resultsTimedGoal,
                  value: context.l10n.resultsTimedValue(current.timedSeconds!),
                ),
              const SizedBox(height: 16),
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: current.questions.length,
                    itemBuilder: (BuildContext context, int index) {
                      final QuestionResult result = current.questions[index];
                      return ListTile(
                        leading: Icon(
                          result.isCorrect ? Icons.check_circle : Icons.cancel,
                          color: result.isCorrect
                              ? Colors.green
                              : Colors.redAccent,
                        ),
                        title: Text(result.prompt),
                        subtitle: Text(
                          context.l10n.resultsAnswerLabel(result.correctAnswer),
                        ),
                        trailing: Text(
                          result.userAnswer == null
                              ? context.l10n.resultsSkipped
                              : result.userAnswer.toString(),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _replay(context, replayConfig),
                      icon: const Icon(Icons.refresh),
                      label: Text(context.l10n.resultsReplay),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push(AppRoutePath.statistics),
                      icon: const Icon(Icons.bar_chart),
                      label: Text(context.l10n.resultsStatistics),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => context.push(
                    AppRoutePath.exerciseModeType,
                    extra: backConfig,
                  ),
                  child: Text(context.l10n.resultsBackHome),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _replay(BuildContext context, ExerciseConfig config) {
    switch (config.format) {
      case ExerciseFormat.multipleChoice:
        context.push(AppRoutePath.exerciseMultipleChoice, extra: config);
        break;
      case ExerciseFormat.directInput:
      case ExerciseFormat.timedChallenge:
        context.push(AppRoutePath.exerciseDirectInput, extra: config);
        break;
    }
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          Icon(icon),
          const SizedBox(width: 12),
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
