import 'dart:math';

import 'package:uuid/uuid.dart';

import '../../../data/models/exercise_metadata.dart';
import '../models/exercise_config.dart';
import '../models/exercise_question.dart';

class ExerciseQuestionGenerator {
  ExerciseQuestionGenerator({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;
  final Random _random = Random();

  List<ExerciseQuestion> generate(ExerciseConfig config) {
    final int questionCount = config.questionCount;
    final Set<String> questionKeys = <String>{};
    final List<ExerciseQuestion> questions = <ExerciseQuestion>[];

    while (questions.length < questionCount) {
      final _Operands operands = _nextOperands(config);
      final String key =
          '${operands.left}-${operands.right}-${config.operation.name}';
      if (questionKeys.contains(key)) {
        continue;
      }
      questionKeys.add(key);

      final int answer = _calculateAnswer(
        config.operation,
        operands.left,
        operands.right,
      );
      final List<int> choices = config.format == ExerciseFormat.multipleChoice
          ? _buildChoices(answer, config.operation)
          : const <int>[];

      questions.add(
        ExerciseQuestion(
          id: _uuid.v4(),
          operation: config.operation,
          left: operands.left,
          right: operands.right,
          correctAnswer: answer,
          choices: choices,
        ),
      );
    }

    return questions;
  }

  _Operands _nextOperands(ExerciseConfig config) {
    switch (config.operation) {
      case OperationKind.multiplication:
        final int base = config.baseNumber;
        final int second = _random.nextInt(12) + 1;
        return _Operands(left: base, right: second);
      case OperationKind.addition:
        final int base = config.baseNumber;
        final int second = _random.nextInt(10) + 1;
        return _Operands(left: base, right: second);
    }
  }

  int _calculateAnswer(OperationKind operation, int left, int right) {
    switch (operation) {
      case OperationKind.multiplication:
        return left * right;
      case OperationKind.addition:
        return left + right;
    }
  }

  List<int> _buildChoices(int correct, OperationKind operation) {
    final Set<int> options = <int>{correct};
    while (options.length < 4) {
      final int delta = operation == OperationKind.multiplication
          ? _random.nextInt(12) + 1
          : _random.nextInt(7) + 1;
      int candidate = correct + (_random.nextBool() ? delta : -delta);
      if (candidate < 0) {
        candidate = correct + delta;
      }
      options.add(candidate);
    }
    final List<int> list = options.toList();
    list.shuffle(_random);
    return list;
  }
}

class _Operands {
  const _Operands({required this.left, required this.right});

  final int left;
  final int right;
}
