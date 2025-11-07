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
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(7)
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
      ..write(obj.localeCode);
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
