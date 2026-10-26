import 'package:flutter/foundation.dart';

const String _kPublishedSpeechModelBaseUrl = 'https://models.bdzapps.com/asr';
const String _kSpeechModelBaseUrlOverride = String.fromEnvironment(
  'SPEECH_MODEL_BASE_URL',
);

/// Where the on-device speech recognition models are published (Cloudflare R2).
/// Debug builds may point elsewhere with `--dart-define=SPEECH_MODEL_BASE_URL=…`
/// (see `tool/serve_asr_models.sh`); release and profile builds never do.
String get kSpeechModelBaseUrl =>
    kDebugMode && _kSpeechModelBaseUrlOverride.isNotEmpty
    ? _kSpeechModelBaseUrlOverride
    : _kPublishedSpeechModelBaseUrl;

/// Manifest read by this app version. Its name carries the schema so a future
/// schema can be published next to it without breaking installed apps.
const String kSpeechModelManifest = 'manifest-v1.json';

/// Languages the voice exercise mode supports.
const List<String> kSpeechModelLanguages = <String>['fr', 'en'];

/// Model sizes shown before the manifest is fetched (sum of the published
/// files, measured on 2026-10-25).
const Map<String, int> kSpeechModelSizeBytes = <String, int>{
  'fr': 71052319,
  'en': 71053214,
};

/// Upper bound accepted for any single model file announced by the manifest.
const int kSpeechModelMaxFileBytes = 200 * 1000 * 1000;

/// Files every model version ships, in the order they are downloaded.
/// Keep in sync with the file loop of `tool/build_asr_models.sh`.
const List<String> kSpeechModelFiles = <String>[
  'encoder.onnx',
  'decoder.onnx',
  'joiner.onnx',
  'tokens.txt',
];

/// Text-to-speech locale used for each supported language.
const Map<String, String> kSpeechTtsLocales = <String, String>{
  'fr': 'fr-FR',
  'en': 'en-US',
};

/// Language of the voice mode for an app [languageCode]: `fr` or `en`.
String voiceLanguageFor(String languageCode) =>
    languageCode == 'fr' ? 'fr' : 'en';
