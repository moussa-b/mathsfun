import 'package:flutter/material.dart';

import '../../../core/extensions/context_localizations.dart';
import '../models/table_analytics.dart';

class TableAnalyticsCard extends StatelessWidget {
  const TableAnalyticsCard({
    super.key,
    required this.analytics,
    required this.onReset,
  });

  final TableAnalytics analytics;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final hasAnyData =
        analytics.exerciseStats.hasData || analytics.flashCardStats.hasData;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(
          context.l10n.parentDashboardTableLabel(analytics.table),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        subtitle: hasAnyData
            ? Text(
                _getSubtitle(context),
                style: Theme.of(context).textTheme.bodySmall,
              )
            : null,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Exercise Statistics
                _buildExerciseStats(context),
                const SizedBox(height: 24),
                // Flash Card Statistics
                _buildFlashCardStats(context),
                const SizedBox(height: 16),
                // Reset Button
                if (hasAnyData)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onReset,
                      icon: const Icon(Icons.refresh),
                      label: Text(context.l10n.parentDashboardResetTable),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getSubtitle(BuildContext context) {
    final parts = <String>[];
    
    if (analytics.exerciseStats.hasData) {
      parts.add(
        '${analytics.exerciseStats.totalAttempts} ${context.l10n.parentDashboardTotalAttempts.toLowerCase()}',
      );
    }
    
    if (analytics.flashCardStats.hasData) {
      parts.add(
        '${analytics.flashCardStats.gotItCount}/${analytics.flashCardStats.totalReviewed} ${context.l10n.parentDashboardCardsMastered.toLowerCase()}',
      );
    }
    
    return parts.join(' • ');
  }

  Widget _buildExerciseStats(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.assignment, size: 20),
            const SizedBox(width: 8),
            Text(
              context.l10n.parentDashboardExerciseStats,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (!analytics.exerciseStats.hasData)
          _buildEmptyState(
            context,
            context.l10n.parentDashboardNoExerciseData,
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatRow(
                context,
                context.l10n.parentDashboardTotalAttempts,
                analytics.exerciseStats.totalAttempts.toString(),
              ),
              _buildStatRow(
                context,
                context.l10n.parentDashboardTotalQuestions,
                analytics.exerciseStats.totalQuestions.toString(),
              ),
              _buildStatRow(
                context,
                context.l10n.parentDashboardSuccessRate,
                '${analytics.exerciseStats.successRate.toStringAsFixed(1)}%',
                valueColor: _getSuccessRateColor(
                  analytics.exerciseStats.successRate,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.parentDashboardProblemOperations,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              if (analytics.exerciseStats.problemOperations.isEmpty)
                Text(
                  context.l10n.parentDashboardNoProblemOperations,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                        fontStyle: FontStyle.italic,
                      ),
                )
              else
                ...analytics.exerciseStats.problemOperations.map(
                  (problem) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, size: 16, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            context.l10n.parentDashboardOperationFailed(
                              problem.expression,
                              problem.failureCount,
                              problem.totalAttempts,
                              problem.failureRate.toStringAsFixed(0),
                            ),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildFlashCardStats(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.style, size: 20),
            const SizedBox(width: 8),
            Text(
              context.l10n.parentDashboardFlashCardStats,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (!analytics.flashCardStats.hasData)
          _buildEmptyState(
            context,
            context.l10n.parentDashboardNoFlashCardData,
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatRow(
                context,
                context.l10n.parentDashboardCardsReviewed,
                analytics.flashCardStats.totalReviewed.toString(),
              ),
              _buildStatRow(
                context,
                context.l10n.parentDashboardCardsMastered,
                analytics.flashCardStats.gotItCount.toString(),
                valueColor: Colors.green,
              ),
              _buildStatRow(
                context,
                context.l10n.parentDashboardCardsToReview,
                analytics.flashCardStats.reviewAgainCount.toString(),
                valueColor: Colors.orange,
              ),
              _buildStatRow(
                context,
                context.l10n.parentDashboardMasteryRate,
                '${analytics.flashCardStats.masteryRate.toStringAsFixed(1)}%',
                valueColor: _getSuccessRateColor(
                  analytics.flashCardStats.masteryRate,
                ),
              ),
              if (analytics.flashCardStats.masteredCards.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  context.l10n.parentDashboardMasteredCards,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: analytics.flashCardStats.masteredCards
                      .map(
                        (card) => Chip(
                          label: Text(card),
                          backgroundColor: Colors.green.shade50,
                          labelStyle: const TextStyle(color: Colors.green),
                          side: BorderSide(color: Colors.green.shade200),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(),
                ),
              ],
              if (analytics.flashCardStats.reviewCards.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  context.l10n.parentDashboardReviewCards,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: analytics.flashCardStats.reviewCards
                      .map(
                        (card) => Chip(
                          label: Text(card),
                          backgroundColor: Colors.orange.shade50,
                          labelStyle: const TextStyle(color: Colors.orange),
                          side: BorderSide(color: Colors.orange.shade200),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
      ),
    );
  }

  Color _getSuccessRateColor(double rate) {
    if (rate >= 80) return Colors.green;
    if (rate >= 60) return Colors.orange;
    return Colors.red;
  }
}

