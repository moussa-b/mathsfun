# Publier MathsFun sur l'App Store

État au 24/10/2026 : l'IPA signée **Apple Distribution (34AFV4S7Z8)** de la version
**1.3.0 (build 4)** est dans `build/ios/ipa/mathsfun.ipa`, l'archive Xcode dans
`build/ios/archive/Runner.xcarchive`. Les captures sont dans `appstore/screenshots/`.

Fiche Android de référence : <https://play.google.com/store/apps/details?id=com.bdzapps.mathsfun>

## Ce qui a changé côté iOS pour pouvoir publier

- Flutter épinglé en **3.47.7 via fvm** (`.fvmrc`). Flutter 3.32 ne fonctionne plus avec Xcode 27 :
  le SDK iOS 27 impose le cycle de vie UIScene et l'app plantait au lancement.
- `AppDelegate.swift` et `Info.plist` migrés vers `FlutterSceneDelegate` (même montage que Counter++).
- iOS minimum : **15.0** (le minimum accepté par Xcode 27).
- App **iPhone uniquement** (`TARGETED_DEVICE_FAMILY = 1`), donc pas de captures iPad à fournir.
  Elle reste installable sur iPad en mode compatibilité. On pourra ajouter l'iPad plus tard, mais
  Apple refuse de le retirer une fois publié.
- `ITSAppUsesNonExemptEncryption = false` et `CFBundleLocalizations = fr, en` dans `Info.plist`.
- Équipe de signature `34AFV4S7Z8` renseignée dans le projet Xcode.

## 1. Créer la fiche dans App Store Connect

<https://appstoreconnect.apple.com> → Apps → **+** → Nouvelle app

| Champ | Valeur |
|---|---|
| Plateformes | iOS |
| Nom | MathsFun (s'il est pris : « MathsFun Tables » ou « MathsFun : tables de calcul ») |
| Langue principale | Français (France) |
| Identifiant de lot | `com.bdzapps.mathsfun` (créé par la signature auto lors du build) |
| SKU | `mathsfun-ios` |
| Accès utilisateur | Accès complet |

Ajoute ensuite la localisation **Anglais (U.S.)** (menu langue en haut à droite de la fiche).

## 2. Envoyer le build

Option la plus simple, par Xcode :

```bash
open build/ios/archive/Runner.xcarchive
```

Organizer → **Distribute App** → **App Store Connect** → **Upload**. Les options par défaut conviennent.

Autre option : l'app **Transporter** (Mac App Store), glisser `build/ios/ipa/mathsfun.ipa`.

Le build apparaît dans l'onglet TestFlight après 5 à 30 min de traitement. La question sur le
chiffrement ne sera pas posée.

Pour les prochaines versions : incrémenter `version:` dans `pubspec.yaml` (le numéro de build
doit toujours augmenter), puis :

```bash
fvm flutter build ipa --release --export-method app-store
```

## 3. Remplir la version 1.3.0

### Captures

Glisser les fichiers dans l’ordre 01 → 09 (09_oral = mode Oral, nouveau en 1.3.0), dossier `fr` pour la fiche française, `en` pour l'anglaise :

- **iPhone with Dynamic Island (large display)** : `appstore/screenshots/iphone-6.9/{fr,en}/` (1320×2868).
- **iPhone with Dynamic Island (medium display)** : `appstore/screenshots/iphone-6.3/{fr,en}/` (1206×2622).
  Si App Store Connect ne la demande pas, elle est facultative : Apple réduit les captures 6,9".

Les captures n'ont pas de canal alpha (sinon l'upload est refusé). Pour les régénérer après un
changement d'interface (environ 2 min par simulateur) :

```bash
tool/appstore_screenshots.sh C4D3FDD9-BEDE-4820-BA0D-D51E6BD9686B iphone-6.9
```

```bash
tool/appstore_screenshots.sh 935DB9AC-CCF6-4C0A-B378-7BE5E70787C7 iphone-6.3
```

(iPhone 18 Pro Max et iPhone 18 Pro sous iOS 27 ; un 3e argument `fr` ou `en` limite à une langue.)

### Textes (FR)

