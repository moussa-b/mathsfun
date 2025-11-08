import 'dart:io';

import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/app_settings.dart';
import '../models/exercise_metadata.dart';
import '../models/exercise_session.dart';
import '../models/flash_card_result.dart';
import '../models/profile.dart';
import '../models/reward.dart';
import 'hive_boxes.dart';

class HiveInitializer {
  const HiveInitializer();

  Future<void> init() async {
    try {
      await Hive.initFlutter();
    } on MissingPluginException {
      final Directory tempDir = await Directory.systemTemp.createTemp(
        'mathsfun_hive_',
      );
      Hive.init(tempDir.path);
    }
    _registerAdapters();

    await Future.wait([
      Hive.openBox<AppSettings>(HiveBoxes.settings),
      Hive.openBox<Profile>(HiveBoxes.profiles),
      Hive.openBox<ExerciseSession>(HiveBoxes.sessions),
      Hive.openBox<Reward>(HiveBoxes.rewards),
      Hive.openBox<FlashCardResult>(HiveBoxes.flashCardResults),
    ]);

    final settingsBox = Hive.box<AppSettings>(HiveBoxes.settings);
    if (settingsBox.isEmpty) {
      await settingsBox.put('app', AppSettings());
    }
  }

  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProfileAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(SchoolClassAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(OperationKindAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(StudyModeAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(ExerciseFormatAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(ExerciseSessionAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(QuestionResultAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(RewardAdapter());
    }
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(RewardTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter(AppSettingsAdapter());
    }
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(FlashCardResultAdapter());
    }
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(FlashCardStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(13)) {
      Hive.registerAdapter(RevisionFormatAdapter());
    }
    if (!Hive.isAdapterRegistered(14)) {
      Hive.registerAdapter(DifficultyLevelAdapter());
    }
  }
}
