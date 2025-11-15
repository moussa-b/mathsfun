import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../core/utils/pin_utils.dart';
import '../models/app_settings.dart';
import '../models/exercise_metadata.dart';
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

  int? getLastRevisionTable(OperationKind operation) {
    switch (operation) {
      case OperationKind.multiplication:
        return _settings.lastRevisionTableMultiplication;
      case OperationKind.addition:
        return _settings.lastRevisionTableAddition;
    }
  }

  Future<void> setLastRevisionTable(OperationKind operation, int table) async {
    switch (operation) {
      case OperationKind.multiplication:
        await _save(_settings.copyWith(lastRevisionTableMultiplication: table));
        break;
      case OperationKind.addition:
        await _save(_settings.copyWith(lastRevisionTableAddition: table));
        break;
    }
  }

  Set<int>? getLastExerciseSelectedTables(OperationKind operation) {
    final List<int>? tables = switch (operation) {
      OperationKind.multiplication =>
          _settings.lastExerciseSelectedTablesMultiplication,
      OperationKind.addition =>
          _settings.lastExerciseSelectedTablesAddition,
    };
    return tables?.toSet();
  }

  Future<void> setLastExerciseSelectedTables(
    OperationKind operation,
    Set<int> tables,
  ) async {
    final List<int> tablesList = tables.toList()..sort();
    switch (operation) {
      case OperationKind.multiplication:
        await _save(_settings.copyWith(
          lastExerciseSelectedTablesMultiplication: tablesList,
        ));
        break;
      case OperationKind.addition:
        await _save(_settings.copyWith(
          lastExerciseSelectedTablesAddition: tablesList,
        ));
        break;
    }
  }

  DifficultyLevel? getLastExerciseDifficultyLevel(OperationKind operation) {
    final int? index = switch (operation) {
      OperationKind.multiplication =>
          _settings.lastExerciseDifficultyLevelMultiplication,
      OperationKind.addition =>
          _settings.lastExerciseDifficultyLevelAddition,
    };
    if (index == null) return null;
    return DifficultyLevel.values[index];
  }

  Future<void> setLastExerciseDifficultyLevel(
    OperationKind operation,
    DifficultyLevel level,
  ) async {
    final int index = level.index;
    switch (operation) {
      case OperationKind.multiplication:
        await _save(_settings.copyWith(
          lastExerciseDifficultyLevelMultiplication: index,
        ));
        break;
      case OperationKind.addition:
        await _save(_settings.copyWith(
          lastExerciseDifficultyLevelAddition: index,
        ));
        break;
    }
  }

  bool? getLastExerciseShuffleQuestions(OperationKind operation) {
    return switch (operation) {
      OperationKind.multiplication =>
          _settings.lastExerciseShuffleQuestionsMultiplication,
      OperationKind.addition =>
          _settings.lastExerciseShuffleQuestionsAddition,
    };
  }

  Future<void> setLastExerciseShuffleQuestions(
    OperationKind operation,
    bool shuffle,
  ) async {
    switch (operation) {
      case OperationKind.multiplication:
        await _save(_settings.copyWith(
          lastExerciseShuffleQuestionsMultiplication: shuffle,
        ));
        break;
      case OperationKind.addition:
        await _save(_settings.copyWith(
          lastExerciseShuffleQuestionsAddition: shuffle,
        ));
        break;
    }
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
