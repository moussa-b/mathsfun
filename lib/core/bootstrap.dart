import '../data/local/hive_initializer.dart';

/// Performs asynchronous initialisation required before the app renders.
Future<void> bootstrapApp() async {
  const HiveInitializer hiveInitializer = HiveInitializer();
  await hiveInitializer.init();
}
