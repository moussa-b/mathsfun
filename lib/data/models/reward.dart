import 'package:hive/hive.dart';

import 'exercise_metadata.dart';

part 'reward.g.dart';

@HiveType(typeId: 7)
class Reward extends HiveObject {
  Reward({
    required this.id,
    required this.profileId,
    required this.type,
    required this.title,
    required this.description,
    required this.awardedAt,
    this.value = 1,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String profileId;

  @HiveField(2)
  RewardType type;

  @HiveField(3)
  String title;

  @HiveField(4)
  String description;

  @HiveField(5)
  DateTime awardedAt;

  @HiveField(6)
  int value;
}
