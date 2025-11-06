import 'package:flutter_test/flutter_test.dart';

import 'package:mathsfun/data/models/exercise_metadata.dart';
import 'package:mathsfun/data/models/exercise_session.dart';
import 'package:mathsfun/data/models/reward.dart';
import 'package:mathsfun/features/statistics/models/profile_statistics.dart';

void main() {
  final ExerciseSession sessionA = ExerciseSession(
    id: 'a',
    profileId: 'p1',
    operation: OperationKind.multiplication,
    mode: StudyMode.exercise,
    format: ExerciseFormat.multipleChoice,
    startedAt: DateTime(2024, 5, 12, 10),
    durationMillis: 60000,
    questions: <QuestionResult>[
      QuestionResult(
        prompt: '3 × 4',
        correctAnswer: 12,
        userAnswer: 12,
        isCorrect: true,
        responseMillis: 4000,
      ),
      QuestionResult(
        prompt: '3 × 5',
        correctAnswer: 15,
        userAnswer: 12,
        isCorrect: false,
        responseMillis: 5000,
      ),
    ],
    targetTable: 3,
  );

  final ExerciseSession sessionB = ExerciseSession(
    id: 'b',
    profileId: 'p1',
    operation: OperationKind.addition,
    mode: StudyMode.exercise,
    format: ExerciseFormat.directInput,
    startedAt: DateTime(2024, 5, 13, 9),
    durationMillis: 45000,
    questions: <QuestionResult>[
      QuestionResult(
        prompt: '4 + 5',
        correctAnswer: 9,
        userAnswer: 9,
        isCorrect: true,
        responseMillis: 3000,
      ),
      QuestionResult(
        prompt: '4 + 6',
        correctAnswer: 10,
        userAnswer: 10,
        isCorrect: true,
        responseMillis: 3500,
      ),
    ],
    targetTable: 4,
  );

  final Reward reward = Reward(
    id: 'r1',
    profileId: 'p1',
    type: RewardType.star,
    title: 'Star',
    description: 'Great accuracy',
    awardedAt: DateTime(2024, 5, 13, 9, 5),
    value: 3,
  );

  test('buildProfileStatistics aggregates sessions and rewards', () {
    final ProfileStatistics stats = buildProfileStatistics(
      <ExerciseSession>[sessionA, sessionB],
      <Reward>[reward],
    );

    expect(stats.totalSessions, 2);
    expect(stats.totalQuestions, 4);
    expect(stats.totalCorrect, 3);
    expect(stats.totalStars, 3);
    expect(stats.totalPracticeTime.inMinutes, 1);
    expect(stats.recentSessions.first.id, 'b');
  });
}
