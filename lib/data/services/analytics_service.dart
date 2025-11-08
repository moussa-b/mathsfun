import '../models/exercise_metadata.dart';
import '../models/flash_card_result.dart';
import '../../features/parent_dashboard/models/table_analytics.dart';
import 'flash_card_service.dart';
import 'session_service.dart';

class AnalyticsService {
  AnalyticsService({
    required SessionService sessionService,
    required FlashCardService flashCardService,
  })  : _sessionService = sessionService,
        _flashCardService = flashCardService;

  final SessionService _sessionService;
  final FlashCardService _flashCardService;

  /// Get analytics for a specific table
  TableAnalytics getTableAnalytics({
    required String profileId,
    required int table,
    required OperationKind operation,
  }) {
    final exerciseStats = _getExerciseStats(
      profileId: profileId,
      table: table,
      operation: operation,
    );
    final flashCardStats = _getFlashCardStats(
      profileId: profileId,
      table: table,
      operation: operation,
    );

    return TableAnalytics(
      table: table,
      operation: operation,
      exerciseStats: exerciseStats,
      flashCardStats: flashCardStats,
    );
  }

  /// Get analytics for all tables
  List<TableAnalytics> getAllTablesAnalytics({
    required String profileId,
    required OperationKind operation,
  }) {
    final int maxTable = operation == OperationKind.multiplication ? 12 : 10;
    final List<TableAnalytics> analytics = [];

    for (int table = 2; table <= maxTable; table++) {
      analytics.add(
        getTableAnalytics(
          profileId: profileId,
          table: table,
          operation: operation,
        ),
      );
    }

    return analytics;
  }

  ExerciseStats _getExerciseStats({
    required String profileId,
    required int table,
    required OperationKind operation,
  }) {
    // Get all sessions for this profile, table, and operation
    final sessions = _sessionService
        .sessionsForProfile(profileId)
        .where((session) =>
            session.operation == operation &&
            session.targetTable == table &&
            session.mode == StudyMode.exercise)
        .toList();

    if (sessions.isEmpty) {
      return const ExerciseStats(
        totalAttempts: 0,
        totalQuestions: 0,
        correctAnswers: 0,
        problemOperations: [],
      );
    }

    // Aggregate data
    int totalQuestions = 0;
    int correctAnswers = 0;
    final Map<String, _OperationAttempt> operationAttempts = {};

    for (final session in sessions) {
      for (final question in session.questions) {
        totalQuestions++;
        if (question.isCorrect) {
          correctAnswers++;
        }

        // Track per-operation attempts
        final prompt = question.prompt;
        operationAttempts.putIfAbsent(
          prompt,
          () => _OperationAttempt(expression: prompt),
        );
        operationAttempts[prompt]!.totalAttempts++;
        if (!question.isCorrect) {
          operationAttempts[prompt]!.failureCount++;
        }
      }
    }

    // Identify problem operations (failure rate > 40%)
    final problemOperations = operationAttempts.values
        .where((attempt) => attempt.failureRate > 40 && attempt.totalAttempts >= 2)
        .map((attempt) => ProblemOperation(
              expression: attempt.expression,
              totalAttempts: attempt.totalAttempts,
              failureCount: attempt.failureCount,
            ))
        .toList()
      ..sort((a, b) => b.failureRate.compareTo(a.failureRate));

    return ExerciseStats(
      totalAttempts: sessions.length,
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      problemOperations: problemOperations,
    );
  }

  FlashCardStats _getFlashCardStats({
    required String profileId,
    required int table,
    required OperationKind operation,
  }) {
    final results = _flashCardService.resultsForTable(
      profileId: profileId,
      table: table,
      operation: operation,
    );

    if (results.isEmpty) {
      return const FlashCardStats(
        totalReviewed: 0,
        gotItCount: 0,
        reviewAgainCount: 0,
        masteredCards: [],
        reviewCards: [],
      );
    }

    // Get the most recent status for each card (table × multiplier)
    final Map<int, FlashCardStatus> latestStatus = {};
    
    for (final result in results) {
      final existing = latestStatus[result.multiplier];
      if (existing == null) {
        latestStatus[result.multiplier] = result.status;
      } else {
        // Find the most recent result for this multiplier
        final laterResult = results
            .where((r) => r.multiplier == result.multiplier)
            .reduce((a, b) => a.timestamp.isAfter(b.timestamp) ? a : b);
        latestStatus[result.multiplier] = laterResult.status;
      }
    }

    int gotItCount = 0;
    int reviewAgainCount = 0;
    List<String> masteredCards = [];
    List<String> reviewCards = [];

    latestStatus.forEach((multiplier, status) {
      final symbol = operation == OperationKind.multiplication ? '×' : '+';
      final card = '$multiplier $symbol $table';
      
      if (status == FlashCardStatus.gotIt) {
        gotItCount++;
        masteredCards.add(card);
      } else {
        reviewAgainCount++;
        reviewCards.add(card);
      }
    });

    return FlashCardStats(
      totalReviewed: latestStatus.length,
      gotItCount: gotItCount,
      reviewAgainCount: reviewAgainCount,
      masteredCards: masteredCards,
      reviewCards: reviewCards,
    );
  }

  /// Reset all progress for a specific table
  Future<void> resetTableProgress({
    required String profileId,
    required int table,
    required OperationKind operation,
  }) async {
    // Delete exercise sessions for this table
    final sessions = _sessionService
        .sessionsForProfile(profileId)
        .where((session) =>
            session.operation == operation && session.targetTable == table)
        .toList();

    for (final session in sessions) {
      await _sessionService.deleteSession(session.id);
    }

    // Delete flash card results for this table
    await _flashCardService.deleteResultsForTable(
      profileId: profileId,
      table: table,
      operation: operation,
    );
  }

  /// Reset all progress for a profile
  Future<void> resetAllProgress(String profileId) async {
    await _sessionService.deleteSessionsForProfile(profileId);
    await _flashCardService.deleteResultsForProfile(profileId);
  }
}

class _OperationAttempt {
  _OperationAttempt({required this.expression});

  final String expression;
  int totalAttempts = 0;
  int failureCount = 0;

  double get failureRate =>
      totalAttempts == 0 ? 0 : (failureCount / totalAttempts * 100);
}

