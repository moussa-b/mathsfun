import 'package:hive/hive.dart';

part 'exercise_metadata.g.dart';

@HiveType(typeId: 2)
enum OperationKind {
  @HiveField(0)
  addition,
  @HiveField(1)
  multiplication,
}

extension OperationKindX on OperationKind {
  String get label => switch (this) {
    OperationKind.addition => 'Addition',
    OperationKind.multiplication => 'Multiplication',
  };

  String get themeColorKey => switch (this) {
    OperationKind.addition => 'red',
    OperationKind.multiplication => 'blue',
  };
}

@HiveType(typeId: 3)
enum StudyMode {
  @HiveField(0)
  revision,
  @HiveField(1)
  exercise,
}

extension StudyModeX on StudyMode {
  String get label => switch (this) {
    StudyMode.revision => 'Revision',
    StudyMode.exercise => 'Exercise',
  };
}

@HiveType(typeId: 4)
enum ExerciseFormat {
  @HiveField(0)
  multipleChoice,
  @HiveField(1)
  directInput,
  @HiveField(2)
  timedChallenge,
}

extension ExerciseFormatX on ExerciseFormat {
  String get label => switch (this) {
    ExerciseFormat.multipleChoice => 'Multiple Choice',
    ExerciseFormat.directInput => 'Direct Input',
    ExerciseFormat.timedChallenge => 'Timed Challenge',
  };

  bool get isTimed => this == ExerciseFormat.timedChallenge;
}

@HiveType(typeId: 13)
enum RevisionFormat {
  @HiveField(0)
  listView,
  @HiveField(1)
  flashCard,
}

extension RevisionFormatX on RevisionFormat {
  String get label => switch (this) {
    RevisionFormat.listView => 'List View',
    RevisionFormat.flashCard => 'Flash Cards',
  };
}

@HiveType(typeId: 14)
enum DifficultyLevel {
  @HiveField(0)
  easy,
  @HiveField(1)
  medium,
  @HiveField(2)
  hard,
}

extension DifficultyLevelX on DifficultyLevel {
  String get label => switch (this) {
        DifficultyLevel.easy => 'Easy',
        DifficultyLevel.medium => 'Medium',
        DifficultyLevel.hard => 'Hard',
      };

  /// Time limit per question in seconds. `null` represents no timer.
  int? get timeLimitSeconds => switch (this) {
        DifficultyLevel.easy => null,
        DifficultyLevel.medium => 15,
        DifficultyLevel.hard => 7,
      };
}

@HiveType(typeId: 8)
enum RewardType {
  @HiveField(0)
  star,
  @HiveField(1)
  badge,
}

extension RewardTypeX on RewardType {
  String get label => switch (this) {
    RewardType.star => 'Star',
    RewardType.badge => 'Badge',
  };
}
