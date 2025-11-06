import 'dart:math';

import '../../../data/models/exercise_metadata.dart';
import '../../../data/models/exercise_session.dart';
import '../../../data/models/reward.dart';

class ProfileStatistics {
  const ProfileStatistics({
    required this.totalSessions,
    required this.totalQuestions,
    required this.totalCorrect,
    required this.averageAccuracy,
    required this.bestAccuracy,
    required this.totalPracticeMillis,
    required this.recentSessions,
    required this.rewards,
  });

  final int totalSessions;
  final int totalQuestions;
  final int totalCorrect;
  final double averageAccuracy;
  final double bestAccuracy;
  final int totalPracticeMillis;
  final List<ExerciseSession> recentSessions;
  final List<Reward> rewards;

  int get totalStars => rewards
      .where((Reward reward) => reward.type == RewardType.star)
      .fold<int>(0, (int sum, Reward reward) => sum + reward.value);

  int get totalBadges =>
      rewards.where((Reward reward) => reward.type == RewardType.badge).length;

  Duration get totalPracticeTime => Duration(milliseconds: totalPracticeMillis);
}

ProfileStatistics buildProfileStatistics(
  List<ExerciseSession> sessions,
  List<Reward> rewards,
) {
  final List<ExerciseSession> orderedSessions =
      List<ExerciseSession>.from(sessions)..sort(
        (ExerciseSession a, ExerciseSession b) =>
            b.startedAt.compareTo(a.startedAt),
      );
  final List<Reward> orderedRewards = List<Reward>.from(rewards)
    ..sort((Reward a, Reward b) => b.awardedAt.compareTo(a.awardedAt));

  final int totalSessions = orderedSessions.length;
  final int totalQuestions = orderedSessions.fold(
    0,
    (int sum, ExerciseSession session) => sum + session.totalQuestions,
  );
  final int totalCorrect = orderedSessions.fold(
    0,
    (int sum, ExerciseSession session) => sum + session.correctCount,
  );
  final double averageAccuracy = totalSessions == 0
      ? 0
      : orderedSessions.fold<double>(
              0,
              (double sum, ExerciseSession session) => sum + session.accuracy,
            ) /
            totalSessions;
  final double bestAccuracy = orderedSessions.isEmpty
      ? 0
      : orderedSessions
            .map((ExerciseSession session) => session.accuracy)
            .reduce(max);
  final int totalPracticeMillis = orderedSessions.fold(
    0,
    (int sum, ExerciseSession session) => sum + session.durationMillis,
  );

  return ProfileStatistics(
    totalSessions: totalSessions,
    totalQuestions: totalQuestions,
    totalCorrect: totalCorrect,
    averageAccuracy: averageAccuracy,
    bestAccuracy: bestAccuracy,
    totalPracticeMillis: totalPracticeMillis,
    recentSessions: orderedSessions.take(10).toList(),
    rewards: orderedRewards,
  );
}
