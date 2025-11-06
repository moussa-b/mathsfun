import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../core/utils/pin_utils.dart';
import '../models/app_settings.dart';
import '../repositories/settings_repository.dart';

class SettingsService extends ChangeNotifier {
  SettingsService({SettingsRepository? repository})
    : _repository = repository ?? SettingsRepository() {
    _settings = _repository.current;
    _settingsListenable = _repository.watch()..addListener(_onSettingsChanged);
  }

  final SettingsRepository _repository;
  late AppSettings _settings;
  late final ValueListenable<Box<AppSettings>> _settingsListenable;

  AppSettings get settings => _settings;

  bool get hasParentPin => _settings.parentPinHash != null;

  Locale get locale => Locale(_settings.localeCode ?? 'en');

  Future<void> toggleSound(bool value) =>
      _save(_settings.copyWith(soundEnabled: value));

  Future<void> toggleHaptics(bool value) =>
      _save(_settings.copyWith(hapticsEnabled: value));

  Future<void> toggleAnimations(bool value) =>
      _save(_settings.copyWith(animationsEnabled: value));

  Future<void> updateTimedChallengeSeconds(int seconds) =>
      _save(_settings.copyWith(timedChallengeSeconds: seconds));

  Future<void> setParentPin(String pin) =>
      _save(_settings.copyWith(parentPinHash: hashPin(pin)));

  Future<void> clearParentPin() =>
      _save(_settings.copyWith(removeParentPin: true));

  bool validatePin(String pin) => verifyPin(pin, _settings.parentPinHash);

  Future<void> setLocale(Locale locale) async {
    await _save(_settings.copyWith(localeCode: locale.languageCode));
  }

  Future<void> _save(AppSettings updated) async {
    _settings = updated;
    await _repository.save(_settings);
    notifyListeners();
  }

  void _onSettingsChanged() {
    _settings = _repository.current;
    notifyListeners();
  }

  @override
  void dispose() {
    _settingsListenable.removeListener(_onSettingsChanged);
    super.dispose();
  }
}
