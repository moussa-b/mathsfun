import 'package:flutter_test/flutter_test.dart';
import 'package:mathsfun/features/exercise/application/spoken_number_parser.dart';

// Hand-written spellings, independent from the parser's generator, the way a
// recognizer would transcribe them (hyphens included).
const List<String> _french0to99 = <String>[
  'zéro', 'un', 'deux', 'trois', 'quatre', 'cinq', 'six', 'sept', 'huit',
  'neuf', 'dix', 'onze', 'douze', 'treize', 'quatorze', 'quinze', 'seize',
  'dix-sept', 'dix-huit', 'dix-neuf', 'vingt', 'vingt et un', 'vingt-deux',
  'vingt-trois', 'vingt-quatre', 'vingt-cinq', 'vingt-six', 'vingt-sept',
  'vingt-huit', 'vingt-neuf', 'trente', 'trente et un', 'trente-deux',
  'trente-trois', 'trente-quatre', 'trente-cinq', 'trente-six',
  'trente-sept', 'trente-huit', 'trente-neuf', 'quarante', 'quarante et un',
  'quarante-deux', 'quarante-trois', 'quarante-quatre', 'quarante-cinq',
  'quarante-six', 'quarante-sept', 'quarante-huit', 'quarante-neuf',
  'cinquante', 'cinquante et un', 'cinquante-deux', 'cinquante-trois',
  'cinquante-quatre', 'cinquante-cinq', 'cinquante-six', 'cinquante-sept',
  'cinquante-huit', 'cinquante-neuf', 'soixante', 'soixante et un',
  'soixante-deux', 'soixante-trois', 'soixante-quatre', 'soixante-cinq',
  'soixante-six', 'soixante-sept', 'soixante-huit', 'soixante-neuf',
  'soixante-dix', 'soixante et onze', 'soixante-douze', 'soixante-treize',
  'soixante-quatorze', 'soixante-quinze', 'soixante-seize',
  'soixante-dix-sept', 'soixante-dix-huit', 'soixante-dix-neuf',
  'quatre-vingts', 'quatre-vingt-un', 'quatre-vingt-deux',
  'quatre-vingt-trois', 'quatre-vingt-quatre', 'quatre-vingt-cinq',
  'quatre-vingt-six', 'quatre-vingt-sept', 'quatre-vingt-huit',
  'quatre-vingt-neuf', 'quatre-vingt-dix', 'quatre-vingt-onze',
  'quatre-vingt-douze', 'quatre-vingt-treize', 'quatre-vingt-quatorze',
  'quatre-vingt-quinze', 'quatre-vingt-seize', 'quatre-vingt-dix-sept',
  'quatre-vingt-dix-huit', 'quatre-vingt-dix-neuf',
];

const List<String> _english0to99 = <String>[
  'zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight',
  'nine', 'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen',
  'sixteen', 'seventeen', 'eighteen', 'nineteen', 'twenty', 'twenty-one',
  'twenty-two', 'twenty-three', 'twenty-four', 'twenty-five', 'twenty-six',
  'twenty-seven', 'twenty-eight', 'twenty-nine', 'thirty', 'thirty-one',
  'thirty-two', 'thirty-three', 'thirty-four', 'thirty-five', 'thirty-six',
  'thirty-seven', 'thirty-eight', 'thirty-nine', 'forty', 'forty-one',
  'forty-two', 'forty-three', 'forty-four', 'forty-five', 'forty-six',
  'forty-seven', 'forty-eight', 'forty-nine', 'fifty', 'fifty-one',
  'fifty-two', 'fifty-three', 'fifty-four', 'fifty-five', 'fifty-six',
  'fifty-seven', 'fifty-eight', 'fifty-nine', 'sixty', 'sixty-one',
  'sixty-two', 'sixty-three', 'sixty-four', 'sixty-five', 'sixty-six',
  'sixty-seven', 'sixty-eight', 'sixty-nine', 'seventy', 'seventy-one',
  'seventy-two', 'seventy-three', 'seventy-four', 'seventy-five',
  'seventy-six', 'seventy-seven', 'seventy-eight', 'seventy-nine', 'eighty',
  'eighty-one', 'eighty-two', 'eighty-three', 'eighty-four', 'eighty-five',
  'eighty-six', 'eighty-seven', 'eighty-eight', 'eighty-nine', 'ninety',
  'ninety-one', 'ninety-two', 'ninety-three', 'ninety-four', 'ninety-five',
  'ninety-six', 'ninety-seven', 'ninety-eight', 'ninety-nine',
];

