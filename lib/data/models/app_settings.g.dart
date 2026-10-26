// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 9;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      soundEnabled: fields[0] as bool,
      hapticsEnabled: fields[1] as bool,
      animationsEnabled: fields[2] as bool,
      parentPinHash: fields[3] as String?,
      timedChallengeSeconds: fields[4] as int,
      lastProfileId: fields[5] as String?,
      localeCode: fields[6] as String?,
      lastRevisionTableMultiplication: fields[7] as int?,
      lastRevisionTableAddition: fields[8] as int?,
      lastExerciseSelectedTablesMultiplication:
          (fields[9] as List?)?.cast<int>(),
      lastExerciseSelectedTablesAddition: (fields[10] as List?)?.cast<int>(),
      lastExerciseDifficultyLevelMultiplication: fields[11] as int?,
      lastExerciseDifficultyLevelAddition: fields[12] as int?,
      lastExerciseShuffleQuestionsMultiplication: fields[13] as bool?,
      lastExerciseShuffleQuestionsAddition: fields[14] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.soundEnabled)
      ..writeByte(1)
      ..write(obj.hapticsEnabled)
      ..writeByte(2)
      ..write(obj.animationsEnabled)
      ..writeByte(3)
      ..write(obj.parentPinHash)
      ..writeByte(4)
      ..write(obj.timedChallengeSeconds)
      ..writeByte(5)
      ..write(obj.lastProfileId)
      ..writeByte(6)
      ..write(obj.localeCode)
      ..writeByte(7)
      ..write(obj.lastRevisionTableMultiplication)
      ..writeByte(8)
      ..write(obj.lastRevisionTableAddition)
      ..writeByte(9)
      ..write(obj.lastExerciseSelectedTablesMultiplication)
      ..writeByte(10)
      ..write(obj.lastExerciseSelectedTablesAddition)
      ..writeByte(11)
      ..write(obj.lastExerciseDifficultyLevelMultiplication)
      ..writeByte(12)
      ..write(obj.lastExerciseDifficultyLevelAddition)
      ..writeByte(13)
      ..write(obj.lastExerciseShuffleQuestionsMultiplication)
      ..writeByte(14)
      ..write(obj.lastExerciseShuffleQuestionsAddition);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
