import '../../../data/models/exercise_metadata.dart';

class ExerciseConfig {
  const ExerciseConfig({
    required this.operation,
    required this.mode,
    required this.format,
    this.baseNumber = 2,
    this.selectedTables,
    this.questionCount = 10,
    this.timedSeconds,
    this.shuffleQuestions = false,
    this.revisionFormat = RevisionFormat.listView,
    this.difficultyLevel = DifficultyLevel.easy,
  }) : assert(baseNumber >= 0 && baseNumber <= 12);

  final OperationKind operation;
  final StudyMode mode;
  final ExerciseFormat format;
  final int baseNumber;
  final List<int>? selectedTables;
  final int questionCount;
  final int? timedSeconds;
  final bool shuffleQuestions;
  final RevisionFormat revisionFormat;
  final DifficultyLevel difficultyLevel;
  
  /// Returns the list of tables to practice (uses selectedTables if available, otherwise baseNumber)
  List<int> get tables => selectedTables ?? [baseNumber];

  bool get isTimed =>
      format == ExerciseFormat.timedChallenge || timedSeconds != null;

  ExerciseConfig copyWith({
    OperationKind? operation,
    StudyMode? mode,
    ExerciseFormat? format,
    int? baseNumber,
    List<int>? selectedTables,
    int? questionCount,
    int? timedSeconds,
    bool? shuffleQuestions,
    RevisionFormat? revisionFormat,
    DifficultyLevel? difficultyLevel,
  }) {
    return ExerciseConfig(
      operation: operation ?? this.operation,
      mode: mode ?? this.mode,
      format: format ?? this.format,
      baseNumber: baseNumber ?? this.baseNumber,
      selectedTables: selectedTables ?? this.selectedTables,
      questionCount: questionCount ?? this.questionCount,
      timedSeconds: timedSeconds ?? this.timedSeconds,
      shuffleQuestions: shuffleQuestions ?? this.shuffleQuestions,
      revisionFormat: revisionFormat ?? this.revisionFormat,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
    );
  }
}
