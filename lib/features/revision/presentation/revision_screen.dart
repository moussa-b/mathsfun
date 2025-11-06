import 'package:flutter/material.dart';

import '../../../core/extensions/context_localizations.dart';
import '../../../data/models/exercise_metadata.dart';
import '../../exercise/models/exercise_config.dart';
import '../../exercise/widgets/table_selector.dart';

/// Displays a multiplication or addition table for revision purposes.
class RevisionScreen extends StatefulWidget {
  const RevisionScreen({super.key, required this.config});

  final ExerciseConfig config;

  @override
  State<RevisionScreen> createState() => _RevisionScreenState();
}

class _RevisionScreenState extends State<RevisionScreen> {
  late int _table;

  @override
  void initState() {
    super.initState();
    _table = widget.config.baseNumber;
  }

  @override
  Widget build(BuildContext context) {
    final bool isMultiplication =
        widget.config.operation == OperationKind.multiplication;
    return Scaffold(
      appBar: AppBar(
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
                    ? context.l10n.revisionHeadingMultiplication(_table)
                    : context.l10n.revisionHeadingAddition(_table),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              TableSelector(
                value: _table,
                onChanged: (int value) => setState(() => _table = value),
                label: context.l10n.tableSelectorLabel,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Card(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: 12,
                    itemBuilder: (BuildContext context, int index) {
                      final int multiplier = index + 1;
                      final int result = isMultiplication
                          ? multiplier * _table
                          : multiplier + _table;
                      final String expression = isMultiplication
                          ? '$multiplier × $_table'
                          : '$multiplier + $_table';
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
    );
  }
}