- **Sous-titre** (30 car.) : `Révise tes tables en jouant`
- **Mots-clés** (100 car.) : `tables,multiplication,addition,calcul mental,maths,CP,CE1,CE2,CM1,CM2,école,révision,enfant,primaire`
- **Texte promotionnel** : `Tables de multiplication et additions, du CP au CM2 : révise avec des cartes, entraîne-toi avec des quiz.`
- **Description** :

```
MathsFun aide les enfants du CP au CM2 à apprendre les tables de multiplication et les additions, en s'amusant.

• Un profil par enfant, avec son prénom, sa classe et son avatar.
• Mode révision : la table complète ou des cartes à retourner pour tester sa mémoire.
• Mode exercice : QCM, saisie directe, défi chronométré ou mode Oral.
• Mode Oral : l'app lit l'opération à voix haute et l'enfant répond à l'oral. La reconnaissance vocale se fait entièrement sur l'appareil.
• Choix des tables à travailler, trois niveaux de difficulté, questions dans l'ordre ou mélangées.
• Des étoiles à gagner et des statistiques pour suivre les progrès.
• Un code parent pour protéger les réglages et la suppression des profils.
• En français et en anglais.

Sans publicité, sans compte. Internet ne sert qu'une fois, pour télécharger la voix du mode Oral (environ 70 Mo). Aucune donnée ne quitte l'appareil, et la voix de l'enfant n'est jamais enregistrée.
```

### Texts (EN)

- **Subtitle**: `Learn times tables by playing`
- **Keywords**: `times tables,multiplication,addition,math,mental math,kids,school,flash cards,practice,quiz,learn`
- **Promotional text**: `Times tables and addition for primary school: revise with flash cards, practise with quizzes.`
- **Description**:

```
MathsFun helps primary school children learn their times tables and addition facts while having fun.

• One profile per child, with a nickname, school year and avatar.
• Revision mode: the full table, or flash cards to flip and test recall.
• Exercise mode: multiple choice, direct input, a timed challenge or Oral mode.
• Oral mode: the app reads the question aloud and the child answers out loud. Speech recognition runs entirely on the device.
• Pick which tables to practise, three difficulty levels, ordered or shuffled questions.
• Stars to earn and statistics to follow progress.
• A parent PIN protects settings and profile deletion.
• In English and French.

No ads, no account. The internet is only used once, to download the Oral mode voice model (about 70 MB). No data ever leaves the device, and the child's voice is never recorded.
```

### Autres champs

| Champ | Valeur |
|---|---|
| URL d'assistance | `https://bdzapps.com/mathsfun/support/` |
| URL de politique de confidentialité | `https://bdzapps.com/mathsfun/privacy/` |
| Copyright | `2026 Moussa Boudamouz` |
| Catégorie | Éducation (secondaire : Jeux → Éducatifs, ou rien) |
| Prix | Gratuit (onglet Tarifs et disponibilité) |
| Build | sélectionner 1.3.0 (4) |
| Connexion requise | Non (pas de compte de démo à fournir) |

### Confidentialité de l'app

Choisir **« Aucune donnée collectée »**. Depuis la 1.3.0, la seule requête réseau télécharge les modèles
vocaux depuis `mathsfun-models.bdzapps.com` ; le micro est analysé sur l'appareil, rien n'est envoyé ni
conservé. L'app ne contient aucun SDK tiers. Les journaux nginx du VPS ne doivent servir à rien d'autre
qu'au service (les désactiver ou les garder peu de temps).

### Classification par âge

Répondre « Aucun » ou « Non » partout → **4+**. Le code parent n'est pas un « contrôle parental »
au sens d'Apple (il ne filtre pas de contenu) : répondre Non.

### Catégorie Enfants : à éviter pour ce premier envoi

Ne coche pas « Made for Kids / Catégorie Enfants ». Elle impose une tranche d'âge définitive et une
vérification plus stricte (barrière parentale devant tout lien externe, etc.). Une app Éducation 4+
reste visible des parents et peut passer en catégorie Enfants plus tard si tu le souhaites.

## 4. Soumettre

**Ajouter pour vérification** → **Soumettre**. Délai habituel : 24 à 48 h. Pour un premier envoi,
choisir la publication manuelle afin de pouvoir corriger la fiche avant la sortie.

Risque de rejet le plus probable : aucun identifié. Pas de lien externe, pas d'achat, pas de
données, pas de contenu Android dans l'app.
