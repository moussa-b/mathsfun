import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../local/hive_boxes.dart';
import '../models/exercise_metadata.dart';
import '../models/flash_card_result.dart';

class FlashCardRepository {
  FlashCardRepository({Box<FlashCardResult>? box, Uuid? uuid})
      : _box = box ?? Hive.box<FlashCardResult>(HiveBoxes.flashCardResults),
        _uuid = uuid ?? const Uuid();

  final Box<FlashCardResult> _box;
  final Uuid _uuid;

  ValueListenable<Box<FlashCardResult>> watchAll() => _box.listenable();

  Iterable<FlashCardResult> listByProfile(String profileId) => _box.values
      .where((FlashCardResult result) => result.profileId == profileId)
      .toList(growable: false);

  Iterable<FlashCardResult> listByProfileAndTable({
    required String profileId,
    required int table,
    required OperationKind operation,
  }) =>
      _box.values
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
    final FlashCardResult result = FlashCardResult(
      id: _uuid.v4(),
      profileId: profileId,
      operation: operation,
      table: table,
      multiplier: multiplier,
      status: status,
      timestamp: DateTime.now(),
    );
    await _box.put(result.id, result);
    return result;
  }

  Future<void> delete(String resultId) async {
    await _box.delete(resultId);
  }

  Future<void> deleteForProfile(String profileId) async {
    final Iterable<dynamic> keysToRemove = _box.keys.where((dynamic key) {
      final FlashCardResult? result = _box.get(key);
      return result?.profileId == profileId;
    });
    await _box.deleteAll(keysToRemove);
  }

  Future<void> deleteForTable({
    required String profileId,
    required int table,
    required OperationKind operation,
  }) async {
    final Iterable<dynamic> keysToRemove = _box.keys.where((dynamic key) {
      final FlashCardResult? result = _box.get(key);
      return result?.profileId == profileId &&
          result?.table == table &&
          result?.operation == operation;
    });
    await _box.deleteAll(keysToRemove);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}

