import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/context_localizations.dart';
import '../../../core/routes/app_router.dart';
import '../../../data/models/exercise_metadata.dart';
import '../../../data/services/settings_service.dart';
import '../models/exercise_config.dart';
import '../widgets/table_selector.dart';
import '../widgets/voice_exercise_tile.dart';

/// Screen to pick the exercise format: multiple choice, direct input, timed
/// challenge or voice.
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
  late DifficultyLevel _difficultyLevel;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _shuffleQuestions = widget.config.shuffleQuestions;
    // Initialize with selectedTables if available, otherwise use baseNumber
    _selectedTables = widget.config.selectedTables?.toSet() ?? 
        {widget.config.baseNumber};
    _difficultyLevel = widget.config.difficultyLevel;
  }

  void _navigateToModeSelection(BuildContext context) {
    final ExerciseConfig modeConfig = widget.config.copyWith(
      mode: StudyMode.exercise,
    );
    context.go(AppRoutePath.modeSelection, extra: modeConfig);
  }

  @override
  Widget build(BuildContext context) {
    final SettingsService settingsService = context.watch<SettingsService>();
    final int timedSeconds = settingsService.settings.timedChallengeSeconds;

    // Load saved preferences on first build
    if (!_initialized) {
      final Set<int>? savedTables = settingsService.getLastExerciseSelectedTables(
        widget.config.operation,
      );
      final DifficultyLevel? savedDifficulty = settingsService.getLastExerciseDifficultyLevel(
        widget.config.operation,
      );
      final bool? savedShuffle = settingsService.getLastExerciseShuffleQuestions(
        widget.config.operation,
      );

      if (savedTables != null || savedDifficulty != null || savedShuffle != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              if (savedTables != null && savedTables.isNotEmpty) {
                _selectedTables = savedTables;
              }
              if (savedDifficulty != null) {
                _difficultyLevel = savedDifficulty;
              }
              if (savedShuffle != null) {
                _shuffleQuestions = savedShuffle;
              }
            });
          }
        });
      }
      _initialized = true;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          _navigateToModeSelection(context);
        }
      },
      child: Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => _navigateToModeSelection(context),
        ),
        title: Text(context.l10n.exerciseModeTypeTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TableSelector(
              value: _selectedTables.first,
              onChanged: (int value) {},
              multiSelect: true,
              selectedValues: _selectedTables,
              onMultiChanged: (Set<int> values) {
                setState(() => _selectedTables = values);
                settingsService.setLastExerciseSelectedTables(
                  widget.config.operation,
                  values,
                );
              },
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
              context.l10n.exerciseDifficultyLabel,
              style: Theme
                  .of(context)
                  .textTheme
                  .titleMedium,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<DifficultyLevel>(
                  segments: <ButtonSegment<DifficultyLevel>>[
                    ButtonSegment<DifficultyLevel>(
                      value: DifficultyLevel.easy,
                      label: _DifficultyLabel(
                        label: context.l10n.exerciseDifficultyEasy,
                        stars: 1,
                      ),
                    ),
                    ButtonSegment<DifficultyLevel>(
                      value: DifficultyLevel.medium,
                      label: _DifficultyLabel(
                        label: context.l10n.exerciseDifficultyMedium,
                        stars: 2,
                      ),
                    ),
                    ButtonSegment<DifficultyLevel>(
                      value: DifficultyLevel.hard,
                      label: _DifficultyLabel(
                        label: context.l10n.exerciseDifficultyHard,
                        stars: 3,
                      ),
                    ),
                  ],
                  selected: <DifficultyLevel>{_difficultyLevel},
                  onSelectionChanged: (Set<DifficultyLevel> newSelection) {
                    final DifficultyLevel newLevel = newSelection.first;
                    setState(() {
                      _difficultyLevel = newLevel;
                    });
                    settingsService.setLastExerciseDifficultyLevel(
                      widget.config.operation,
                      newLevel,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _difficultyDescription(context, _difficultyLevel),
              style: Theme
                  .of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                color: Theme
                    .of(context)
                    .colorScheme
                    .primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.questionOrderLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<bool>(
                  segments: <ButtonSegment<bool>>[
                  ButtonSegment<bool>(
                    value: false,
                    label: _SegmentLabel(text: context.l10n.questionOrderOrdered),
                    icon: const Icon(Icons.format_list_numbered, size: 22),
                  ),
                  ButtonSegment<bool>(
                    value: true,
                    label:
                        _SegmentLabel(text: context.l10n.questionOrderShuffled),
                    icon: const Icon(Icons.shuffle, size: 22),
                  ),
                ],
                  selected: <bool>{_shuffleQuestions},
                  onSelectionChanged: (Set<bool> newSelection) {
                    final bool newShuffle = newSelection.first;
                    setState(() {
                      _shuffleQuestions = newShuffle;
                    });
                    settingsService.setLastExerciseShuffleQuestions(
                      widget.config.operation,
                      newShuffle,
                    );
                  },
                ),
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
                  difficultyLevel: _difficultyLevel,
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
                  difficultyLevel: _difficultyLevel,
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
                  difficultyLevel: _difficultyLevel,
                );
                context.push(AppRoutePath.exerciseDirectInput, extra: next);
              },
            ),
            const SizedBox(height: 16),
            VoiceExerciseTile(
              buildConfig: () => widget.config.copyWith(
                format: ExerciseFormat.voice,
                questionCount: 12,
                shuffleQuestions: _shuffleQuestions,
                selectedTables: _selectedTables.toList(),
                difficultyLevel: _difficultyLevel,
              ),
            ),
          ],
        ),
      ),
    ));
  }

  String _difficultyDescription(BuildContext context,
      DifficultyLevel level,) {
    final int? seconds = level.timeLimitSeconds;
    if (seconds == null) {
      return context.l10n.exerciseDifficultyEasyDescription;
    }
    if (level == DifficultyLevel.medium) {
      return context.l10n.exerciseDifficultyMediumDescription(seconds);
    }
    return context.l10n.exerciseDifficultyHardDescription(seconds);
  }
}

class _SegmentLabel extends StatelessWidget {
  const _SegmentLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    String firstLine = text;
    String? secondLine;
    final int parenIndex = text.indexOf('(');
    if (parenIndex != -1) {
      firstLine = text.substring(0, parenIndex).trim();
      secondLine = text.substring(parenIndex).trim();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          firstLine,
          textAlign: TextAlign.center,
          style: Theme
              .of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (secondLine != null)
          Text(
            secondLine,
            textAlign: TextAlign.center,
            style: Theme
                .of(context)
                .textTheme
                .bodySmall,
          ),
      ],
    );
  }
}

class _DifficultyLabel extends StatelessWidget {
  const _DifficultyLabel({
    required this.label,
    required this.stars,
  });

  final String label;
  final int stars;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme
                .of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(
              stars,
              (int index) => const Icon(
                Icons.star,
                color: Colors.amber,
                size: 18,
              ),
            ),
          ),
        ],
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
