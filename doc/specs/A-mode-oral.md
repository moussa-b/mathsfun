---
spec_id: A
spec_filed_at: 2026-10-25T09:33:30Z
spec_branch: main
spec_quality_gate: 8/10 (cursor-agent, 2026-10-25)
---

# Mode d'exercice « Oral » : l'app lit l'opération, écoute la réponse, corrige et chronomètre (100 % hors ligne)

## Contexte

Aujourd'hui l'enfant répond en touchant l'écran (QCM) ou en tapant un nombre (saisie directe, défi chrono). Il n'existe aucun moyen de travailler le calcul mental « à l'oral », alors que c'est la façon dont on interroge les tables en classe. Ce mode ajoute un 4ᵉ format où l'app lit l'opération à voix haute, écoute la réponse de l'enfant, dit si c'est juste ou faux, et enregistre la session comme les autres formats (durée totale + temps par question).

Contrainte produit : **aucune API LLM, aucun envoi de la voix de l'enfant**. La reconnaissance se fait sur l'appareil avec un modèle téléchargé une fois après installation, pour ne pas alourdir le bundle.

## État actuel (vérifié le 2026-10-25, branche `main`, v1.2.0+3)

| Élément | Où | Constat |
|---|---|---|
| Formats d'exercice | `lib/data/models/exercise_metadata.dart:42-58` | `ExerciseFormat { multipleChoice(0), directInput(1), timedChallenge(2) }`, Hive `typeId: 4` |
| Adaptateur Hive | `lib/data/models/exercise_metadata.g.dart:92-103` | index inconnu → `multipleChoice` (rollback sans crash) |
| Choix du format | `lib/features/exercise/presentation/exercise_mode_type_selection_screen.dart:236-287` | 3 tuiles `_ExerciseTypeTile` |
| Contrôleur | `lib/features/exercise/application/exercise_controller.dart` | calcule `responseMillis` par question (l.95), `durationMillis` session (l.171), timer par question selon difficulté (l.34, l.158) |
| Persistance | `lib/data/models/exercise_session.dart` | `QuestionResult.responseMillis` existe déjà, `ExerciseSession.durationMillis` aussi |
| Résultats | `lib/features/results/presentation/results_screen.dart:104` | durée totale affichée ; la liste des questions (l.118-140) **n'affiche pas** le temps par question |
| `switch` exhaustifs sur `ExerciseFormat` | `results_screen.dart:186`, `statistics_screen.dart:98` | casseront la compilation à l'ajout de la valeur, c'est voulu |
| Routes | `lib/core/routes/app_router.dart:26-41` | pas de route vocale |
| Permissions | `ios/Runner/Info.plist`, `android/app/src/main/AndroidManifest.xml` | pas de `NSMicrophoneUsageDescription`, pas de `RECORD_AUDIO` ; `INTERNET` présent |
| Localisation iOS | `ios/Runner/` | seulement `Base.lproj`, pas de `fr.lproj/InfoPlist.strings` |
| Dépendances | `pubspec.yaml` | `crypto` et `path_provider` déjà là ; pas de TTS, micro ni ASR |
| Réseau | n/a | l'app ne fait **aucun** appel réseau aujourd'hui |

Plage des réponses : multiplication jusqu'à 12 × 12 = 144, addition jusqu'à 12 + 10 = 22 (`question_generator.dart:113-120`).

Le réglage `AppSettings.soundEnabled` existe, mais **aucun écran ne le modifie et aucun code ne le lit**. Seul `settings_service.dart:29` l'écrit. Le mode Oral l'ignore donc (voir §3). Le parseur doit couvrir **0 à 144**.

## Choix techniques (décidés)

| Brique | Choix | Version vérifiée sur pub.dev |
|---|---|---|
| Lecture à voix haute | `flutter_tts` (moteur TTS du système, hors ligne) | 4.2.5 |
| Capture micro | `record` (flux PCM 16 kHz mono 16 bits) | 7.1.2 |
| Reconnaissance | `sherpa_onnx`, `OnlineRecognizer` en streaming avec détection de fin de parole | 2.0.0 (23/10/2026) |
| Interprétation | parseur maison mots → nombre (fr/en), aucun LLM | n/a |

Écartés : `vosk_flutter` (pas d'iOS, abandonné en 2023), `speech_to_text` (packs de langue gérés par l'OS, pas embarquables, Android peut basculer sur le serveur Google).

### Modèles (tailles mesurées le 2026-10-25 en listant les archives k2-fsa)

| Langue | Modèle k2-fsa retenu | Fichiers à héberger | Taille | Licence |
|---|---|---|---|---|
| fr | `sherpa-onnx-streaming-zipformer-fr-kroko-2025-08-06` | encoder 70,1 Mo + decoder 0,62 Mo + joiner 0,34 Mo + tokens.txt | **≈ 71 Mo** | CC-BY-SA (modèle « Community » de Banafo/Kroko) : attribution obligatoire, voir §9 |
| en | `sherpa-onnx-streaming-zipformer-en-kroko-2025-08-06` | encoder 70,1 Mo + decoder 0,62 Mo + joiner 0,34 Mo + tokens.txt | **≈ 71 Mo** | CC-BY-SA (Kroko « Community »), même mention de crédit |

On télécharge uniquement la langue de l'interface.

