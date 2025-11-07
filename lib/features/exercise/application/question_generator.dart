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
    // Cap question count to prevent infinite loops based on operation type
    final int maxQuestionsPerTable = config.operation == OperationKind.multiplication ? 12 : 10;
    final int questionCount = config.questionCount > maxQuestionsPerTable 
        ? maxQuestionsPerTable 
        : config.questionCount;

    // Get the list of tables to practice
    final List<int> tables = config.tables;

    if (config.shuffleQuestions) {
      // Shuffled mode: mix questions from all tables randomly
      return _generateShuffled(config, questionCount, tables);
    } else {
      // Ordered mode: sequential generation (all questions from first table, then second, etc.)
      return _generateOrdered(config, questionCount, tables);
    }
  }

  List<ExerciseQuestion> _generateShuffled(ExerciseConfig config, int questionCountPerTable, List<int> tables) {
    final Set<String> questionKeys = <String>{};
    final List<ExerciseQuestion> questions = <ExerciseQuestion>[];

    // Generate questionCountPerTable questions for each table, then shuffle together
    for (final int table in tables) {
      int tableQuestionCount = 0;
      while (tableQuestionCount < questionCountPerTable) {
        final _Operands operands = _nextOperandsForTable(config, table);
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
        tableQuestionCount++;
      }
    }

    // Shuffle all questions together
    questions.shuffle(_random);
    return questions;
  }

  List<ExerciseQuestion> _generateOrdered(ExerciseConfig config, int questionCountPerTable, List<int> tables) {
    final List<ExerciseQuestion> questions = <ExerciseQuestion>[];

    // Generate questions for each table sequentially
    for (final int table in tables) {
      for (int i = 1; i <= questionCountPerTable; i++) {
        final int left = table;
        final int right = i;
        
        final int answer = _calculateAnswer(
          config.operation,
          left,
          right,
        );
        final List<int> choices = config.format == ExerciseFormat.multipleChoice
            ? _buildChoices(answer, config.operation)
            : const <int>[];

        questions.add(
          ExerciseQuestion(
            id: _uuid.v4(),
            operation: config.operation,
            left: left,
            right: right,
            correctAnswer: answer,
            choices: choices,
          ),
        );
      }
    }

    return questions;
  }

  _Operands _nextOperandsForTable(ExerciseConfig config, int table) {
    switch (config.operation) {
      case OperationKind.multiplication:
        final int second = _random.nextInt(12) + 1;
        return _Operands(left: table, right: second);
      case OperationKind.addition:
        final int second = _random.nextInt(10) + 1;
        return _Operands(left: table, right: second);
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
