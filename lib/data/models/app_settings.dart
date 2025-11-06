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

  AppSettings copyWith({
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? animationsEnabled,
    String? parentPinHash,
    bool removeParentPin = false,
    int? timedChallengeSeconds,
    String? lastProfileId,
    String? localeCode,
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
    );
  }
}
