import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_localizations.dart';
import '../../../core/routes/app_router.dart';
import '../../../data/models/exercise_metadata.dart';
import '../../exercise/models/exercise_config.dart';
import '../../exercise/widgets/table_selector.dart';

/// Screen for selecting between revision and exercise modes.
class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({super.key, required this.initialConfig});

  final ExerciseConfig initialConfig;

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  late int _selectedTable;

  @override
  void initState() {
    super.initState();
    _selectedTable = widget.initialConfig.baseNumber;
  }

  @override
  Widget build(BuildContext context) {
    final ExerciseConfig baseConfig = widget.initialConfig;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.modeSelectionTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                baseConfig.operation == OperationKind.multiplication
                    ? context.l10n.modeSelectionHeadingMultiplication
                    : context.l10n.modeSelectionHeadingAddition,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.modeSelectionSubtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TableSelector(
                value: _selectedTable,
                onChanged: (int value) =>
                    setState(() => _selectedTable = value),
                label: context.l10n.tableSelectorLabel,
                max: baseConfig.operation == OperationKind.multiplication ? 12 : 10,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Column(
                  children: <Widget>[
                    _ModeCard(
                      title: context.l10n.modeRevisionCardTitle,
                      description: context.l10n.modeRevisionCardDescription,
                      icon: Icons.menu_book,
                      color: Colors.teal,
                      onTap: () {
                        final ExerciseConfig config = baseConfig.copyWith(
                          mode: StudyMode.revision,
                          baseNumber: _selectedTable,
                        );
                        context.push(AppRoutePath.revision, extra: config);
                      },
                    ),
                    const SizedBox(height: 20),
                    _ModeCard(
                      title: context.l10n.modeExerciseCardTitle,
                      description: context.l10n.modeExerciseCardDescription,
                      icon: Icons.gamepad,
                      color: Colors.orange,
                      onTap: () {
                        final ExerciseConfig config = baseConfig.copyWith(
                          mode: StudyMode.exercise,
                          baseNumber: _selectedTable,
                        );
                        context.push(
                          AppRoutePath.exerciseModeType,
                          extra: config,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
        ),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundColor: color,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(description),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }
}
