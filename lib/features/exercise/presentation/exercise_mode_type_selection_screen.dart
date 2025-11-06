import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/context_localizations.dart';
import '../../../core/routes/app_router.dart';
import '../../../data/models/exercise_metadata.dart';
import '../../../data/services/settings_service.dart';
import '../models/exercise_config.dart';

/// Screen to pick between multiple choice and direct input exercise types.
class ExerciseModeTypeSelectionScreen extends StatelessWidget {
  const ExerciseModeTypeSelectionScreen({super.key, required this.config});

  final ExerciseConfig config;

  @override
  Widget build(BuildContext context) {
    final SettingsService settingsService = context.watch<SettingsService>();
    final int timedSeconds = settingsService.settings.timedChallengeSeconds;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.exerciseModeTypeTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              context.l10n.exerciseModePrompt,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _ExerciseTypeTile(
              icon: Icons.check_circle_outline,
              title: context.l10n.exerciseMultipleChoiceTitle,
              description: context.l10n.exerciseMultipleChoiceDescription,
              color: Colors.purple,
              onTap: () {
                final ExerciseConfig next = config.copyWith(
                  format: ExerciseFormat.multipleChoice,
                  questionCount: 10,
                );
                context.push(AppRoutePath.exerciseMultipleChoice, extra: next);
              },
            ),
            const SizedBox(height: 16),
            _ExerciseTypeTile(
              icon: Icons.edit,
              title: context.l10n.exerciseDirectInputTitle,
              description: context.l10n.exerciseDirectInputDescription,
              color: Colors.green,
              onTap: () {
                final ExerciseConfig next = config.copyWith(
                  format: ExerciseFormat.directInput,
                  questionCount: 10,
                );
                context.push(AppRoutePath.exerciseDirectInput, extra: next);
              },
            ),
            const SizedBox(height: 16),
            _ExerciseTypeTile(
              icon: Icons.timer,
              title: context.l10n.exerciseTimedChallengeTitle,
              description: context.l10n.exerciseTimedChallengeDescription(
                timedSeconds,
              ),
              color: Colors.red,
              onTap: () {
                final ExerciseConfig next = config.copyWith(
                  format: ExerciseFormat.timedChallenge,
                  questionCount: 20,
                  timedSeconds: timedSeconds,
                );
                context.push(AppRoutePath.exerciseDirectInput, extra: next);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseTypeTile extends StatelessWidget {
  const _ExerciseTypeTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.2),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(description),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
