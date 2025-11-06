// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProfileAdapter extends TypeAdapter<Profile> {
  @override
  final int typeId = 0;

  @override
  Profile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Profile(
      id: fields[0] as String,
      nickname: fields[1] as String,
      schoolClass: fields[2] as SchoolClass,
      avatarId: fields[3] as String,
      createdAt: fields[4] as DateTime,
      lastPlayedAt: fields[5] as DateTime?,
      totalStars: fields[6] as int,
      earnedBadges: (fields[7] as List?)?.cast<String>(),
      completedSessions: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Profile obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nickname)
      ..writeByte(2)
      ..write(obj.schoolClass)
      ..writeByte(3)
      ..write(obj.avatarId)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.lastPlayedAt)
      ..writeByte(6)
      ..write(obj.totalStars)
      ..writeByte(7)
      ..write(obj.earnedBadges)
      ..writeByte(8)
      ..write(obj.completedSessions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SchoolClassAdapter extends TypeAdapter<SchoolClass> {
  @override
  final int typeId = 1;

  @override
  SchoolClass read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SchoolClass.cp;
      case 1:
        return SchoolClass.ce1;
      case 2:
        return SchoolClass.ce2;
      case 3:
        return SchoolClass.cm1;
      case 4:
        return SchoolClass.cm2;
      default:
        return SchoolClass.cp;
    }
  }

  @override
  void write(BinaryWriter writer, SchoolClass obj) {
    switch (obj) {
      case SchoolClass.cp:
        writer.writeByte(0);
        break;
      case SchoolClass.ce1:
        writer.writeByte(1);
        break;
      case SchoolClass.ce2:
        writer.writeByte(2);
        break;
      case SchoolClass.cm1:
        writer.writeByte(3);
        break;
      case SchoolClass.cm2:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SchoolClassAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
