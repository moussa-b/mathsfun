import '../../../data/models/exercise_metadata.dart';

class ExerciseQuestion {
  const ExerciseQuestion({
    required this.id,
    required this.operation,
    required this.left,
    required this.right,
    required this.correctAnswer,
    this.choices = const <int>[],
  });

  final String id;
  final OperationKind operation;
  final int left;
  final int right;
  final int correctAnswer;
  final List<int> choices;

  String get prompt => operation == OperationKind.multiplication
      ? '$left × $right'
      : '$left + $right';
}
