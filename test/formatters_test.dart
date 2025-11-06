import 'package:flutter_test/flutter_test.dart';

import 'package:mathsfun/core/utils/formatters.dart';

void main() {
  test('formatDuration formats seconds', () {
    expect(formatDuration(const Duration(seconds: 45)), '45s');
  });

  test('formatDuration formats minutes and seconds', () {
    expect(formatDuration(const Duration(minutes: 2, seconds: 5)), '2m 5s');
  });
}
