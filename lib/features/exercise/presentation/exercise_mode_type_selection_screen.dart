import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/context_localizations.dart';
import '../../../core/routes/app_router.dart';
import '../../../data/models/exercise_metadata.dart';
import '../../../data/services/settings_service.dart';
import '../models/exercise_config.dart';
import '../widgets/table_selector.dart';

/// Screen to pick between multiple choice and direct input exercise types.
class ExerciseModeTypeSelectionScreen extends StatefulWidget {
  const ExerciseModeTypeSelectionScreen({super.key, required this.config});

  final ExerciseConfig config;

  @override
  State<ExerciseModeTypeSelectionScreen> createState() =>
      _ExerciseModeTypeSelectionScreenState();
}

class _ExerciseModeTypeSelectionScreenState
    extends State<ExerciseModeTypeSelectionScreen> {
  late bool _shuffleQuestions;
  late Set<int> _selectedTables;

  @override
  void initState() {
    super.initState();
    _shuffleQuestions = widget.config.shuffleQuestions;
    // Initialize with selectedTables if available, otherwise use baseNumber
    _selectedTables = widget.config.selectedTables?.toSet() ?? 
        {widget.config.baseNumber};
  }

  @override
  Widget build(BuildContext context) {
    final SettingsService settingsService = context.watch<SettingsService>();
    final int timedSeconds = settingsService.settings.timedChallengeSeconds;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.exerciseModeTypeTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              context.l10n.questionOrderLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              segments: <ButtonSegment<bool>>[
                ButtonSegment<bool>(
                  value: false,
                  label: Text(context.l10n.questionOrderOrdered),
                  icon: const Icon(Icons.format_list_numbered, size: 18),
                ),
                ButtonSegment<bool>(
                  value: true,
                  label: Text(context.l10n.questionOrderShuffled),
                  icon: const Icon(Icons.shuffle, size: 18),
                ),
              ],
              selected: <bool>{_shuffleQuestions},
              onSelectionChanged: (Set<bool> newSelection) {
                setState(() {
                  _shuffleQuestions = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 24),
            TableSelector(
              value: _selectedTables.first,
              onChanged: (int value) {},
              multiSelect: true,
              selectedValues: _selectedTables,
              onMultiChanged: (Set<int> values) =>
                  setState(() => _selectedTables = values),
              label: context.l10n.tableSelectorLabel,
              max: widget.config.operation == OperationKind.multiplication ? 12 : 10,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.tableSelectorSelectedCount(_selectedTables.length),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
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
                final ExerciseConfig next = widget.config.copyWith(
                  format: ExerciseFormat.multipleChoice,
                  questionCount: 10,
                  shuffleQuestions: _shuffleQuestions,
                  selectedTables: _selectedTables.toList(),
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
                final ExerciseConfig next = widget.config.copyWith(
                  format: ExerciseFormat.directInput,
                  questionCount: 12,
                  shuffleQuestions: _shuffleQuestions,
                  selectedTables: _selectedTables.toList(),
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
                final ExerciseConfig next = widget.config.copyWith(
                  format: ExerciseFormat.timedChallenge,
                  questionCount: 12,
                  timedSeconds: timedSeconds,
                  shuffleQuestions: _shuffleQuestions,
                  selectedTables: _selectedTables.toList(),
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
