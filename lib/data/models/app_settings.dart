import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 9)
class AppSettings extends HiveObject {
  AppSettings({
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.animationsEnabled = true,
    this.parentPinHash,
    this.timedChallengeSeconds = 60,
    this.lastProfileId,
    this.localeCode,
    this.lastRevisionTableMultiplication,
    this.lastRevisionTableAddition,
    this.lastExerciseSelectedTablesMultiplication,
    this.lastExerciseSelectedTablesAddition,
    this.lastExerciseDifficultyLevelMultiplication,
    this.lastExerciseDifficultyLevelAddition,
    this.lastExerciseShuffleQuestionsMultiplication,
    this.lastExerciseShuffleQuestionsAddition,
  });

  @HiveField(0)
  bool soundEnabled;

  @HiveField(1)
  bool hapticsEnabled;

  @HiveField(2)
  bool animationsEnabled;

  @HiveField(3)
  String? parentPinHash;

  @HiveField(4)
  int timedChallengeSeconds;

  @HiveField(5)
  String? lastProfileId;

  @HiveField(6)
  String? localeCode;

  @HiveField(7)
  int? lastRevisionTableMultiplication;

  @HiveField(8)
  int? lastRevisionTableAddition;

  @HiveField(9)
  List<int>? lastExerciseSelectedTablesMultiplication;

  @HiveField(10)
  List<int>? lastExerciseSelectedTablesAddition;

  @HiveField(11)
  int? lastExerciseDifficultyLevelMultiplication;

  @HiveField(12)
  int? lastExerciseDifficultyLevelAddition;

  @HiveField(13)
  bool? lastExerciseShuffleQuestionsMultiplication;

  @HiveField(14)
  bool? lastExerciseShuffleQuestionsAddition;

  AppSettings copyWith({
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? animationsEnabled,
    String? parentPinHash,
    bool removeParentPin = false,
    int? timedChallengeSeconds,
    String? lastProfileId,
    String? localeCode,
    int? lastRevisionTableMultiplication,
    int? lastRevisionTableAddition,
    List<int>? lastExerciseSelectedTablesMultiplication,
    List<int>? lastExerciseSelectedTablesAddition,
    int? lastExerciseDifficultyLevelMultiplication,
    int? lastExerciseDifficultyLevelAddition,
    bool? lastExerciseShuffleQuestionsMultiplication,
    bool? lastExerciseShuffleQuestionsAddition,
  }) {
    return AppSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      parentPinHash: removeParentPin
          ? null
          : parentPinHash ?? this.parentPinHash,
      timedChallengeSeconds:
          timedChallengeSeconds ?? this.timedChallengeSeconds,
      lastProfileId: lastProfileId ?? this.lastProfileId,
      localeCode: localeCode ?? this.localeCode,
      lastRevisionTableMultiplication: lastRevisionTableMultiplication ?? this.lastRevisionTableMultiplication,
      lastRevisionTableAddition: lastRevisionTableAddition ?? this.lastRevisionTableAddition,
      lastExerciseSelectedTablesMultiplication: lastExerciseSelectedTablesMultiplication ?? this.lastExerciseSelectedTablesMultiplication,
      lastExerciseSelectedTablesAddition: lastExerciseSelectedTablesAddition ?? this.lastExerciseSelectedTablesAddition,
      lastExerciseDifficultyLevelMultiplication: lastExerciseDifficultyLevelMultiplication ?? this.lastExerciseDifficultyLevelMultiplication,
      lastExerciseDifficultyLevelAddition: lastExerciseDifficultyLevelAddition ?? this.lastExerciseDifficultyLevelAddition,
      lastExerciseShuffleQuestionsMultiplication: lastExerciseShuffleQuestionsMultiplication ?? this.lastExerciseShuffleQuestionsMultiplication,
      lastExerciseShuffleQuestionsAddition: lastExerciseShuffleQuestionsAddition ?? this.lastExerciseShuffleQuestionsAddition,
    );
  }
}
