// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flash_card_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FlashCardResultAdapter extends TypeAdapter<FlashCardResult> {
  @override
  final int typeId = 10;

  @override
  FlashCardResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FlashCardResult(
      id: fields[0] as String,
      profileId: fields[1] as String,
      operation: fields[2] as OperationKind,
      table: fields[3] as int,
      multiplier: fields[4] as int,
      status: fields[5] as FlashCardStatus,
      timestamp: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FlashCardResult obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.profileId)
      ..writeByte(2)
      ..write(obj.operation)
      ..writeByte(3)
      ..write(obj.table)
      ..writeByte(4)
      ..write(obj.multiplier)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlashCardResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FlashCardStatusAdapter extends TypeAdapter<FlashCardStatus> {
  @override
  final int typeId = 11;

  @override
  FlashCardStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FlashCardStatus.gotIt;
      case 1:
        return FlashCardStatus.reviewAgain;
      default:
        return FlashCardStatus.gotIt;
    }
  }

  @override
  void write(BinaryWriter writer, FlashCardStatus obj) {
    switch (obj) {
      case FlashCardStatus.gotIt:
        writer.writeByte(0);
        break;
      case FlashCardStatus.reviewAgain:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlashCardStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
