import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../local/hive_boxes.dart';
import '../models/profile.dart';

class ProfileRepository {
  ProfileRepository({Box<Profile>? box, Uuid? uuid})
    : _box = box ?? Hive.box<Profile>(HiveBoxes.profiles),
      _uuid = uuid ?? const Uuid();

  final Box<Profile> _box;
  final Uuid _uuid;

  ValueListenable<Box<Profile>> watchAll() => _box.listenable();

  List<Profile> getAll() => _box.values.toList(growable: false);

  Profile? getById(String id) => _box.get(id);

  Future<Profile> create({
    required String nickname,
    required SchoolClass schoolClass,
    required String avatarId,
  }) async {
    final String id = _uuid.v4();
    final Profile profile = Profile(
      id: id,
      nickname: nickname,
      schoolClass: schoolClass,
      avatarId: avatarId,
      createdAt: DateTime.now(),
    );
    await _box.put(id, profile);
    return profile;
  }

  Future<void> update(Profile profile) async {
    await _box.put(profile.id, profile);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> deleteAll() async {
    await _box.clear();
  }
}
