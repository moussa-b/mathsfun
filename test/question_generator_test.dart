import 'package:flutter_test/flutter_test.dart';

import 'package:mathsfun/features/exercise/application/question_generator.dart';
import 'package:mathsfun/features/exercise/models/exercise_config.dart';
import 'package:mathsfun/data/models/exercise_metadata.dart';

void main() {
  final ExerciseQuestionGenerator generator = ExerciseQuestionGenerator();

  test('generates multiplication questions with four choices', () {
    final ExerciseConfig config = const ExerciseConfig(
      operation: OperationKind.multiplication,
      mode: StudyMode.exercise,
      format: ExerciseFormat.multipleChoice,
      baseNumber: 3,
      questionCount: 6,
    );

    final questions = generator.generate(config);

    expect(questions, hasLength(6));
    for (final question in questions) {
      expect(question.prompt, startsWith('3 ×'));
      expect(question.choices, hasLength(4));
      expect(question.choices, contains(question.correctAnswer));
    }
  });

  test('generates addition questions without duplicate prompts', () {
    final ExerciseConfig config = const ExerciseConfig(
      operation: OperationKind.addition,
      mode: StudyMode.exercise,
      format: ExerciseFormat.multipleChoice,
      baseNumber: 5,
      questionCount: 10,
    );

    final questions = generator.generate(config);

    expect(questions.map((q) => q.prompt).toSet(), hasLength(questions.length));
    expect(questions.every((q) => q.prompt.contains('5 +')), isTrue);
  });
}
