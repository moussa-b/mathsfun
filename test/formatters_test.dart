import 'package:flutter_test/flutter_test.dart';

import 'package:mathsfun/core/utils/formatters.dart';

void main() {
  test('formatDuration formats seconds', () {
    expect(formatDuration(const Duration(seconds: 45)), '45s');
  });

  test('formatDuration formats minutes and seconds', () {
    expect(formatDuration(const Duration(minutes: 2, seconds: 5)), '2m 5s');
  });

  // protects=the download size shown on the voice tile and in parent
  // settings; fails_when=the unit or rounding is wrong for fr/en;
  // no_claim=none beyond protects.
  test('formatMegabytes rounds and localizes the unit', () {
    expect(formatMegabytes(71052319, 'fr'), '71 Mo');
    expect(formatMegabytes(71053214, 'en'), '71 MB');
  });

  // protects=per-question voice times on the results screen ('3,2 s' in
  // French); fails_when=the decimal separator ignores the locale;
  // no_claim=none beyond protects.
  test('formatSecondsOneDecimal uses the locale separator', () {
    expect(formatSecondsOneDecimal(3240, 'fr'), '3,2');
    expect(formatSecondsOneDecimal(3240, 'en'), '3.2');
  });
}
