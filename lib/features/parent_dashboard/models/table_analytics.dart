import '../../../data/models/exercise_metadata.dart';

class TableAnalytics {
  const TableAnalytics({
    required this.table,
    required this.operation,
    required this.exerciseStats,
    required this.flashCardStats,
  });

  final int table;
  final OperationKind operation;
  final ExerciseStats exerciseStats;
  final FlashCardStats flashCardStats;
}

class ExerciseStats {
  const ExerciseStats({
    required this.totalAttempts,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.problemOperations,
  });

  final int totalAttempts;
  final int totalQuestions;
  final int correctAnswers;
  final List<ProblemOperation> problemOperations;

  double get successRate =>
      totalQuestions == 0 ? 0 : (correctAnswers / totalQuestions * 100);

  bool get hasData => totalAttempts > 0;
}

class ProblemOperation {
  const ProblemOperation({
    required this.expression,
    required this.totalAttempts,
    required this.failureCount,
  });

  final String expression;
  final int totalAttempts;
  final int failureCount;

  double get failureRate =>
      totalAttempts == 0 ? 0 : (failureCount / totalAttempts * 100);
}

class FlashCardStats {
  const FlashCardStats({
    required this.totalReviewed,
    required this.gotItCount,
    required this.reviewAgainCount,
    required this.masteredCards,
    required this.reviewCards,
  });

  final int totalReviewed;
  final int gotItCount;
  final int reviewAgainCount;
  final List<String> masteredCards;
  final List<String> reviewCards;

  bool get hasData => totalReviewed > 0;

  double get masteryRate =>
      totalReviewed == 0 ? 0 : (gotItCount / totalReviewed * 100);
}

