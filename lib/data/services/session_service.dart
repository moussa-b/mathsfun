import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/exercise_metadata.dart';
import '../models/exercise_session.dart';
import '../repositories/session_repository.dart';

class SessionService extends ChangeNotifier {
  SessionService({SessionRepository? repository})
    : _repository = repository ?? SessionRepository() {
    _sessionListenable = _repository.watchAll()
      ..addListener(_onSessionsChanged);
    _sessions = _sessionListenable.value.values.toList(growable: false)
      ..sort(
        (ExerciseSession a, ExerciseSession b) =>
            b.startedAt.compareTo(a.startedAt),
      );
  }

  final SessionRepository _repository;
  late final ValueListenable<Box<ExerciseSession>> _sessionListenable;
  List<ExerciseSession> _sessions = <ExerciseSession>[];

  List<ExerciseSession> get sessions =>
      List<ExerciseSession>.unmodifiable(_sessions);

  List<ExerciseSession> sessionsForProfile(String profileId) => _sessions
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
    final ExerciseSession session = await _repository.recordSession(
      profileId: profileId,
      operation: operation,
      mode: mode,
      format: format,
      questions: questions,
      startedAt: startedAt,
      durationMillis: durationMillis,
      targetTable: targetTable,
      timedSeconds: timedSeconds,
    );
    return session;
  }

  Future<void> deleteSession(String id) => _repository.delete(id);

  Future<void> deleteSessionsForProfile(String profileId) =>
      _repository.deleteForProfile(profileId);

  void _onSessionsChanged() {
    _sessions = _sessionListenable.value.values.toList(growable: false)
      ..sort(
        (ExerciseSession a, ExerciseSession b) =>
            b.startedAt.compareTo(a.startedAt),
      );
    notifyListeners();
  }

  @override
  void dispose() {
    _sessionListenable.removeListener(_onSessionsChanged);
    super.dispose();
  }
}
