# TODO — suivi MathsFun

Fichier de suivi unique du projet : **pas d'issue GitHub, pas de PR**. Chaque tâche
a sa spec détaillée dans [`doc/specs/`](specs/). Branches : `feature/<slug>` depuis
`develop`, fusion locale dans `develop` après validation, puis `develop` → `main` pour
une version. Push avec la clé SSH perso (`core.sshCommand` configuré dans le dépôt).

Statuts : ⬜ à faire · 🟨 en cours · 🟦 à valider (codé, attend le test sur appareil) · ✅ fait (fusionné dans develop)

## Specs du 2026-10-25

| # | Tâche | Spec | Branche | Priorité | Effort | Dépend de | Statut |
|---|-------|------|---------|----------|--------|-----------|--------|
| A | Mode d'exercice « Oral » : l'app lit l'opération, écoute la réponse (sherpa_onnx hors ligne, modèles Kroko fr/en ≈ 71 Mo chacun, téléchargés depuis R2), corrige à voix haute, chronomètre la session et chaque question | [A](specs/A-mode-oral.md) | `feature/mode-oral` | Haute | ~30 h humain / ~3 h CC + test sur appareil | Hébergement `mathsfun-models.bdzapps.com` (projet `../mathsfun-models`) + licence Kroko validée | ✅ livré en local : 1.3.0 (build 4), tag `v1.3.0`, AAB + IPA construits ; reste la publication (R2, licence, site, stores) |

| A2 | Mode Oral : reconnaissance (chargement du modèle + décodage) sur un isolate séparé, modèle gardé en mémoire entre deux exercices | [A](specs/A-mode-oral.md) (décision D3) | — | Basse | ~1 j humain / ~45 min CC + retest appareil | A | ⬜ à faire si des saccades sont signalées |

Qualité des specs (revue `cursor-agent`, 2026-10-25) : A 8/10. Les ambiguïtés relevées
(permission micro, injection du client HTTP, réglage Son sans interface, cycle de vie du
manifest, contrat sherpa/record) ont été levées dans la spec.

## Rappels de fin de déploiement

- **A (mode Oral)** : avant de soumettre aux stores, mettre à jour la politique de
  confidentialité (`bdzapps.com/mathsfun/privacy/`), le site web de MathsFun, la
  confidentialité dans App Store Connect, la sécurité des données sur Google Play
  et les fiches des stores. Détail dans la section « Checklist de fin de déploiement »
  de la spec.

## Reprise de la livraison A (état au 2026-10-26, 15 h)

- Fait : test sur le P20 Lite (1er exercice ≈ 28 s avec le texte d'attente, 2ᵉ exercice 1,5 s), version 1.3.0+4, fusion `develop` → `main`, tag `v1.3.0`, `build/app/outputs/bundle/release/app-release.aab` et `build/ios/ipa/mathsfun.ipa` construits depuis `main`, branche `feature/mode-oral` supprimée. Rien n'est poussé.
- Fait : modèles en ligne sur `mathsfun-models.bdzapps.com` (vérifiés le 2026-10-26). Reste, dans l’ordre : validation de la licence Kroko, prompt du site fr/en, mises à jour des stores (App Privacy, Data safety, fiches, captures).
