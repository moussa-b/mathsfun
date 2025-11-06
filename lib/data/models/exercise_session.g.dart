// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuestionResultAdapter extends TypeAdapter<QuestionResult> {
  @override
  final int typeId = 6;

  @override
  QuestionResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuestionResult(
      prompt: fields[0] as String,
      correctAnswer: fields[1] as int,
      userAnswer: fields[2] as int?,
      isCorrect: fields[3] as bool,
      responseMillis: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, QuestionResult obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.prompt)
      ..writeByte(1)
      ..write(obj.correctAnswer)
      ..writeByte(2)
      ..write(obj.userAnswer)
      ..writeByte(3)
      ..write(obj.isCorrect)
      ..writeByte(4)
      ..write(obj.responseMillis);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExerciseSessionAdapter extends TypeAdapter<ExerciseSession> {
  @override
  final int typeId = 5;

  @override
  ExerciseSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseSession(
      id: fields[0] as String,
      profileId: fields[1] as String,
      operation: fields[2] as OperationKind,
      mode: fields[3] as StudyMode,
      format: fields[4] as ExerciseFormat,
      startedAt: fields[5] as DateTime,
      durationMillis: fields[6] as int,
      questions: (fields[7] as List).cast<QuestionResult>(),
      targetTable: fields[8] as int?,
      timedSeconds: fields[9] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseSession obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.profileId)
      ..writeByte(2)
      ..write(obj.operation)
      ..writeByte(3)
      ..write(obj.mode)
      ..writeByte(4)
      ..write(obj.format)
      ..writeByte(5)
      ..write(obj.startedAt)
      ..writeByte(6)
      ..write(obj.durationMillis)
      ..writeByte(7)
      ..write(obj.questions)
      ..writeByte(8)
      ..write(obj.targetTable)
      ..writeByte(9)
      ..write(obj.timedSeconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
