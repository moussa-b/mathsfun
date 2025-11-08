import 'package:flutter/material.dart';

import '../../../core/extensions/context_localizations.dart';

class QuestionTimerChip extends StatelessWidget {
  const QuestionTimerChip({super.key, required this.remainingSeconds});

  final int remainingSeconds;

  @override
  Widget build(BuildContext context) {
    final bool isCritical = remainingSeconds <= 3;
    final Color baseColor = isCritical
        ? Colors.redAccent
        : Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: baseColor, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hourglass_bottom,
            color: baseColor,
          ),
          const SizedBox(width: 8),
          Text(
            context.l10n.exerciseQuestionTimer(remainingSeconds),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: baseColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
