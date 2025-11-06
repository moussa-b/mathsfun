import 'package:flutter/material.dart';

import 'core/app.dart';
import 'core/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapApp();
  runApp(const MathsFunApp());
}
