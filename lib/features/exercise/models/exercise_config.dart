import '../../../data/models/exercise_metadata.dart';

class ExerciseConfig {
  const ExerciseConfig({
    required this.operation,
    required this.mode,
    required this.format,
    this.baseNumber = 2,
    this.questionCount = 10,
    this.timedSeconds,
    this.shuffleQuestions = false,
  }) : assert(baseNumber >= 0 && baseNumber <= 12);

  final OperationKind operation;
  final StudyMode mode;
  final ExerciseFormat format;
  final int baseNumber;
  final int questionCount;
  final int? timedSeconds;
  final bool shuffleQuestions;

  bool get isTimed =>
      format == ExerciseFormat.timedChallenge || timedSeconds != null;

  ExerciseConfig copyWith({
    OperationKind? operation,
    StudyMode? mode,
    ExerciseFormat? format,
    int? baseNumber,
    int? questionCount,
    int? timedSeconds,
    bool? shuffleQuestions,
  }) {
    return ExerciseConfig(
      operation: operation ?? this.operation,
      mode: mode ?? this.mode,
      format: format ?? this.format,
      baseNumber: baseNumber ?? this.baseNumber,
      questionCount: questionCount ?? this.questionCount,
      timedSeconds: timedSeconds ?? this.timedSeconds,
      shuffleQuestions: shuffleQuestions ?? this.shuffleQuestions,
    );
  }
}
