import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/context_localizations.dart';
import '../../../core/routes/app_router.dart';
import '../../../data/models/exercise_metadata.dart';
import '../../../data/services/settings_service.dart';
import '../../exercise/models/exercise_config.dart';
import '../../exercise/widgets/table_selector.dart';

/// Screen to pick between list view and flash card revision modes.
class RevisionModeTypeSelectionScreen extends StatefulWidget {
  const RevisionModeTypeSelectionScreen({super.key, required this.config});

  final ExerciseConfig config;

  @override
  State<RevisionModeTypeSelectionScreen> createState() =>
      _RevisionModeTypeSelectionScreenState();
}

class _RevisionModeTypeSelectionScreenState
    extends State<RevisionModeTypeSelectionScreen> {
  late int _table;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _table = widget.config.baseNumber;
  }

  void _navigateToModeSelection(BuildContext context) {
    final ExerciseConfig modeConfig = widget.config.copyWith(
      mode: StudyMode.revision,
    );
    context.go(AppRoutePath.modeSelection, extra: modeConfig);
  }

  @override
  Widget build(BuildContext context) {
    final bool isMultiplication =
        widget.config.operation == OperationKind.multiplication;
    final SettingsService settingsService = context.watch<SettingsService>();

    // Load saved preference on first build
    if (!_initialized) {
      final int? savedTable = settingsService.getLastRevisionTable(
        widget.config.operation,
      );
      if (savedTable != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _table = savedTable;
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
        title: Text(context.l10n.revisionModeTypeTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TableSelector(
              value: _table,
              onChanged: (int value) {
                setState(() => _table = value);
                settingsService.setLastRevisionTable(
                  widget.config.operation,
                  value,
                );
              },
              label: context.l10n.tableSelectorLabel,
              max: isMultiplication ? 12 : 10,
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.revisionModePrompt,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _RevisionTypeTile(
              icon: Icons.format_list_bulleted,
              title: context.l10n.revisionListViewTitle,
              description: context.l10n.revisionListViewDescription,
              color: Colors.teal,
              onTap: () {
                final ExerciseConfig config = widget.config.copyWith(
                  baseNumber: _table,
                  revisionFormat: RevisionFormat.listView,
                );
                context.push(AppRoutePath.revision, extra: config);
              },
            ),
            const SizedBox(height: 16),
            _RevisionTypeTile(
              icon: Icons.style,
              title: context.l10n.revisionFlashCardTitle,
              description: context.l10n.revisionFlashCardDescription,
              color: Colors.deepPurple,
              onTap: () {
                final ExerciseConfig config = widget.config.copyWith(
                  baseNumber: _table,
                  revisionFormat: RevisionFormat.flashCard,
                );
                context.push(AppRoutePath.revisionFlashCard, extra: config);
              },
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _RevisionTypeTile extends StatelessWidget {
  const _RevisionTypeTile({
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

