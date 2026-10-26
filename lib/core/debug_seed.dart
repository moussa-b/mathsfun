import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../data/local/hive_boxes.dart';
import '../data/models/profile.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/settings_repository.dart';

/// Debug builds only: with `--dart-define=SEED_TEST_PROFILES=true`, creates
/// two test profiles (and switches the app to French) when none exist, so a
/// fresh install can be tested right away.
Future<void> seedTestProfilesIfRequested() async {
  const bool requested = bool.fromEnvironment('SEED_TEST_PROFILES');
  if (!kDebugMode || !requested) {
    return;
  }
  if (Hive.box<Profile>(HiveBoxes.profiles).isNotEmpty) {
    return;
  }
  final ProfileRepository profiles = ProfileRepository();
  await profiles.create(
    nickname: 'Léa',
    schoolClass: SchoolClass.ce1,
    avatarId: 'lion',
  );
  await profiles.create(
    nickname: 'Noah',
    schoolClass: SchoolClass.cm1,
    avatarId: 'robot',
  );
  final SettingsRepository settings = SettingsRepository();
  if (settings.current.localeCode == null) {
    await settings.save(settings.current.copyWith(localeCode: 'fr'));
  }
}
