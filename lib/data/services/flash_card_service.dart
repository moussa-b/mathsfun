import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/exercise_metadata.dart';
import '../models/flash_card_result.dart';
import '../repositories/flash_card_repository.dart';

class FlashCardService extends ChangeNotifier {
  FlashCardService({FlashCardRepository? repository})
      : _repository = repository ?? FlashCardRepository() {
    _resultsListenable = _repository.watchAll()
      ..addListener(_onResultsChanged);
    _results = _resultsListenable.value.values.toList(growable: false)
      ..sort(
        (FlashCardResult a, FlashCardResult b) =>
            b.timestamp.compareTo(a.timestamp),
      );
  }

  final FlashCardRepository _repository;
  late final ValueListenable<Box<FlashCardResult>> _resultsListenable;
  List<FlashCardResult> _results = <FlashCardResult>[];

  List<FlashCardResult> get results =>
      List<FlashCardResult>.unmodifiable(_results);

  List<FlashCardResult> resultsForProfile(String profileId) => _results
      .where((FlashCardResult result) => result.profileId == profileId)
      .toList(growable: false);

  List<FlashCardResult> resultsForTable({
    required String profileId,
    required int table,
    required OperationKind operation,
  }) =>
      _results
          .where((FlashCardResult result) =>
              result.profileId == profileId &&
              result.table == table &&
              result.operation == operation)
          .toList(growable: false);

  Future<FlashCardResult> saveResult({
    required String profileId,
    required OperationKind operation,
    required int table,
    required int multiplier,
    required FlashCardStatus status,
  }) async {
    final FlashCardResult result = await _repository.saveResult(
      profileId: profileId,
      operation: operation,
      table: table,
      multiplier: multiplier,
      status: status,
    );
    return result;
  }

  Future<void> deleteResult(String id) => _repository.delete(id);

  Future<void> deleteResultsForProfile(String profileId) =>
      _repository.deleteForProfile(profileId);

  Future<void> deleteResultsForTable({
    required String profileId,
    required int table,
    required OperationKind operation,
  }) =>
      _repository.deleteForTable(
        profileId: profileId,
        table: table,
        operation: operation,
      );

  void _onResultsChanged() {
    _results = _resultsListenable.value.values.toList(growable: false)
      ..sort(
        (FlashCardResult a, FlashCardResult b) =>
            b.timestamp.compareTo(a.timestamp),
      );
    notifyListeners();
  }

  @override
  void dispose() {
    _resultsListenable.removeListener(_onResultsChanged);
    super.dispose();
  }
}

