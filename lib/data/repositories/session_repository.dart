import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../local/hive_boxes.dart';
import '../models/exercise_metadata.dart';
import '../models/exercise_session.dart';

class SessionRepository {
  SessionRepository({Box<ExerciseSession>? box, Uuid? uuid})
    : _box = box ?? Hive.box<ExerciseSession>(HiveBoxes.sessions),
      _uuid = uuid ?? const Uuid();

  final Box<ExerciseSession> _box;
  final Uuid _uuid;

  ValueListenable<Box<ExerciseSession>> watchAll() => _box.listenable();

  Iterable<ExerciseSession> listByProfile(String profileId) => _box.values
      .where((ExerciseSession session) => session.profileId == profileId)
      .toList(growable: false);

  Future<ExerciseSession> recordSession({
    required String profileId,
    required OperationKind operation,
    required StudyMode mode,
    required ExerciseFormat format,
    required List<QuestionResult> questions,
    DateTime? startedAt,
    int? durationMillis,
    int? targetTable,
    int? timedSeconds,
  }) async {
    final ExerciseSession session = ExerciseSession(
      id: _uuid.v4(),
      profileId: profileId,
      operation: operation,
      mode: mode,
      format: format,
      startedAt: startedAt ?? DateTime.now(),
      durationMillis: durationMillis ?? 0,
      questions: questions,
      targetTable: targetTable,
      timedSeconds: timedSeconds,
    );
    await _box.put(session.id, session);
    return session;
  }

  Future<void> delete(String sessionId) async {
    await _box.delete(sessionId);
  }

  Future<void> deleteForProfile(String profileId) async {
    final Iterable<dynamic> keysToRemove = _box.keys.where((dynamic key) {
      final ExerciseSession? session = _box.get(key);
      return session?.profileId == profileId;
    });
    await _box.deleteAll(keysToRemove);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}
