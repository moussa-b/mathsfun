/// Turns a speech recognizer transcript into the number the learner said.
///
/// Pure Dart, no Flutter dependency. Supports French (including the Belgian
/// and Swiss forms "septante", "huitante", "octante", "nonante") and English.
/// When several numbers appear, the last one wins, so "six fois sept
/// quarante-deux" yields 42.
///
/// Every accepted spelling of 0..999 is generated once per language into a
/// lookup table; the transcript is then matched from its end, longest
/// candidate first.
class SpokenNumberParser {
  const SpokenNumberParser();

  static const int maxValue = 999;
  static const int _maxWordsPerNumber = 7;

  static final RegExp _digitsOnly = RegExp(r'^\d+$');
  static final RegExp _separators = RegExp(r"[-'’]");
  static final RegExp _punctuation = RegExp(r'[^\p{L}\p{N}\s]', unicode: true);
  static final RegExp _spaces = RegExp(r'\s+');

  static final Map<String, int> _french = _buildTable(_frenchForms);
  static final Map<String, int> _english = _buildTable(_englishForms);

  /// Returns the last number found in [text], or `null` when there is none.
  /// [languageCode] is `fr` or `en`; anything else is treated as English.
  int? parse(String text, String languageCode) {
    final String normalized = text
        .toLowerCase()
        .replaceAll(_separators, ' ')
        .replaceAll(_punctuation, ' ')
        .trim();
    if (normalized.isEmpty) {
      return null;
    }

    final List<String> words = normalized.split(_spaces);
    // "oh" means zero only when it is the whole answer, never as a filler.
    if (languageCode != 'fr' && words.length == 1 && words.single == 'oh') {
      return 0;
    }
    final Map<String, int> table = languageCode == 'fr' ? _french : _english;
    // Walk back from the end: the first number found, in digits or in
    // words, is the last one said.
    for (int end = words.length; end > 0; end--) {
      final String last = words[end - 1];
      if (_digitsOnly.hasMatch(last)) {
        final int? value = int.tryParse(last);
        return value == null || value > maxValue ? null : value;
      }
      final int firstStart =
          end - _maxWordsPerNumber < 0 ? 0 : end - _maxWordsPerNumber;
      for (int start = firstStart; start < end; start++) {
        final int? value = table[words.sublist(start, end).join(' ')];
        if (value != null) {
          return value;
        }
      }
    }
    return null;
  }

  static Map<String, int> _buildTable(List<String> Function(int) formsOf) {
    final Map<String, int> table = <String, int>{};
    for (int n = 0; n <= maxValue; n++) {
      for (final String form in formsOf(n)) {
        table.putIfAbsent(form, () => n);
      }
    }
    return table;
  }

  static const List<String> _frenchUnits = <String>[
    'zéro', 'un', 'deux', 'trois', 'quatre', 'cinq', 'six', 'sept', 'huit',
    'neuf', 'dix', 'onze', 'douze', 'treize', 'quatorze', 'quinze', 'seize',
  ];

  static const Map<int, String> _frenchTens = <int, String>{
    20: 'vingt',
    30: 'trente',
    40: 'quarante',
    50: 'cinquante',
    60: 'soixante',
  };

  /// French spellings of 0..99, accents kept, hyphens already turned into
  /// spaces.
  static List<String> _frenchBelowHundred(int n) {
    if (n <= 16) {
      return n == 0 ? <String>['zéro', 'zero'] : <String>[_frenchUnits[n]];
    }
    if (n < 20) {
      return <String>['dix ${_frenchUnits[n - 10]}'];
    }
    final int tens = n ~/ 10 * 10;
    final int unit = n % 10;
    final List<String> forms = <String>[];

    if (tens <= 60) {
      forms.addAll(_withUnit(_frenchTens[tens]!, unit));
    } else if (tens == 70) {
      // soixante dix, soixante et onze, soixante douze...
      for (final String rest in _frenchBelowHundred(n - 60)) {
        forms.add('soixante $rest');
        if (unit == 1) {
          forms.add('soixante et $rest');
        }
      }
      forms.addAll(_withUnit('septante', unit));
    } else if (tens == 80) {
      forms.addAll(_quatreVingt(unit == 0 ? null : _frenchUnits[unit]));
      forms.addAll(_withUnit('huitante', unit));
      forms.addAll(_withUnit('octante', unit));
    } else {
      for (final String rest in _frenchBelowHundred(n - 80)) {
        forms.addAll(_quatreVingt(rest));
      }
      forms.addAll(_withUnit('nonante', unit));
    }
    return forms;
  }

  /// "vingt", "vingt et un", "vingt un", "vingt deux"...
  static List<String> _withUnit(String tens, int unit) {
    if (unit == 0) {
      return <String>[tens];
    }
    final String unitWord = _frenchUnits[unit];
    return unit == 1
        ? <String>['$tens et $unitWord', '$tens $unitWord']
        : <String>['$tens $unitWord'];
  }

  static List<String> _quatreVingt(String? rest) => rest == null
      ? <String>['quatre vingts', 'quatre vingt']
      : <String>['quatre vingt $rest', 'quatre vingts $rest'];

  static List<String> _frenchForms(int n) {
    if (n < 100) {
      return _frenchBelowHundred(n);
    }
    final int hundreds = n ~/ 100;
    final int rest = n % 100;
    final List<String> prefixes = hundreds == 1
        ? <String>['cent', 'un cent']
        : <String>[
            '${_frenchUnits[hundreds]} cent',
            if (rest == 0) '${_frenchUnits[hundreds]} cents',
          ];
    if (rest == 0) {
      return prefixes;
    }
    return <String>[
      for (final String prefix in prefixes)
        for (final String tail in _frenchBelowHundred(rest)) '$prefix $tail',
    ];
  }

  static const List<String> _englishUnits = <String>[
    'zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight',
    'nine', 'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen',
    'sixteen', 'seventeen', 'eighteen', 'nineteen',
  ];

  static const List<String> _englishTens = <String>[
    '', '', 'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy',
    'eighty', 'ninety',
  ];

  static List<String> _englishBelowHundred(int n) {
    if (n < 20) {
      return <String>[_englishUnits[n]];
    }
    final String tens = _englishTens[n ~/ 10];
    final int unit = n % 10;
    return <String>[unit == 0 ? tens : '$tens ${_englishUnits[unit]}'];
  }

  static List<String> _englishForms(int n) {
    if (n < 100) {
      return _englishBelowHundred(n);
    }
    final int hundreds = n ~/ 100;
    final int rest = n % 100;
    final List<String> prefixes = <String>[
      '${_englishUnits[hundreds]} hundred',
      if (hundreds == 1) 'a hundred',
      if (hundreds == 1) 'hundred',
    ];
    if (rest == 0) {
      return prefixes;
    }
    return <String>[
      for (final String prefix in prefixes)
        for (final String tail in _englishBelowHundred(rest)) ...<String>[
          '$prefix $tail',
          '$prefix and $tail',
        ],
    ];
  }
}
