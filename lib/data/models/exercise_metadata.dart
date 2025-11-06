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
