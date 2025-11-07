// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'MathsFun';

  @override
  String get splashLoading => 'Chargement de MathsFun…';

  @override
  String get profileCreationTitle => 'Créer un profil';

  @override
  String get profileCreationHeading => 'Qui joue ?';

  @override
  String get profileCreationSubtitle =>
      'Crée un profil amusant pour suivre les progrès.';

  @override
  String get profileNicknameLabel => 'Surnom';

  @override
  String get profileNicknameHint => 'ex. Super Sophie';

  @override
  String get profileNicknameErrorEmpty => 'Merci de choisir un surnom';

  @override
  String get profileNicknameErrorShort =>
      'Le surnom doit comporter au moins 3 caractères';

  @override
  String get profileClassLabel => 'Classe';

  @override
  String get profileAvatarLabel => 'Choisir un avatar';

  @override
  String get profileSaveButton => 'Enregistrer le profil';

  @override
  String get profileCreateSuccess => 'Profil créé !';

  @override
  String profileCreateError(String error) {
    return 'Impossible de créer le profil : $error';
  }

  @override
  String get profileSelectorTitle => 'Qui joue aujourd\'hui ?';

  @override
  String get profileSelectorParentSettings => 'Réglages parents';

  @override
  String get profileSelectorNewProfile => 'Nouveau profil';

  @override
  String profileSelectorGreeting(String name) {
    return 'Bonjour $name !';
  }

  @override
  String profileSelectorDeleteMessage(String name) {
    return 'Cela supprimera les progrès et récompenses de $name. Cette action est irréversible.';
  }

  @override
  String get profileSelectorDeleteTitle => 'Supprimer le profil ?';

  @override
  String get profileSelectorDeleteCancel => 'Annuler';

  @override
  String get profileSelectorDeleteConfirm => 'Supprimer';

  @override
  String profileSelectorDeleteSuccess(String name) {
    return 'Profil de $name supprimé';
  }

  @override
  String get profileSelectorEmptyTitle => 'Aucun profil';

  @override
  String get profileSelectorEmptySubtitle =>
      'Crée un profil pour suivre les scores et récompenses.';

  @override
  String get profileSelectorEmptyButton => 'Créer un profil';

  @override
  String get parentSettingsTitle => 'Réglages parents';

  @override
  String get parentSettingsDescriptionWithPin =>
      'Modifie ton code parent pour protéger les actions sensibles.';

  @override
  String get parentSettingsDescriptionNoPin =>
      'Définis un code parent pour contrôler la suppression des profils et l\'accès aux réglages.';

  @override
  String get parentSettingsPinLabelCreate => 'Créer un code';

  @override
  String get parentSettingsPinLabelNew => 'Nouveau code';

  @override
  String get parentSettingsPinConfirmLabel => 'Confirmer le code';

  @override
  String get parentSettingsPinValidationDigits =>
      'Le code doit comporter 4 chiffres';

  @override
  String get parentSettingsPinValidationEmpty => 'Saisis un code à 4 chiffres';

  @override
  String get parentSettingsPinConfirmValidationEmpty => 'Confirme ton code';

  @override
  String get parentSettingsPinConfirmValidationMismatch =>
      'Les codes ne correspondent pas';

  @override
  String get parentSettingsSaveButton => 'Enregistrer le code';

  @override
  String get parentSettingsRemovePin => 'Supprimer le code';

  @override
  String get parentSettingsSaving => 'Enregistrement…';

  @override
  String get parentSettingsSaved => 'Code parent mis à jour';

  @override
  String get parentSettingsRemoved => 'Code parent supprimé';

  @override
  String get parentSettingsLanguageLabel => 'Langue de l\'application';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageFrench => 'Français';

  @override
  String get parentGateTitle => 'Accès parent';

  @override
  String get parentGateMessage => 'Entre ton code à 4 chiffres pour continuer.';

  @override
  String get parentGatePinLabel => 'Code';

  @override
  String get parentGatePinEmpty => 'Merci d\'entrer ton code';

  @override
  String get parentGatePinInvalid => 'Le code doit comporter 4 chiffres';

  @override
  String get parentGatePinIncorrect => 'Code incorrect';

  @override
  String get parentGateErrorFix => 'Merci de corriger les erreurs ci-dessus.';

  @override
  String get parentGateCancel => 'Annuler';

  @override
  String get parentGateUnlock => 'Déverrouiller';

  @override
  String get exerciseTypeTitle => 'Choisis ton aventure';

  @override
  String get exerciseTypeSubtitle => 'Que veux-tu réviser ?';

  @override
  String get exerciseTypeChangeProfile => 'Changer de profil';

  @override
  String get exerciseTypeWelcomeBack => 'Content de te revoir,';

  @override
  String get exerciseDefaultNickname => 'Explorateur';

  @override
  String get profileMenuEdit => 'Modifier le profil';

  @override
  String get profileMenuSwitch => 'Changer de compte';

  @override
  String get profileMenuStatistics => 'Mes statistiques';

  @override
  String get profileEditTitle => 'Modifier le profil';

  @override
  String get questionOrderLabel => 'Ordre des questions';

  @override
  String get questionOrderShuffled => 'Mélangé (Aléatoire)';

  @override
  String get questionOrderOrdered => 'Ordonné (Séquentiel)';

  @override
  String get profileUpdateSuccess => 'Profil mis à jour !';

  @override
  String profileUpdateError(String error) {
    return 'Impossible de mettre à jour le profil : $error';
  }

  @override
  String get exerciseMultiplication => 'Multiplications';

  @override
  String get exerciseAddition => 'Additions';

  @override
  String get exerciseMultiplicationDescription =>
      'Maîtrise les tables avec des jeux et des révisions.';

  @override
  String get exerciseAdditionDescription =>
      'Développe tes super pouvoirs de calcul mental.';

  @override
  String get modeSelectionTitle => 'Choisir un mode';

  @override
  String get modeSelectionHeadingMultiplication => 'Table de multiplication';

  @override
  String get modeSelectionHeadingAddition => 'Opérations d\'addition';

  @override
  String get modeSelectionSubtitle => 'Choisis un nombre à réviser.';

  @override
  String get modeRevisionCardTitle => 'Mode révision';

  @override
  String get modeRevisionCardDescription =>
      'Revois la table complète avec les réponses et des animations.';

  @override
  String get modeExerciseCardTitle => 'Mode exercice';

  @override
  String get modeExerciseCardDescription =>
      'Réponds aux questions et gagne des étoiles avec une super précision !';

  @override
  String get tableSelectorLabel => 'Table';

  @override
  String tableSelectorSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tables sélectionnées',
      one: '1 table sélectionnée',
    );
    return '$_temp0';
  }

  @override
  String get revisionTitleMultiplication => 'Révision des multiplications';

  @override
  String get revisionTitleAddition => 'Révision des additions';

  @override
  String revisionHeadingMultiplication(int table) {
    return 'Exerce-toi sur la table de ×$table';
  }

  @override
  String revisionHeadingAddition(int table) {
    return 'Exerce-toi à additionner $table';
  }

  @override
  String get exerciseModeTypeTitle => 'Style d\'exercice';

  @override
  String get exerciseModePrompt => 'Comment veux-tu t\'entraîner ?';

  @override
  String get exerciseMultipleChoiceTitle => 'QCM';

  @override
  String get exerciseMultipleChoiceDescription =>
      'Choisis la bonne réponse parmi quatre options. Parfait pour s\'échauffer !';

  @override
  String get exerciseDirectInputTitle => 'Saisie directe';

  @override
  String get exerciseDirectInputDescription =>
      'Tape la réponse pour muscler ta mémoire.';

  @override
  String get exerciseTimedChallengeTitle => 'Défi chronométré';

  @override
  String exerciseTimedChallengeDescription(int seconds) {
    return 'Réponds au maximum en $seconds secondes pour gagner des étoiles !';
  }

  @override
  String get exerciseNoProfile =>
      'Aucun profil sélectionné. Merci d\'en choisir un d\'abord.';

  @override
  String get exerciseSolvePrompt => 'Résous :';

  @override
  String get exerciseTimedBanner => 'Réponds le plus vite possible !';

  @override
  String exerciseTimedCountdown(int seconds) {
    return 'Il reste $seconds secondes';
  }

  @override
  String get exerciseTimedGo => 'Go !';

  @override
  String exerciseQuestionProgress(int current, int total) {
    return 'Question $current / $total';
  }

  @override
  String get exerciseAnswerLabel => 'Ta réponse';

  @override
  String get exerciseSubmit => 'Valider';

  @override
  String get exerciseSkip => 'Passer';

  @override
  String get exerciseSnackbarCorrect => 'Bravo !';

  @override
  String get exerciseSnackbarIncorrect => 'Oups, réessaie !';

  @override
  String get exerciseSnackbarDirectCorrect => 'Oui ! Continue !';

  @override
  String get exerciseSnackbarDirectIncorrect =>
      'Pas tout à fait, tu vas y arriver !';

  @override
  String get exerciseAnswerRequired => 'Saisis une réponse pour continuer.';

  @override
  String get exerciseDigitsOnly => 'Entre uniquement des chiffres.';

  @override
  String get resultsNoSession => 'Aucune donnée de session.';

  @override
  String get resultsBackHome => 'Retour à l\'accueil';

  @override
  String get resultsTitle => 'Résultats';

  @override
  String get resultsHeading => 'Bravo !';

  @override
  String get resultsAccuracy => 'Précision';

  @override
  String get resultsCorrect => 'Bonnes réponses';

  @override
  String get resultsMistakes => 'Erreurs';

  @override
  String get resultsTime => 'Temps';

  @override
  String get resultsTimedGoal => 'Défi chrono';

  @override
  String resultsTimedValue(int seconds) {
    return 'Défi de ${seconds}s';
  }

  @override
  String resultsAnswerLabel(int answer) {
    return 'Réponse : $answer';
  }

  @override
  String get resultsSkipped => 'Passée';

  @override
  String get resultsReplay => 'Rejouer';

  @override
  String get resultsStatistics => 'Voir les statistiques';

  @override
  String statisticsTitle(String name) {
    return '$name — Statistiques';
  }

  @override
  String get statisticsPageTitle => 'Statistiques';

  @override
  String get statisticsEmpty => 'Fais un exercice pour débloquer tes stats !';

  @override
  String get statisticsSessions => 'Sessions';

  @override
  String get statisticsAverageAccuracy => 'Précision moy.';

  @override
  String get statisticsStars => 'Étoiles gagnées';

  @override
  String get statisticsPracticeTime => 'Temps de pratique';

  @override
  String get statisticsRecentSessions => 'Sessions récentes';

  @override
  String statisticsSessionSummary(String operation, String format) {
    return '$operation — $format';
  }

  @override
  String statisticsSessionAccuracy(int accuracy) {
    return '$accuracy% de réussite';
  }

  @override
  String statisticsSessionScore(int correct, int total) {
    return '$correct/$total';
  }

  @override
  String get statisticsOperationMultiplication => 'Multiplication';

  @override
  String get statisticsOperationAddition => 'Addition';

  @override
  String get statisticsFormatMultipleChoice => 'QCM';

  @override
  String get statisticsFormatDirectInput => 'Saisie directe';

  @override
  String get statisticsFormatTimedChallenge => 'Défi chrono';

  @override
  String get parentSettingsSavingLabel => 'Enregistrement…';

  @override
  String get loadingGeneric => 'Chargement…';

  @override
  String errorRouteNotFound(String path) {
    return 'Route introuvable : $path';
  }

  @override
  String get avatarBraveLion => 'Lion courageux';

  @override
  String get avatarSparklyDino => 'Dino scintillant';

  @override
  String get avatarSpaceExplorer => 'Explorateur spatial';

  @override
  String get avatarHappyRobot => 'Robot joyeux';

  @override
  String get avatarMagicUnicorn => 'Licorne magique';

  @override
  String get avatarCreativePainter => 'Peintre créatif';

  @override
  String get rewardBrilliantWork => 'Excellent travail !';

  @override
  String rewardScoredAccuracy(String accuracy) {
    return 'Score de $accuracy% de précision.';
  }

  @override
  String get revisionModeTypeTitle => 'Style de révision';

  @override
  String get revisionModePrompt => 'Comment souhaitez-vous réviser ?';

  @override
  String get revisionListViewTitle => 'Vue liste';

  @override
  String get revisionListViewDescription =>
      'Voir toutes les opérations et réponses dans une liste déroulante.';

  @override
  String get revisionFlashCardTitle => 'Cartes mémoire';

  @override
  String get revisionFlashCardDescription =>
      'Cartes interactives pour tester vos connaissances. Retournez pour voir les réponses !';

  @override
  String get flashCardTitle => 'Révision par cartes mémoire';

  @override
  String flashCardProgress(int current, int total) {
    return 'Carte $current sur $total';
  }

  @override
  String get flashCardTapToReveal => 'Appuyez pour révéler la réponse';

  @override
  String get flashCardPrevious => 'Précédent';

  @override
  String get flashCardNext => 'Suivant';

  @override
  String get flashCardGotIt => 'Compris';

  @override
  String get flashCardReviewAgain => 'À revoir';

  @override
  String get flashCardSummaryTitle => 'Révision terminée !';

  @override
  String get flashCardSummaryMastered => 'Cartes maîtrisées';

  @override
  String get flashCardSummaryToReview => 'À revoir';

  @override
  String get flashCardSummaryNotAnswered => 'Non répondu';

  @override
  String get flashCardRestart => 'Recommencer';

  @override
  String get flashCardReviewMarked => 'Revoir les cartes marquées';
}
