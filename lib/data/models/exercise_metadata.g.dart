// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_metadata.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OperationKindAdapter extends TypeAdapter<OperationKind> {
  @override
  final int typeId = 2;

  @override
  OperationKind read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return OperationKind.addition;
      case 1:
        return OperationKind.multiplication;
      default:
        return OperationKind.addition;
    }
  }

  @override
  void write(BinaryWriter writer, OperationKind obj) {
    switch (obj) {
      case OperationKind.addition:
        writer.writeByte(0);
        break;
      case OperationKind.multiplication:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OperationKindAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StudyModeAdapter extends TypeAdapter<StudyMode> {
  @override
  final int typeId = 3;

  @override
  StudyMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return StudyMode.revision;
      case 1:
        return StudyMode.exercise;
      default:
        return StudyMode.revision;
    }
  }

  @override
  void write(BinaryWriter writer, StudyMode obj) {
    switch (obj) {
      case StudyMode.revision:
        writer.writeByte(0);
        break;
      case StudyMode.exercise:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudyModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExerciseFormatAdapter extends TypeAdapter<ExerciseFormat> {
  @override
  final int typeId = 4;

  @override
  ExerciseFormat read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExerciseFormat.multipleChoice;
      case 1:
        return ExerciseFormat.directInput;
      case 2:
        return ExerciseFormat.timedChallenge;
      default:
        return ExerciseFormat.multipleChoice;
    }
  }

  @override
  void write(BinaryWriter writer, ExerciseFormat obj) {
    switch (obj) {
      case ExerciseFormat.multipleChoice:
        writer.writeByte(0);
        break;
      case ExerciseFormat.directInput:
        writer.writeByte(1);
        break;
      case ExerciseFormat.timedChallenge:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseFormatAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RevisionFormatAdapter extends TypeAdapter<RevisionFormat> {
  @override
  final int typeId = 13;

  @override
  RevisionFormat read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RevisionFormat.listView;
      case 1:
        return RevisionFormat.flashCard;
      default:
        return RevisionFormat.listView;
    }
  }

  @override
  void write(BinaryWriter writer, RevisionFormat obj) {
    switch (obj) {
      case RevisionFormat.listView:
        writer.writeByte(0);
        break;
      case RevisionFormat.flashCard:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RevisionFormatAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DifficultyLevelAdapter extends TypeAdapter<DifficultyLevel> {
  @override
  final int typeId = 14;

  @override
  DifficultyLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DifficultyLevel.easy;
      case 1:
        return DifficultyLevel.medium;
      case 2:
        return DifficultyLevel.hard;
      default:
        return DifficultyLevel.easy;
    }
  }

  @override
  void write(BinaryWriter writer, DifficultyLevel obj) {
    switch (obj) {
      case DifficultyLevel.easy:
        writer.writeByte(0);
        break;
      case DifficultyLevel.medium:
        writer.writeByte(1);
        break;
      case DifficultyLevel.hard:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DifficultyLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RewardTypeAdapter extends TypeAdapter<RewardType> {
  @override
  final int typeId = 8;

  @override
  RewardType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RewardType.star;
      case 1:
        return RewardType.badge;
      default:
        return RewardType.star;
    }
  }

  @override
  void write(BinaryWriter writer, RewardType obj) {
    switch (obj) {
      case RewardType.star:
        writer.writeByte(0);
        break;
      case RewardType.badge:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RewardTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