String _frenchSpelling(int n) =>
    n < 100 ? _french0to99[n] : (n == 100 ? 'cent' : 'cent ${_french0to99[n - 100]}');

String _englishSpelling(int n) => n < 100
    ? _english0to99[n]
    : (n == 100
        ? 'one hundred'
        : 'one hundred and ${_english0to99[n - 100]}');

void main() {
  const SpokenNumberParser parser = SpokenNumberParser();

  // protects=every answer the app can expect (0..144) is understood in French;
  // fails_when=any spelling maps to the wrong value or to null;
  // no_claim=what the recognizer actually transcribes for a child's voice.
  test('parses every French spelling from 0 to 144', () {
    for (int n = 0; n <= 144; n++) {
      expect(parser.parse(_frenchSpelling(n), 'fr'), n,
          reason: _frenchSpelling(n));
    }
  });

  // protects=same as above for English; fails_when=wrong value or null;
  // no_claim=recognizer output on real audio.
  test('parses every English spelling from 0 to 144', () {
    for (int n = 0; n <= 144; n++) {
      expect(parser.parse(_englishSpelling(n), 'en'), n,
          reason: _englishSpelling(n));
    }
  });

  // protects=recognizers that emit digits; fails_when=digits are ignored or
  // the wrong number in the sentence is kept; no_claim=none beyond protects.
  test('parses digits and keeps the last number', () {
    for (int n = 0; n <= 144; n++) {
      expect(parser.parse('$n', 'fr'), n);
      expect(parser.parse('$n', 'en'), n);
    }
    expect(parser.parse('6 fois 7 = 42', 'fr'), 42);
    expect(parser.parse('1000', 'fr'), isNull);
  });

  // protects=a child who repeats the operation before answering;
  // fails_when=operands are merged into the answer (e.g. 49 instead of 42);
  // no_claim=none beyond protects.
  test('keeps the last number of a sentence', () {
    expect(parser.parse('six fois sept quarante-deux', 'fr'), 42);
    expect(parser.parse('euh quarante deux', 'fr'), 42);
    expect(parser.parse('sept plus huit ça fait quinze', 'fr'), 15);
    expect(parser.parse('six times seven is forty two', 'en'), 42);
    expect(parser.parse('cent quarante-quatre voilà', 'fr'), 144);
  });

  // protects=Belgian/Swiss forms and spelling variants; fails_when=one of
  // them is rejected; no_claim=none beyond protects.
  test('accepts regional and variant forms', () {
    expect(parser.parse('septante-deux', 'fr'), 72);
    expect(parser.parse('huitante', 'fr'), 80);
    expect(parser.parse('octante-quatre', 'fr'), 84);
    expect(parser.parse('nonante-neuf', 'fr'), 99);
    expect(parser.parse('quatre vingt', 'fr'), 80);
    expect(parser.parse('vingt un', 'fr'), 21);
    expect(parser.parse('Quarante-Deux.', 'fr'), 42);
    expect(parser.parse('a hundred and twelve', 'en'), 112);
    expect(parser.parse('oh', 'en'), 0);
  });

  // protects=unintelligible answers trigger a retry instead of a wrong
  // answer; fails_when=noise is parsed as a number; no_claim=none.
  test('returns null when no number is said', () {
    for (final String text in <String>['', '   ', 'euh', 'je sais pas', 'banane']) {
      expect(parser.parse(text, 'fr'), isNull, reason: text);
    }
    expect(parser.parse("I don't know", 'en'), isNull);
  });

  // protects=transcripts mixing digits and words keep the last number said;
  // fails_when=a digit earlier in the sentence wins over the spoken answer
  // ('6 fois 7 ça fait quarante-deux' read as 7); no_claim=none beyond
  // protects; why_new=testing specialist finding (digits short-circuited).
  test('mixed digits and words keep the last number', () {
    expect(parser.parse('6 fois 7 ça fait quarante-deux', 'fr'), 42);
    expect(parser.parse('six times 7 is forty two', 'en'), 42);
    expect(parser.parse('quarante-deux non 43', 'fr'), 43);
  });

  // protects=a filler 'oh' never turns an English answer into 0;
  // fails_when='forty two oh' is read as 0; no_claim=none.
  test("'oh' is zero only as the whole answer", () {
    expect(parser.parse('forty two oh', 'en'), 42);
    expect(parser.parse('oh', 'en'), 0);
    expect(parser.parse('oh forty', 'en'), 40);
  });
}