Modèles écartés pour le français (mesurés le 2026-10-25) : `zipformer-fr-2023-04-14` int8 ≈ 128 Mo, `nemo-fast-conformer-ctc-en-de-es-fr` int8 ≈ 132 Mo, Whisper tiny ≈ 110 Mo (archive) et non streaming.

**Plan B sans nouvelle version de l'app.** Kroko et le modèle de 2023 ont la même architecture (transducer zipformer en streaming) et les mêmes noms de fichiers (`encoder/decoder/joiner.onnx`, `tokens.txt`). Si Kroko échoue au critère 20, on publie le modèle 2023 en `fr/v2` et on met à jour `manifest-v1.json`. Les apps déjà installées voient la nouvelle version au lancement suivant (si aucun exercice n'utilise le modèle), suppriment `v1` et téléchargent `v2`.

**Licence Kroko à confirmer.** La fiche Hugging Face de Banafo annonce « CC-BY-SA licensed community models », mais je n'ai pas pu lire le fichier `LICENSE` (réponse vide). Le script `tool/build.sh` (`../mathsfun-models`) doit copier le `README.md` de l’archive dans `public/asr/fr/v1/LICENSE.txt`, et Moussa doit valider la licence avant de publier. On utilise le modèle tel quel, sans quantification ni réentraînement, pour éviter que la clause « ShareAlike » ne s'applique.

## Changement proposé

```
[Tuile « Oral »] ──modèle absent──> SpeechModelService.download(lang)  (tuile désactivée + barre %)
        │                                   │ manifest.json → fichiers → SHA-256 → rename atomique
        └──modèle prêt──> /exercise/voice ──> VoiceExerciseScreen
                                                 │
            ┌────────────────────────────────────┘
            v
  TTS lit « 6 fois 7 » ─fin─> micro ON + sherpa streaming ─fin de parole─> SpokenNumberParser
            ^                                                          │
            │ « Je n'ai pas compris, répète »  <── null ─────────────────┤
            │                                                          │ nombre
            └── question suivante <── TTS « Bravo ! » / « Non, c'était 42 » <── controller.submitDirectAnswer(n)
```

### 1. Hébergement des modèles (VPS Coolify)

- nginx sur le VPS Coolify de Moussa, domaine `mathsfun-models.bdzapps.com` (DNS chez OVH). R2 écarté le 2026-10-26 : un domaine personnalisé R2 exige que la zone DNS soit chez Cloudflare.
- L'app vérifie au plus 5 s si le serveur publie le modèle ; sans modèle sur l'appareil et sans réponse, la tuile Oral est masquée.
- Arborescence :
  ```
  asr/manifest-v1.json
  asr/fr/v1/encoder.onnx  decoder.onnx  joiner.onnx  tokens.txt  LICENSE.txt
  asr/en/v1/encoder.onnx  decoder.onnx  joiner.onnx  tokens.txt  LICENSE.txt
  ```
- `manifest.json` :
  ```json
  {
    "schema": 1,
    "languages": {
      "fr": {
        "version": "v1",
        "model": "sherpa-onnx-streaming-zipformer-fr-kroko-2025-08-06",
        "files": [
          {"name": "encoder.onnx", "size": 70092599, "sha256": "…"},
          {"name": "decoder.onnx", "size": 617488, "sha256": "…"},
          {"name": "joiner.onnx", "size": 336817, "sha256": "…"},
          {"name": "tokens.txt", "size": 5415, "sha256": "…"}
        ]
      },
      "en": { "version": "v1", "model": "sherpa-onnx-streaming-zipformer-en-kroko-2025-08-06", "files": [ … ] }
    }
  }
  ```
