import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/exercise_metadata.dart';
import '../models/reward.dart';
import '../repositories/reward_repository.dart';

class RewardService extends ChangeNotifier {
  RewardService({RewardRepository? repository})
    : _repository = repository ?? RewardRepository() {
    _rewardListenable = _repository.watchAll()..addListener(_onRewardsChanged);
    _rewards = _rewardListenable.value.values.toList(growable: false)
      ..sort((Reward a, Reward b) => b.awardedAt.compareTo(a.awardedAt));
  }

  final RewardRepository _repository;
  late final ValueListenable<Box<Reward>> _rewardListenable;
  List<Reward> _rewards = <Reward>[];

  List<Reward> get rewards => List<Reward>.unmodifiable(_rewards);

  List<Reward> rewardsForProfile(String profileId) => _rewards
      .where((Reward reward) => reward.profileId == profileId)
      .toList(growable: false);

  Future<Reward> award({
    required String profileId,
    required RewardType type,
    required String title,
    String description = '',
    int value = 1,
    DateTime? awardedAt,
  }) async {
    final Reward reward = await _repository.award(
      profileId: profileId,
      type: type,
      title: title,
      description: description,
      value: value,
      awardedAt: awardedAt,
    );
    return reward;
  }

  Future<void> rescind(String rewardId) => _repository.rescind(rewardId);

  Future<void> clearProfile(String profileId) =>
      _repository.clearForProfile(profileId);

  void _onRewardsChanged() {
    _rewards = _rewardListenable.value.values.toList(growable: false)
      ..sort((Reward a, Reward b) => b.awardedAt.compareTo(a.awardedAt));
    notifyListeners();
  }

  @override
  void dispose() {
    _rewardListenable.removeListener(_onRewardsChanged);
    super.dispose();
  }
}
