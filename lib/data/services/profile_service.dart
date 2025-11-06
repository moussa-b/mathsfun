import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/profile.dart';
import '../repositories/profile_repository.dart';
import '../repositories/settings_repository.dart';

class ProfileService extends ChangeNotifier {
  ProfileService({
    ProfileRepository? profileRepository,
    SettingsRepository? settingsRepository,
  }) : _profileRepository = profileRepository ?? ProfileRepository(),
       _settingsRepository = settingsRepository ?? SettingsRepository() {
    _profiles = _profileRepository.getAll()
      ..sort((Profile a, Profile b) => a.nickname.compareTo(b.nickname));
    _activeProfile = _resolveInitialProfile();
    _profileListenable = _profileRepository.watchAll()
      ..addListener(_onProfilesChanged);
  }

  final ProfileRepository _profileRepository;
  final SettingsRepository _settingsRepository;

  late final ValueListenable<Box<Profile>> _profileListenable;

  List<Profile> _profiles = <Profile>[];
  Profile? _activeProfile;

  List<Profile> get profiles => List<Profile>.unmodifiable(_profiles);

  Profile? get activeProfile => _activeProfile;

  bool get hasProfiles => _profiles.isNotEmpty;

  bool get hasMultipleProfiles => _profiles.length > 1;

  Future<Profile> createProfile({
    required String nickname,
    required SchoolClass schoolClass,
    required String avatarId,
  }) async {
    final Profile newProfile = await _profileRepository.create(
      nickname: nickname,
      schoolClass: schoolClass,
      avatarId: avatarId,
    );
    _profiles = <Profile>[..._profiles, newProfile]
      ..sort((Profile a, Profile b) => a.nickname.compareTo(b.nickname));
    _activeProfile = newProfile;
    await _syncSettingsProfile(newProfile.id);
    notifyListeners();
    return newProfile;
  }

  Future<void> updateProfile(Profile profile) async {
    await _profileRepository.update(profile);
    await _syncSettingsProfile(profile.id);
  }

  Future<void> deleteProfile(String id) async {
    await _profileRepository.delete(id);
    _profiles = _profiles
        .where((Profile profile) => profile.id != id)
        .toList(growable: false);
    if (_activeProfile?.id == id) {
      _activeProfile = _profiles.isNotEmpty ? _profiles.first : null;
      await _syncSettingsProfile(_activeProfile?.id);
    }
    notifyListeners();
  }

  Future<void> setActiveProfile(String? profileId) async {
    Profile? profile;
    if (profileId != null) {
      for (final Profile candidate in _profiles) {
        if (candidate.id == profileId) {
          profile = candidate;
          break;
        }
      }
    }
    _activeProfile = profile ?? (_profiles.isNotEmpty ? _profiles.first : null);
    await _syncSettingsProfile(_activeProfile?.id);
    notifyListeners();
  }

  Future<void> _syncSettingsProfile(String? profileId) async {
    final settings = _settingsRepository.current;
    await _settingsRepository.save(settings.copyWith(lastProfileId: profileId));
  }

  Profile? _resolveInitialProfile() {
    final String? lastProfileId = _settingsRepository.current.lastProfileId;
    if (lastProfileId != null) {
      for (final Profile profile in _profiles) {
        if (profile.id == lastProfileId) {
          return profile;
        }
      }
    }
    return _profiles.isNotEmpty ? _profiles.first : null;
  }

  void _onProfilesChanged() {
    _profiles = _profileRepository.getAll()
      ..sort((Profile a, Profile b) => a.nickname.compareTo(b.nickname));
    Profile? updatedActive;
    if (_activeProfile != null) {
      final String activeId = _activeProfile!.id;
      for (final Profile profile in _profiles) {
        if (profile.id == activeId) {
          updatedActive = profile;
          break;
        }
      }
    }
    _activeProfile =
        updatedActive ?? (_profiles.isNotEmpty ? _profiles.first : null);
    notifyListeners();
  }

  @override
  void dispose() {
    _profileListenable.removeListener(_onProfilesChanged);
    super.dispose();
  }
}
