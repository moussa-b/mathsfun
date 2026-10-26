import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/context_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/exercise_metadata.dart';
import '../../../data/services/profile_service.dart';
import '../../../data/services/reward_service.dart';
import '../../../data/services/session_service.dart';
import '../../statistics/models/profile_statistics.dart';

/// Shows cumulative performance statistics for the current profile.
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileService = context.watch<ProfileService>();
    final profile = profileService.activeProfile;
    if (profile == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.statisticsPageTitle)),
        body: Center(child: Text(context.l10n.profileSelectorEmptySubtitle)),
      );
    }

    final sessionService = context.watch<SessionService>();
    final rewardService = context.watch<RewardService>();
    final stats = buildProfileStatistics(
      sessionService.sessionsForProfile(profile.id),
      rewardService.rewardsForProfile(profile.id).toList(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.statisticsTitle(profile.nickname)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: stats.totalSessions == 0
              ? Center(child: Text(context.l10n.statisticsEmpty))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        _StatisticCard(
                          title: context.l10n.statisticsSessions,
                          value: stats.totalSessions.toString(),
                          icon: Icons.play_circle_fill,
                          color: Colors.blueAccent,
                        ),
                        const SizedBox(width: 16),
                        _StatisticCard(
                          title: context.l10n.statisticsAverageAccuracy,
                          value: '${stats.averageAccuracy.toStringAsFixed(0)}%',
                          icon: Icons.percent,
                          color: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: <Widget>[
                        _StatisticCard(
                          title: context.l10n.statisticsStars,
                          value: stats.totalStars.toString(),
                          icon: Icons.star,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 16),
                        _StatisticCard(
                          title: context.l10n.statisticsPracticeTime,
                          value: formatDuration(stats.totalPracticeTime),
                          icon: Icons.timer,
                          color: Colors.purple,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      context.l10n.statisticsRecentSessions,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: stats.recentSessions.length,
                        itemBuilder: (BuildContext context, int index) {
                          final session = stats.recentSessions[index];
                          final String operationLabel =
                              session.operation == OperationKind.multiplication
                              ? context.l10n.statisticsOperationMultiplication
                              : context.l10n.statisticsOperationAddition;
                          final String formatLabel;
                          switch (session.format) {
                            case ExerciseFormat.multipleChoice:
                              formatLabel =
                                  context.l10n.statisticsFormatMultipleChoice;
                              break;
                            case ExerciseFormat.directInput:
                              formatLabel =
                                  context.l10n.statisticsFormatDirectInput;
                              break;
                            case ExerciseFormat.timedChallenge:
                              formatLabel =
                                  context.l10n.statisticsFormatTimedChallenge;
                              break;
                            case ExerciseFormat.voice:
                              formatLabel = context.l10n.statisticsFormatVoice;
                              break;
                          }
                          final int roundedAccuracy = session.accuracy.round();
                          return Card(
                            child: ListTile(
                              leading: Icon(
                                session.operation ==
                                        OperationKind.multiplication
                                    ? Icons.close_fullscreen
                                    : Icons.add_circle_outline,
                              ),
                              title: Text(
                                context.l10n.statisticsSessionSummary(
                                  operationLabel,
                                  formatLabel,
                                ),
                              ),
                              subtitle: Text(
                                '${formatDateTime(session.startedAt)}  •  ${context.l10n.statisticsSessionAccuracy(roundedAccuracy)}',
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    context.l10n.statisticsSessionScore(
                                      session.correctCount,
                                      session.totalQuestions,
                                    ),
                                  ),
                                  Text(
                                    formatDuration(
                                      Duration(
                                        milliseconds: session.durationMillis,
                                      ),
                                    ),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _StatisticCard extends StatelessWidget {
  const _StatisticCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, color: color),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
