import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_localizations.dart';
import '../../../core/routes/app_router.dart';
import '../../../data/models/exercise_metadata.dart';
import '../../exercise/models/exercise_config.dart';

/// Displays a multiplication or addition table for revision purposes.
class RevisionScreen extends StatefulWidget {
  const RevisionScreen({super.key, required this.config});

  final ExerciseConfig config;

  @override
  State<RevisionScreen> createState() => _RevisionScreenState();
}

class _RevisionScreenState extends State<RevisionScreen> {
  void _navigateToRevisionModeSelection(BuildContext context) {
    context.go(AppRoutePath.revisionModeType, extra: widget.config);
  }

  @override
  Widget build(BuildContext context) {
    final bool isMultiplication =
        widget.config.operation == OperationKind.multiplication;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          _navigateToRevisionModeSelection(context);
        }
      },
      child: Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => _navigateToRevisionModeSelection(context),
        ),
        title: Text(
          isMultiplication
              ? context.l10n.revisionTitleMultiplication
              : context.l10n.revisionTitleAddition,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                isMultiplication
                    ? context.l10n.revisionHeadingMultiplication(widget.config.baseNumber)
                    : context.l10n.revisionHeadingAddition(widget.config.baseNumber),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Card(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: 12,
                    itemBuilder: (BuildContext context, int index) {
                      final int multiplier = index + 1;
                      final int table = widget.config.baseNumber;
                      final int result = isMultiplication
                          ? multiplier * table
                          : multiplier + table;
                      final String expression = isMultiplication
                          ? '$multiplier × $table'
                          : '$multiplier + $table';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                expression,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            Text(
                              '= $result',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
