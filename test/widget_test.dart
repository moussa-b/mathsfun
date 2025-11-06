// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:mathsfun/core/app.dart';
import 'package:mathsfun/core/bootstrap.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await bootstrapApp();
  });

  testWidgets('renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MathsFunApp());
    await tester.pump();

    expect(find.text('Loading MathsFun...'), findsOneWidget);

    // Let scheduled splash timers finish so tests do not leak pending timers.
    await tester.pump(const Duration(seconds: 2));
  });
}