- Script `scripts/build.sh` du projet séparé `../mathsfun-models` (sorti de l'app le 2026-10-26) : télécharge les 2 archives k2-fsa, extrait pour le français les fichiers Kroko tels quels et pour l'anglais les fichiers `*.int8.onnx`, plus `tokens.txt`, en les renommant comme ci-dessus, calcule les SHA-256 et génère `build/asr/` (manifest compris), prêt à être envoyé avec `wrangler r2 object put` (commande affichée, pas exécutée).
- URL de base en constante : `lib/core/constants/speech_constants.dart` → `const String kSpeechModelBaseUrl = 'https://mathsfun-models.bdzapps.com/asr';`

### 2. `SpeechModelService` (nouveau, `lib/data/services/speech_model_service.dart`)

`ChangeNotifier` enregistré dans `lib/core/app.dart` à côté des autres services, pour que le téléchargement continue même si l'enfant quitte l'écran.

```dart
SpeechModelService({
  HttpClient Function()? httpClientFactory,           // défaut : () => HttpClient() ; remplacé dans les tests
  Future<Directory> Function()? baseDirectoryProvider, // défaut : getApplicationCacheDirectory ; dossier temporaire en test
  String baseUrl = kSpeechModelBaseUrl,
});

enum SpeechModelStatus { absent, downloading, ready, error }

class SpeechModelState {
  final SpeechModelStatus status;
  final double progress;          // 0..1, valable si downloading
  final int? totalBytes;          // taille annoncée par le manifest
  final String? errorMessage;
}

SpeechModelState stateFor(String lang);                // 'fr' | 'en'
Future<void> refresh(String lang);                     // vérifie la présence des fichiers sur disque (pas de réseau)
Future<void> checkForUpdate(String lang);              // best effort, voir « Manifest » ci-dessous
Future<void> download(String lang);                    // ne fait rien si déjà downloading/ready
Future<void> delete(String lang);
Future<int> installedBytes();                          // pour les réglages parent
String modelDir(String lang);
```

- Stockage : `getApplicationCacheDirectory()/asr/<lang>/<version>/`. On utilise le dossier **Caches**, et pas Application Support, parce qu'Apple exige que les données re-téléchargeables ne soient pas sauvegardées dans iCloud (règle 2.23, motif de rejet). L'OS peut vider ce dossier quand le stockage manque. On revérifie donc la présence des fichiers à chaque tap sur la tuile (`refresh`), et la tuile repasse en « absent » si besoin.
- Téléchargement avec `HttpClient` de `dart:io` (pas de nouvelle dépendance). Chaque fichier va dans `<name>.part`. On vérifie la taille et le SHA-256 (`crypto`), puis on renomme. Le modèle est « prêt » quand les 4 fichiers sont présents avec la bonne taille, et que le fichier `<lang>/<version>/.complete` est écrit en dernier.
- **Manifest.** Il n'est jamais mis en cache. `download(lang)` télécharge `manifest.json` au début de chaque téléchargement. `checkForUpdate(lang)` est appelé à l'ouverture de l'écran de choix du format, seulement si le modèle est `ready`, avec un timeout de 3 s. Tout échec (hors ligne, timeout, JSON invalide) est ignoré sans rien afficher. Si la `version` du manifest diffère de celle écrite dans `.complete`, l'ancien dossier est supprimé et le statut passe à `absent`. L'utilisateur retélécharge alors au prochain tap.
- **Tailles avant téléchargement.** La tuile affiche les constantes de `speech_constants.dart` : `kSpeechModelSizeBytes = {'fr': 71052319, 'en': 43649301}` (somme des fichiers mesurés). La barre de progression utilise ensuite les `size` du manifest.
- La progression est calculée sur la somme des octets reçus / somme des `size` du manifest, avec `notifyListeners()` au plus toutes les 250 ms.
- Les erreurs (réseau, HTTP ≠ 200, SHA différent, disque plein) font passer le statut à `error`, suppriment les `.part`, et un nouveau tap relance le téléchargement depuis zéro. Pas de reprise partielle (hors périmètre).
- App tuée pendant le téléchargement : au prochain lancement, `refresh` trouve des `.part` sans `.complete`, les supprime et repasse en `absent`.

### 3. Tuile « Oral » dans `exercise_mode_type_selection_screen.dart`

Une 4ᵉ `_ExerciseTypeTile` sous le défi chrono, avec l'icône `Icons.record_voice_over` et une couleur `Colors.orange`.

| État | Rendu de la tuile | Tap |
|---|---|---|
| TTS indisponible pour la langue (`flutter_tts.isLanguageAvailable`) | grisée, « Voix {langue} indisponible sur cet appareil » | rien |
| `absent` | description + « Téléchargement requis (71 Mo) » ou « (71 MB) » (taille selon la langue, lue dans le manifest ou en constante de secours) | lance `download(lang)` |
| `downloading` | désactivée, `LinearProgressIndicator(value: progress)` + « 37 % » | rien |
| `error` | message d'erreur + « Touche pour réessayer » | relance `download` |
| `ready` | normale | demande le micro, puis `context.push(AppRoutePath.exerciseVoice, extra: config)` |

- Langue = locale effective de l'app (`Localizations.localeOf(context).languageCode`, ramenée à `fr` ou `en`, `en` par défaut).
- Pas de code parent pour le téléchargement (décision produit).
- Le réglage Son n'est pas pris en compte, puisqu'il n'a pas d'interface aujourd'hui (voir État actuel). Si un interrupteur Son est ajouté un jour, la tuile Oral devra être grisée quand il est coupé. Ce sera dans une issue séparée.
- Permission micro : on utilise `AudioRecorder().hasPermission()` du package `record`, qui affiche la demande système au premier appel. Pas de `permission_handler`. Si la réponse est `false`, SnackBar « Autorise le micro dans les réglages pour utiliser ce mode » et on reste sur l'écran. Le même message s'affiche à chaque tap tant que l'accès est refusé.
- Config passée : `format: ExerciseFormat.voice`, `questionCount: 12`, tables, mélange et difficulté comme les autres tuiles.

### 4. Modèle de données

- `exercise_metadata.dart` : ajout de `@HiveField(3) voice` dans `ExerciseFormat`, `label => 'Voice'`, puis régénération avec `dart run build_runner build --delete-conflicting-outputs`.
- `ExerciseFormat.voice.isTimed == false`.
- Aucun nouveau champ Hive. `durationMillis` et `responseMillis` sont réutilisés.

### 5. `ExerciseController` (modifs minimes)

- Le timer par question (difficulté moyenne 15 s, difficile 7 s) **n'est pas démarré** quand `config.format == ExerciseFormat.voice`, ni dans le constructeur (l.34) ni dans `_recordAnswer` (l.120).
- Nouvelle méthode `void markQuestionPresented()` qui remet `_questionStart = DateTime.now()`. L'écran vocal l'appelle **à la fin de la première lecture TTS** de chaque opération. `responseMillis` = de la fin de la première lecture jusqu'au nombre accepté, en incluant les « répète » et les « réécouter ». Le feedback TTS « Bravo » / « Non, c'était… » est exclu, car il a lieu après l'enregistrement.
- `durationMillis` reste inchangé : de l'ouverture de l'écran à la fin, lecture TTS et répétitions comprises.
- Réponse via `submitDirectAnswer(int)`, déjà existante.

### 6. `VoiceExerciseScreen` (nouveau, `lib/features/exercise/presentation/voice_exercise_screen.dart`) + route

- Route `AppRoutePath.exerciseVoice = '/exercise/voice'` dans `app_router.dart`, même construction que `exerciseDirectInput`.
- UI : même en-tête et progression que `direct_input_exercise_screen.dart`, l'opération en grand, un indicateur d'état (« J'écoute… » avec une icône micro animée / « Je parle… »), le nombre reconnu affiché une fois accepté, un bouton **« Réécouter »** (`Icons.replay`) et le bouton de sortie existant.
- Machine à états par question : `speakingQuestion → listening → (speakingRetry → listening)* → speakingFeedback → question suivante`.
  - Le micro est **coupé pendant toute lecture TTS** (pour que l'app ne s'entende pas elle-même).
  - `listening` : flux `record` → `OnlineStream.acceptWaveform` → `isEndpoint` (règles par défaut de sherpa : 2,4 s de silence sans parole, 1,2 s de silence après parole, 20 s maximum) → texte final.
  - Texte final → `SpokenNumberParser.parse(text, lang)` :
    - `null` (rien, bruit, « euh ») : TTS « Je n'ai pas compris, répète s'il te plaît » / « I didn't catch that, please say it again », puis on réécoute. **Sans limite** (décision produit).
    - nombre `n` : `submitDirectAnswer(n)`. Juste : TTS « Bravo ! » / « Well done! ». Faux : « Non, c'était {answer} » / « No, it was {answer} ». Puis question suivante.
  - « Réécouter » : coupe le micro, relit l'opération et réécoute. Le chrono de la question **n'est pas** remis à zéro.
  - Fin : même navigation vers `/results` que la saisie directe (`completeAndPersist`).
- Contrat moteur (`voice_engine.dart`, implémentation réelle). Les noms viennent de l'API Dart de `sherpa_onnx`. Les vérifier contre `flutter-examples/streaming_asr` du dépôt k2-fsa avant de coder :
  ```dart
  sherpa.initBindings();                                   // une fois, avant tout usage
  final recognizer = sherpa.OnlineRecognizer(sherpa.OnlineRecognizerConfig(
    model: sherpa.OnlineModelConfig(
      transducer: sherpa.OnlineTransducerModelConfig(
        encoder: '$dir/encoder.onnx', decoder: '$dir/decoder.onnx', joiner: '$dir/joiner.onnx'),
      tokens: '$dir/tokens.txt',
      numThreads: 2,
      modelType: '',                                       // laissé vide : lu dans les métadonnées du modèle
    ),
    enableEndpoint: true,
    rule1MinTrailingSilence: 2.4,
    rule2MinTrailingSilence: 1.2,
    rule3MinUtteranceLength: 20,
    decodingMethod: 'greedy_search',
  ));
  final stream = recognizer.createStream();
  // record : PCM 16 bits little-endian, 16 kHz, mono
  final audio = await AudioRecorder().startStream(const RecordConfig(
    encoder: AudioEncoder.pcm16bits, sampleRate: 16000, numChannels: 1));
  audio.listen((Uint8List bytes) {
    final Float32List samples = int16LeToFloat32(bytes);   // échantillon / 32768.0
    stream.acceptWaveform(samples: samples, sampleRate: 16000);
    while (recognizer.isReady(stream)) { recognizer.decode(stream); }
    if (recognizer.isEndpoint(stream)) {
      final String text = recognizer.getResult(stream).text;
      recognizer.reset(stream);
      onFinalText(text);                                   // → SpokenNumberParser
    }
  });
  ```
  `int16LeToFloat32` est une fonction pure dans `voice_engine.dart`, avec un test unitaire.
- Texte lu par le TTS (nouvelles clés ARB) : `voiceReadMultiplication` « {a} fois {b} » / « {a} times {b} », `voiceReadAddition` « {a} plus {b} » / « {a} plus {b} ». Le TTS est réglé sur `fr-FR` ou `en-US` selon la langue.
- `dispose` : arrêt du TTS, du micro et libération du recognizer.

### 7. `SpokenNumberParser` (nouveau, `lib/features/exercise/application/spoken_number_parser.dart`)

Fonction pure, sans dépendance Flutter : `int? parse(String text, String lang)`.

- Normalisation : minuscules, accents conservés, tirets et apostrophes remplacés par des espaces, suppression de la ponctuation.
- Si le texte contient des chiffres (`\d+`), on prend **le dernier** nombre en chiffres.
- Sinon, on découpe en mots et on cherche **le dernier groupe de mots-nombres consécutifs** (ex. « six fois sept quarante deux » → 42 ; « euh quarante deux » → 42).
- Français : zéro…seize, dix-sept/dix-huit/dix-neuf, vingt…soixante, « et un », soixante-dix (70-79), quatre-vingt(s) (80), quatre-vingt-dix (90-99), cent, cent N. Variantes belges et suisses acceptées : septante, huitante, octante, nonante.
- Anglais : zero/oh, one…nineteen, twenty…ninety, hundred, « and » toléré (« one hundred and twelve »).
- Résultat hors 0..999 : `null`.

### 8. Résultats : temps par question

- `results_screen.dart` : pour les sessions `format == voice`, le `trailing` de chaque ligne affiche la réponse et le temps, par exemple « 42 · 3,2 s » (nouvelle clé ARB `resultsResponseTime` avec un `double` en 1 décimale, selon la locale).
- `_replay` (l.186) : `case ExerciseFormat.voice:` → `context.push(AppRoutePath.exerciseVoice, extra: config)`.
- `statistics_screen.dart:98` : `case ExerciseFormat.voice:` → `statisticsFormatVoice` (« Oral » / « Voice »).

### 9. Réglages parent : `lib/features/profile/widgets/parent_settings_sheet.dart`

- Ligne « Modèles vocaux » qui affiche la taille installée (`installedBytes`, en Mo), et un bouton « Supprimer » qui appelle `delete` sur les deux langues, avec confirmation. La ligne est masquée s'il n'y a rien d'installé.
- Mention de crédit, **toujours visible** (exigée par CC-BY-SA) : « Reconnaissance vocale : sherpa-onnx (k2-fsa, Apache-2.0) · modèle français Kroko ASR (Banafo, CC-BY-SA) », avec un lien vers `https://huggingface.co/Banafo/Kroko-ASR`. Nouvelle clé ARB `parentSettingsVoiceCredits`.

### 10. Permissions et plateformes

- iOS `Info.plist` : `NSMicrophoneUsageDescription` = « MathsFun écoute la réponse de ton enfant pour la corriger. La voix est analysée sur l'appareil et n'est jamais envoyée. » (en anglais dans `Base`). Nouveau `ios/Runner/fr.lproj/InfoPlist.strings` pour la version française, à ajouter à la cible Runner.
- Android `AndroidManifest.xml` : `<uses-permission android:name="android.permission.RECORD_AUDIO"/>`.
- Session audio iOS (lecture + enregistrement) : catégorie `playAndRecord` avec `defaultToSpeaker`, configurée via `flutter_tts.setIosAudioCategory`, pour que le TTS sorte sur le haut-parleur et pas l'écouteur.

### 11. L10n (`lib/l10n/app_fr.arb` + `app_en.arb`)

Nouvelles clés (fr/en) : `exerciseVoiceTitle`, `exerciseVoiceDescription`, `exerciseVoiceDownloadRequired(size)`, `exerciseVoiceDownloading(percent)`, `exerciseVoiceDownloadError`, `exerciseVoiceTtsUnavailable(language)`, `exerciseVoiceMicDenied`, `parentSettingsVoiceCredits`, `voiceListening`, `voiceSpeaking`, `voiceReplay`, `voiceReadMultiplication(a,b)`, `voiceReadAddition(a,b)`, `voiceRetry`, `voiceCorrect`, `voiceIncorrect(answer)`, `resultsResponseTime(seconds)`, `statisticsFormatVoice`, `parentSettingsVoiceModels(size)`, `parentSettingsVoiceModelsDelete`, `parentSettingsVoiceModelsDeleteConfirm`.

## Prérequis hors code (Moussa)

1. Créer le service nginx sur Coolify pour `mathsfun-models.bdzapps.com` (A chez OVH), puis y envoyer `public/asr/` généré par `../mathsfun-models/scripts/build.sh`.
2. Valider la licence Kroko (CC-BY-SA) pour un usage dans l'app.

## Checklist de fin de déploiement (OBLIGATOIRE dans le rapport final)

Le rapport final de l'implémentation, et le rapport de `/ship` ou `/land-and-deploy` pour cette fonctionnalité, **se terminent par ce bloc, mot pour mot**, adressé à Moussa :

> ⚠️ **Actions à faire avant de soumettre la version aux stores :**
> 1. Mettre à jour la politique de confidentialité `https://bdzapps.com/mathsfun/privacy/` : usage du micro, voix analysée uniquement sur l'appareil et jamais envoyée, téléchargement d'un modèle vocal depuis `models.bdzapps.com` (Cloudflare).
> 2. Mettre à jour le site web de MathsFun (`bdzapps.com/mathsfun/`) : présenter le nouveau mode Oral.
> 3. App Store Connect → App Privacy : « Audio Data » = non collecté (traité sur l'appareil, rien d'envoyé).
> 4. Google Play Console → Data safety : même déclaration pour l'audio.
> 5. Fiches App Store et Play (`appstore/`, `playstore/`) : ajouter le mode Oral à la description et aux captures si besoin.

## Critères d'acceptation

1. Sur l'écran de choix du format, une 4ᵉ tuile « Oral » / « Voice » apparaît pour l'addition **et** la multiplication.
2. Modèle absent : un tap lance le téléchargement. La tuile affiche ensuite une barre et un pourcentage qui augmente, et **aucun tap** ne mène à `/exercise/voice` tant que le statut n'est pas `ready`.
3. Après un téléchargement réussi, les 4 fichiers sont dans `<Caches>/asr/<lang>/v1/` avec le SHA-256 du manifest, plus `.complete`. Aucun fichier `.part` ne reste.
4. Un fichier dont le SHA-256 ne correspond pas fait passer le statut à `error`. Le modèle n'est pas marqué prêt et les fichiers partiels sont supprimés.
5. Fichiers supprimés à la main (ou cache vidé), le tap suivant ramène la tuile à l'état « téléchargement requis », sans crash.
6. Mode avion avec un modèle prêt : une session orale complète de 12 questions se déroule et s'enregistre (preuve qu'il n'y a aucune dépendance réseau à l'usage).
7. `SpokenNumberParser.parse` renvoie le bon entier pour **chaque** valeur de 0 à 144 écrite en toutes lettres en français et en anglais (290 cas), pour les mêmes valeurs en chiffres, et renvoie `null` pour « », « euh », « je sais pas », « banane ».
8. Le micro n'est jamais actif pendant qu'une phrase TTS est lue (vérifié par l'état de la machine dans un test du contrôleur d'écran : `isRecording == false` dans `speakingQuestion`, `speakingRetry` et `speakingFeedback`).
9. Réponse non comprise : l'app dit la phrase « répète » et réécoute, sans compter faux ni passer à la question suivante.
10. Nombre faux compris : l'app dit « Non, c'était {answer} », la question est enregistrée `isCorrect == false` avec `userAnswer == n`, puis on passe à la suivante.
11. En difficulté moyenne ou difficile, aucune question orale n'expire (pas de timer par question).
12. La session enregistrée a `format == ExerciseFormat.voice`, un `durationMillis` > 0, et chaque `QuestionResult.responseMillis` mesure le temps entre la fin de la première lecture et le nombre accepté.
13. L'écran de résultats d'une session orale affiche le temps par question (« · 3,2 s ») ; les autres formats ne changent pas.
14. Les statistiques affichent « Oral » / « Voice » pour ces sessions ; « Rejouer » relance une session orale.
15. Si la `version` du manifest distant diffère de celle installée, l'ouverture de l'écran de choix ramène la tuile à « téléchargement requis ». Hors ligne, la tuile reste `ready`, sans message d'erreur.
16. Micro refusé : SnackBar affiché, pas de navigation, pas de crash.
17. Dans les réglages parent, « Supprimer » efface les modèles et la tuile repasse à « téléchargement requis ».
18. Les sessions existantes (QCM, saisie, chrono) s'ouvrent toujours dans l'historique après la mise à jour (compatibilité Hive).
19. `flutter analyze` sans nouvel avertissement, `flutter test` vert.
20. Test manuel sur un iPhone réel et un Android réel, en fr et en en : sur 20 réponses dites par un adulte à voix normale, au moins 18 sont reconnues du premier coup. **À mesurer aussi avec une voix d'enfant** : ce chiffre est rapporté, il ne bloque pas.
21. La mention de crédit Kroko/sherpa-onnx est visible dans les réglages parent, même sans modèle installé.
22. Le rapport final se termine par la « Checklist de fin de déploiement » ci-dessus, mot pour mot.
23. Chaque test du plan indique sa fiche : `protects=<observable protégé>; fails_when=<mauvais résultat rejeté>; no_claim=<ce que le vert ne prouve pas ; quels faux/mocks remplacent quoi, ou « rien au-delà de protects »>`.
24. Aucune régression des fonctionnalités existantes.

## Plan de test

| Couche | Quoi | Nombre |
|---|---|---|
| Unitaire | `SpokenNumberParser` : 0..144 fr + en en lettres, chiffres, dernier nombre d'une phrase, entrées non numériques | +6 (tests paramétrés, 290+ cas) |
| Unitaire | `SpeechModelService` avec `httpClientFactory` (serveur local `HttpServer.bind` sur 127.0.0.1) et `baseDirectoryProvider` (dossier temporaire) : succès, SHA faux, HTTP 404, `.part` orphelins au `refresh`, `delete`, `checkForUpdate` avec une version différente, `checkForUpdate` hors ligne | +7 |
| Unitaire | `int16LeToFloat32` : 0, 32767, −32768, buffer de longueur impaire rejeté | +1 |
| Unitaire | `ExerciseController` en format voice : pas de timer par question, `markQuestionPresented` décale `responseMillis` | +2 |
| Unitaire | `ExerciseFormat` Hive : aller-retour de `voice` via l'adaptateur | +1 |
| Widget | Tuile Oral : états absent / downloading / error / ready / TTS indisponible (service factice) | +5 |
| Widget | `VoiceExerciseScreen` avec TTS, micro et recognizer factices : juste, faux, non compris → répète, réécouter, micro coupé pendant le TTS | +5 |
| Widget | Résultats : temps par question visible pour voice, absent pour directInput | +2 |
| Manuel | Appareils réels fr/en, mode avion, voix adulte et enfant (critère 20) | 1 session de test |

`sherpa_onnx`, `record` et `flutter_tts` sont accessibles derrière des interfaces (`SpeechRecognizerEngine`, `MicrophoneSource`, `SpeechSynthesizer`) injectées dans l'écran, pour que les tests widget n'aient besoin d'aucun plugin natif.

## Règles pour l'agent qui implémente

1. Les critères d'acceptation sont le profil `protects / fails_when / no_claim` de chaque test : l'observable protégé, le mauvais résultat rejeté, et ce que le vert ne prouve pas. Jamais « faire passer les tests ».
2. Le vrai code et les vrais tests arrivent dans le même changement. Un placeholder, une assertion bouchon ou un test reporté à plus tard ne compte pas comme fait.
3. Tout changement de test, validateur, étape de CI, timeout, tolérance, seuil, snapshot ou pragma de suppression est signalé sur sa propre ligne dans le résumé, avec sa justification, avant tout autre résultat.
4. Une commande citée donne la commande et son résultat observé (code de sortie, compteurs, ligne en échec). On ne cite pas une commande qu'on n'a pas lancée, et on ne masque jamais stderr dans une commande citée.
5. Le rapport est une affirmation tant que le parent ne l'a pas relancé : dire ce qui a été vérifié, ce qui a été réutilisé, et ce qui n'a pas pu être vérifié.

## Plan de retour arrière

- Annuler la PR. Les sessions `voice` déjà enregistrées se relisent comme `multipleChoice` (adaptateur Hive par défaut, `exercise_metadata.g.dart:101`), donc pas de crash, juste un libellé faux dans l'historique.
- Les modèles restent dans le dossier Caches, que l'OS finira par purger. Aucun impact.
- VPS : les fichiers des modèles peuvent rester en ligne, ils ne contiennent aucune donnée utilisateur.

## Estimation d'effort

| Composant | Humain | CC |
|---|---|---|
| Script de build des modèles + manifest | 2 h | 10 min |
| `SpeechModelService` + tests | 5 h | 30 min |
| Tuile, états, permission micro | 3 h | 20 min |
| Enum Hive, contrôleur, routes, résultats, stats | 2 h | 15 min |
| `SpokenNumberParser` fr/en + tests | 4 h | 20 min |
| `VoiceExerciseScreen` + abstraction TTS/micro/ASR + tests | 8 h | 1 h |
| Réglages parent, L10n, Info.plist, fr.lproj | 2 h | 15 min |
| Test sur appareils réels, réglage de la détection de fin de parole | 4 h | humain uniquement |
| **Total** | **≈ 30 h (4 j)** | **≈ 3 h + test appareil** |

## Fichiers concernés

| Fichier | Changement |
|---|---|
| `pubspec.yaml` | + `sherpa_onnx: ^2.0.0`, `record: ^7.1.2`, `flutter_tts: ^4.2.5` |
| `../mathsfun-models/scripts/build.sh` | projet séparé : prépare `public/asr/` + manifest |
| `lib/core/constants/speech_constants.dart` | nouveau : URL de base, tailles de secours |
| `lib/data/models/exercise_metadata.dart:42-58` | + `voice` (`HiveField(3)`) |
| `lib/data/models/exercise_metadata.g.dart` | régénéré |
| `lib/data/services/speech_model_service.dart` | nouveau |
| `lib/core/app.dart:25-31` | + `ChangeNotifierProvider<SpeechModelService>` |
| `lib/features/exercise/application/exercise_controller.dart:34,120` | pas de timer par question en voice ; + `markQuestionPresented()` |
| `lib/features/exercise/application/spoken_number_parser.dart` | nouveau |
| `lib/features/exercise/application/voice_engine.dart` | nouveau : interfaces + implémentations sherpa/record/flutter_tts |
| `lib/features/exercise/presentation/voice_exercise_screen.dart` | nouveau |
| `lib/features/exercise/presentation/exercise_mode_type_selection_screen.dart:287` | + tuile Oral et ses états |
| `lib/core/routes/app_router.dart:26-41,138` | + `exerciseVoice` et sa `GoRoute` |
| `lib/features/results/presentation/results_screen.dart:132,186` | temps par question (voice) ; `case voice` dans `_replay` |
| `lib/features/statistics/presentation/statistics_screen.dart:98` | `case voice` |
| `lib/features/profile/widgets/parent_settings_sheet.dart` | ligne « Modèles vocaux » + suppression |
| `lib/l10n/app_fr.arb`, `lib/l10n/app_en.arb` | 21 nouvelles clés |
| `ios/Runner/Info.plist` | + `NSMicrophoneUsageDescription` |
| `ios/Runner/fr.lproj/InfoPlist.strings` | nouveau |
| `android/app/src/main/AndroidManifest.xml` | + `RECORD_AUDIO` |
| `test/spoken_number_parser_test.dart`, `test/speech_model_service_test.dart`, `test/voice_exercise_screen_test.dart`, … | nouveaux |
| `doc/features.md` | + section « Mode oral » |

## Hors périmètre

- Combiner le mode oral avec le défi chronométré.
- La révision orale (flash cards lues à voix haute).
- Les commandes vocales (« répète », « stop »).
- Les statistiques propres à l'oral dans le tableau de bord parent (au-delà du libellé du format).
- La reprise d'un téléchargement interrompu (on recommence depuis zéro).
- La synthèse vocale embarquée (on utilise la voix du système).
- Les mots-clés prioritaires (« hotwords ») de sherpa : seulement si le taux du critère 20 est insuffisant, dans une issue séparée.
- Ajouter un interrupteur Son dans les réglages, et le prendre en compte dans le mode Oral.
- Quantifier soi-même le modèle Kroko pour le rendre plus léger : ce serait une modification soumise à ShareAlike.

## Écarts d'implémentation (2026-10-25, branche `feature/mode-oral`)

- **Modèle anglais : Kroko au lieu de `en-20M`.** Sur Mac, avec les vraies archives et de l'audio de synthèse macOS (voix Samantha), `en-20M` se charge mais renvoie un texte vide pour « forty two », « seventeen » et « one hundred and twelve ». Kroko anglais (≈ 71 Mo, CC-BY-SA) les reconnaît. Test reproduit par le même code de flux et de détection de fin de parole que l'app. Taille de secours : `kSpeechModelSizeBytes['en'] = 71053214`.
- **Silence ≠ incompréhension.** Un résultat vide (rien n'a été dit) ne déclenche pas la phrase « répète » : l'app continue d'écouter. La phrase n'est dite que pour un texte non vide sans nombre.
- **`Pcm16Decoder`** (au lieu de `int16LeToFloat32`) : un octet impair en fin de paquet est gardé pour le paquet suivant au lieu d'être rejeté.
- **Crédits** affichés en texte, avec l'adresse `huggingface.co/Banafo/Kroko-ASR`, sans lien cliquable (pas de nouvelle dépendance `url_launcher`).
- **`app_settings.g.dart` régénéré** : le fichier commité était périmé, et les champs 7 à 14 (dernières tables, difficulté, mélange) n'étaient jamais écrits dans Hive. Ils sont maintenant persistés.
- **Tests** : la logique de l'écran est testée via `VoiceExerciseSession` (faux TTS et faux micro), pas via des tests widget de `VoiceExerciseScreen`. La section « Modèles vocaux » des réglages parent n'a pas de test widget ; `deleteAll` est testé au niveau du service.

- **Voix hors ligne obligatoire (test P20 Lite, 2026-10-26).** Sur Android, `isLanguageAvailable` répond « oui » même quand seule une voix réseau Google (`fr-fr-x-vlf-server`) existe. Sans Internet, la synthèse échoue (code -4), et `flutter_tts` ne termine alors jamais un `speak()` attendu : l'écran restait bloqué sur « Écoute bien ». Corrections :
  - la tuile vérifie `isLanguageInstalled` sur Android (une voix hors ligne doit être installée) et donne le chemin d'installation ;
  - `FlutterTtsSynthesizer` choisit une voix hors ligne, suit lui-même la fin de chaque phrase (handlers + délai maximum) et renvoie `false` en cas d'échec ;
  - si l'appareil ne peut pas parler en cours de session, un bandeau s'affiche et l'exercice continue : l'enfant lit le calcul à l'écran.

## Corrections de la review /ship (2026-10-26)

Reviews : 7 spécialistes (tests, maintenabilité, sécurité, performance, contrat d'API, design, simplification), Red Team, review adversariale Claude, review adversariale Cursor (deuxième modèle). Corrigé :

- **Micro et cycle de vie.** L'écran observe le cycle de vie de l'app. En arrière-plan ou en cas d'interruption (appel, micro perdu, échec du démarrage du micro), la session passe en `paused`, le micro et la voix sont coupés, et « Réécouter » ou le retour au premier plan reprend la question. `SherpaSpeechListener` gère un arrêt pendant le démarrage du micro et signale les erreurs du flux.
- **Synthèse vocale.** Un seul `FlutterTts` pour toute l'app (une nouvelle instance volait les rappels de la session). Une annulation tardive de la phrase précédente n'ouvre plus le micro pendant que l'app parle. Une phrase coupée par une plus récente ne compte plus comme une panne.
- **Android 11+.** `<queries>` déclare `android.intent.action.TTS_SERVICE`, sinon l'app ne voit pas le moteur vocal.
- **Téléchargement.** Délai de connexion de 15 s et délai d'inactivité de 30 s (plus de blocage infini). Taille bornée (200 Mo par fichier) et coupée dès qu'elle dépasse l'annonce. Seuls les 4 fichiers connus sont pris dans le manifest. Un modèle complet déjà sur le disque n'est jamais retéléchargé. « Supprimer » dans les réglages parent annule un téléchargement en cours.
- **Manifest versionné.** L'app lit `asr/manifest-v1.json` (le schéma est dans le nom). Le script exige un numéro de version et rappelle qu'un dossier publié ne se réécrit jamais.
- **Mise à jour.** Vérifiée une fois par lancement, et jamais quand un exercice utilise le modèle (`acquire`/`release`).
- **URL de test** (`SPEECH_MODEL_BASE_URL`) ignorée hors debug.
- **Parseur.** Chiffres et mots mélangés : le dernier nombre dit gagne (« 6 fois 7 ça fait quarante-deux » → 42). « oh » ne vaut zéro que seul.
- **Écran.** Bouton « Passer » (décision D1, la question compte fausse). Le retour s'affiche aussi en texte (« Bravo ! » / « Non, c'était 42 ») et reste 1,5 s à l'écran quand l'appareil ne parle pas. Texte « Je n'ai pas compris » pendant la répétition. Mise en page défilante (grandes polices). Sauvegarde de fin protégée.
- **Temps de réponse** (décision D4) : mesuré jusqu'au dernier mot entendu, sans la fenêtre de silence de détection.
- **Tuile.** Seuls le titre et l'icône pâlissent quand elle est indisponible, le texte d'aide reste lisible. Texte de voix manquante valable sur iOS et Android, adressé à un parent. Le contrôle de voix s'applique aussi en relançant depuis les résultats.
- **Divers.** Route `/exercise/voice` protégée sans arguments, bouton de suppression en rouge, taille des modèles mise à jour en direct, champs morts supprimés, `voiceLanguageFor` partagé.

Décisions de la review :
- **D2 :** pas d'empreintes figées dans l'app. On fait confiance au manifest du CDN, pour garder le plan B côté serveur. Risque accepté : un bucket compromis peut livrer un modèle piégé au moteur natif.
- **D3 :** la reconnaissance sur un isolate séparé est reportée (voir `doc/TODO.md`), car aucun ralentissement n'a été vu sur le P20 Lite.

**Retour arrière vers 1.2.0 :** les sessions orales seraient relues comme des QCM (l'index Hive 3 inconnu tombe sur `multipleChoice`). Ne jamais réutiliser l'index 3 pour autre chose.

