import 'package:hive/hive.dart';

import 'exercise_metadata.dart';

part 'exercise_session.g.dart';

@HiveType(typeId: 6)
class QuestionResult {
  QuestionResult({
    required this.prompt,
    required this.correctAnswer,
    required this.userAnswer,
    required this.isCorrect,
    required this.responseMillis,
  });

  @HiveField(0)
  String prompt;

  @HiveField(1)
  int correctAnswer;

  @HiveField(2)
  int? userAnswer;

  @HiveField(3)
  bool isCorrect;

  @HiveField(4)
  int responseMillis;
}

@HiveType(typeId: 5)
class ExerciseSession extends HiveObject {
  ExerciseSession({
    required this.id,
    required this.profileId,
    required this.operation,
    required this.mode,
    required this.format,
    required this.startedAt,
    required this.durationMillis,
    required this.questions,
    this.targetTable,
    this.timedSeconds,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String profileId;

  @HiveField(2)
  OperationKind operation;

  @HiveField(3)
  StudyMode mode;

  @HiveField(4)
  ExerciseFormat format;

  @HiveField(5)
  DateTime startedAt;

  @HiveField(6)
  int durationMillis;

  @HiveField(7)
  List<QuestionResult> questions;

  /// Represents the table number when applicable (e.g., "3" for ×3 table).
  @HiveField(8)
  int? targetTable;

  /// Total seconds allowed for timed challenge sessions.
  @HiveField(9)
  int? timedSeconds;

  int get totalQuestions => questions.length;

  int get correctCount =>
      questions.where((QuestionResult q) => q.isCorrect).length;

  int get incorrectCount => totalQuestions - correctCount;

  double get accuracy => totalQuestions == 0
      ? 0
      : (correctCount / totalQuestions * 100).clamp(0, 100);
}
