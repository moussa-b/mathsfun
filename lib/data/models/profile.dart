import 'package:hive/hive.dart';

part 'profile.g.dart';

@HiveType(typeId: 1)
enum SchoolClass {
  @HiveField(0)
  cp,
  @HiveField(1)
  ce1,
  @HiveField(2)
  ce2,
  @HiveField(3)
  cm1,
  @HiveField(4)
  cm2,
}

extension SchoolClassX on SchoolClass {
  String get label {
    switch (this) {
      case SchoolClass.cp:
        return 'CP';
      case SchoolClass.ce1:
        return 'CE1';
      case SchoolClass.ce2:
        return 'CE2';
      case SchoolClass.cm1:
        return 'CM1';
      case SchoolClass.cm2:
        return 'CM2';
    }
  }
}

@HiveType(typeId: 0)
class Profile extends HiveObject {
  Profile({
    required this.id,
    required this.nickname,
    required this.schoolClass,
    required this.avatarId,
    required this.createdAt,
    this.lastPlayedAt,
    this.totalStars = 0,
    List<String>? earnedBadges,
    this.completedSessions = 0,
  }) : earnedBadges = earnedBadges ?? <String>[];

  @HiveField(0)
  String id;

  @HiveField(1)
  String nickname;

  @HiveField(2)
  SchoolClass schoolClass;

  @HiveField(3)
  String avatarId;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime? lastPlayedAt;

  @HiveField(6)
  int totalStars;

  @HiveField(7)
  List<String> earnedBadges;

  @HiveField(8)
  int completedSessions;

  Profile copyWith({
    String? nickname,
    SchoolClass? schoolClass,
    String? avatarId,
    DateTime? lastPlayedAt,
    int? totalStars,
    List<String>? earnedBadges,
    int? completedSessions,
  }) {
    return Profile(
      id: id,
      nickname: nickname ?? this.nickname,
      schoolClass: schoolClass ?? this.schoolClass,
      avatarId: avatarId ?? this.avatarId,
      createdAt: createdAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      totalStars: totalStars ?? this.totalStars,
      earnedBadges: earnedBadges ?? List<String>.from(this.earnedBadges),
      completedSessions: completedSessions ?? this.completedSessions,
    );
  }
}
