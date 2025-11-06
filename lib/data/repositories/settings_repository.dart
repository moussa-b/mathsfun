import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../local/hive_boxes.dart';
import '../models/app_settings.dart';

class SettingsRepository {
  SettingsRepository({Box<AppSettings>? box})
    : _box = box ?? Hive.box<AppSettings>(HiveBoxes.settings);

  final Box<AppSettings> _box;
  static const String _settingsKey = 'app';

  ValueListenable<Box<AppSettings>> watch() => _box.listenable();

  AppSettings get current =>
      _box.get(_settingsKey, defaultValue: AppSettings()) ?? AppSettings();

  Future<void> save(AppSettings settings) async {
    await _box.put(_settingsKey, settings);
  }

  Future<void> reset() async {
    await _box.put(_settingsKey, AppSettings());
  }
}
