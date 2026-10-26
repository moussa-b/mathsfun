import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mathsfun/core/bootstrap.dart';
import 'package:mathsfun/data/local/hive_boxes.dart';
import 'package:mathsfun/data/models/app_settings.dart';
import 'package:mathsfun/data/repositories/settings_repository.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await bootstrapApp();
  });

  // protects=the remembered revision table and exercise choices (tables,
  // difficulty, shuffle, per operation) survive an app restart, now that the
  // regenerated adapter writes fields 7-14;
  // fails_when=the adapter stops writing or reading one of these fields, or
  // maps it to the wrong index, so it comes back null or swapped;
  // no_claim=reading settings written by an older build (those fields were
  // never on disk); why_new=no test covered the AppSettings adapter;
  // seam=none.
  test('remembered exercise choices survive a restart', () async {
    final SettingsRepository settings = SettingsRepository();
    await settings.save(
      settings.current.copyWith(
        lastRevisionTableMultiplication: 7,
        lastRevisionTableAddition: 4,
        lastExerciseSelectedTablesMultiplication: <int>[2, 5],
        lastExerciseSelectedTablesAddition: <int>[3],
        lastExerciseDifficultyLevelMultiplication: 2,
        lastExerciseDifficultyLevelAddition: 1,
        lastExerciseShuffleQuestionsMultiplication: true,
        lastExerciseShuffleQuestionsAddition: false,
      ),
    );

    await Hive.box<AppSettings>(HiveBoxes.settings).close();
    await Hive.openBox<AppSettings>(HiveBoxes.settings);
    final AppSettings reread = SettingsRepository().current;

    expect(reread.lastRevisionTableMultiplication, 7);
    expect(reread.lastRevisionTableAddition, 4);
    expect(reread.lastExerciseSelectedTablesMultiplication, <int>[2, 5]);
    expect(reread.lastExerciseSelectedTablesAddition, <int>[3]);
    expect(reread.lastExerciseDifficultyLevelMultiplication, 2);
    expect(reread.lastExerciseDifficultyLevelAddition, 1);
    expect(reread.lastExerciseShuffleQuestionsMultiplication, isTrue);
    expect(reread.lastExerciseShuffleQuestionsAddition, isFalse);
  });
}
