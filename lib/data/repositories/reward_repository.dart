import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../local/hive_boxes.dart';
import '../models/exercise_metadata.dart';
import '../models/reward.dart';

class RewardRepository {
  RewardRepository({Box<Reward>? box, Uuid? uuid})
    : _box = box ?? Hive.box<Reward>(HiveBoxes.rewards),
      _uuid = uuid ?? const Uuid();

  final Box<Reward> _box;
  final Uuid _uuid;

  ValueListenable<Box<Reward>> watchAll() => _box.listenable();

  Iterable<Reward> listByProfile(String profileId) => _box.values
      .where((Reward reward) => reward.profileId == profileId)
      .toList(growable: false);

  Future<Reward> award({
    required String profileId,
    required RewardType type,
    required String title,
    String description = '',
    DateTime? awardedAt,
    int value = 1,
  }) async {
    final Reward reward = Reward(
      id: _uuid.v4(),
      profileId: profileId,
      type: type,
      title: title,
      description: description,
      awardedAt: awardedAt ?? DateTime.now(),
      value: value,
    );
    await _box.put(reward.id, reward);
    return reward;
  }

  Future<void> rescind(String rewardId) async {
    await _box.delete(rewardId);
  }

  Future<void> clearForProfile(String profileId) async {
    final Iterable<dynamic> keysToRemove = _box.keys.where((dynamic key) {
      final Reward? reward = _box.get(key);
      return reward?.profileId == profileId;
    });
    await _box.deleteAll(keysToRemove);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}
