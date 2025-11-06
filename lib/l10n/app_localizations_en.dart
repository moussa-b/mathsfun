// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MathsFun';

  @override
  String get splashLoading => 'Loading MathsFun...';

  @override
  String get profileCreationTitle => 'Create Profile';

  @override
  String get profileCreationHeading => 'Who is playing?';

  @override
  String get profileCreationSubtitle =>
      'Create a fun profile so we can track progress.';

  @override
  String get profileNicknameLabel => 'Nickname';

  @override
  String get profileNicknameHint => 'e.g. Super Sophie';

  @override
  String get profileNicknameErrorEmpty => 'Please choose a nickname';

  @override
  String get profileNicknameErrorShort =>
      'Nickname should be at least 3 characters';

  @override
  String get profileClassLabel => 'Class';

  @override
  String get profileAvatarLabel => 'Pick an avatar';

  @override
  String get profileSaveButton => 'Save Profile';

  @override
  String get profileCreateSuccess => 'Profile created!';

  @override
  String profileCreateError(String error) {
    return 'Could not create profile: $error';
  }

  @override
  String get profileSelectorTitle => 'Who is playing today?';

  @override
  String get profileSelectorParentSettings => 'Parent settings';

  @override
  String get profileSelectorNewProfile => 'New profile';

  @override
  String profileSelectorGreeting(String name) {
    return 'Hello $name!';
  }

  @override
  String profileSelectorDeleteMessage(String name) {
    return 'This will remove $name\'s progress and rewards. This action cannot be undone.';
  }

  @override
  String get profileSelectorDeleteTitle => 'Delete profile?';

  @override
  String get profileSelectorDeleteCancel => 'Cancel';

  @override
  String get profileSelectorDeleteConfirm => 'Delete';

  @override
  String profileSelectorDeleteSuccess(String name) {
    return '$name\'s profile removed';
  }

  @override
  String get profileSelectorEmptyTitle => 'No profiles yet';

  @override
  String get profileSelectorEmptySubtitle =>
      'Create a profile so we can keep track of scores and rewards.';

  @override
  String get profileSelectorEmptyButton => 'Create profile';

  @override
  String get parentSettingsTitle => 'Parent Settings';

  @override
  String get parentSettingsDescriptionWithPin =>
      'Update your parent PIN to keep sensitive actions protected.';

  @override
  String get parentSettingsDescriptionNoPin =>
      'Set a parent PIN to control profile deletion and access to settings.';

  @override
  String get parentSettingsPinLabelCreate => 'Create PIN';

  @override
  String get parentSettingsPinLabelNew => 'New PIN';

  @override
  String get parentSettingsPinConfirmLabel => 'Confirm PIN';

  @override
  String get parentSettingsPinValidationDigits => 'PIN must be 4 digits';

  @override
  String get parentSettingsPinValidationEmpty => 'Enter a 4-digit PIN';

  @override
  String get parentSettingsPinConfirmValidationEmpty => 'Confirm your PIN';

  @override
  String get parentSettingsPinConfirmValidationMismatch => 'PINs do not match';

  @override
  String get parentSettingsSaveButton => 'Save PIN';

  @override
  String get parentSettingsRemovePin => 'Remove PIN';

  @override
  String get parentSettingsSaving => 'Saving...';

  @override
  String get parentSettingsSaved => 'Parent PIN updated';

  @override
  String get parentSettingsRemoved => 'Parent PIN removed';

  @override
  String get parentSettingsLanguageLabel => 'App language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'French';

  @override
  String get parentGateTitle => 'Parent Access';

  @override
  String get parentGateMessage => 'Enter your 4-digit PIN to continue.';

  @override
  String get parentGatePinLabel => 'PIN';

  @override
  String get parentGatePinEmpty => 'Please enter your PIN';

  @override
  String get parentGatePinInvalid => 'PIN must be 4 digits';

  @override
  String get parentGatePinIncorrect => 'Incorrect PIN';

  @override
  String get parentGateErrorFix => 'Please fix the errors above.';

  @override
  String get parentGateCancel => 'Cancel';

  @override
  String get parentGateUnlock => 'Unlock';

  @override
  String get exerciseTypeTitle => 'Choose Your Adventure';

  @override
  String get exerciseTypeSubtitle => 'What would you like to practise?';

  @override
  String get exerciseTypeChangeProfile => 'Change profile';

  @override
  String get exerciseTypeWelcomeBack => 'Welcome back,';

  @override
  String get exerciseDefaultNickname => 'Explorer';

  @override
  String get exerciseMultiplication => 'Multiplication';

  @override
  String get exerciseAddition => 'Addition';

  @override
  String get exerciseMultiplicationDescription =>
      'Master times tables with games and revision.';

  @override
  String get exerciseAdditionDescription =>
      'Grow your mental maths superpowers.';

  @override
  String get modeSelectionTitle => 'Pick a Mode';

  @override
  String get modeSelectionHeadingMultiplication => 'Multiplication table';

  @override
  String get modeSelectionHeadingAddition => 'Addition facts';

  @override
  String get modeSelectionSubtitle => 'Choose a number to practise.';

  @override
  String get modeRevisionCardTitle => 'Revision Mode';

  @override
  String get modeRevisionCardDescription =>
      'Review the full table with answers and animations.';

  @override
  String get modeExerciseCardTitle => 'Exercise Mode';

  @override
  String get modeExerciseCardDescription =>
      'Answer questions and earn stars for great accuracy!';

  @override
  String get tableSelectorLabel => 'Table';

  @override
  String get revisionTitleMultiplication => 'Multiplication Revision';

  @override
  String get revisionTitleAddition => 'Addition Revision';

  @override
  String revisionHeadingMultiplication(int table) {
    return 'Practise the ×$table table';
  }

  @override
  String revisionHeadingAddition(int table) {
    return 'Practise adding $table';
  }

  @override
  String get exerciseModeTypeTitle => 'Exercise Style';

  @override
  String get exerciseModePrompt => 'How would you like to practise?';

  @override
  String get exerciseMultipleChoiceTitle => 'Multiple Choice';

  @override
  String get exerciseMultipleChoiceDescription =>
      'Pick the correct answer out of four options. Great for warm-ups!';

  @override
  String get exerciseDirectInputTitle => 'Direct Input';

  @override
  String get exerciseDirectInputDescription =>
      'Type the answer yourself to build strong recall.';

  @override
  String get exerciseTimedChallengeTitle => 'Timed Challenge';

  @override
  String exerciseTimedChallengeDescription(int seconds) {
    return 'Answer as many as you can in $seconds seconds for bonus stars!';
  }

  @override
  String get exerciseNoProfile =>
      'No profile selected. Please choose a profile first.';

  @override
  String get exerciseSolvePrompt => 'Solve:';

  @override
  String get exerciseTimedBanner => 'Answer as fast as you can!';

  @override
  String exerciseTimedCountdown(int seconds) {
    return '$seconds seconds left';
  }

  @override
  String get exerciseTimedGo => 'Go!';

  @override
  String exerciseQuestionProgress(int current, int total) {
    return 'Question $current / $total';
  }

  @override
  String get exerciseAnswerLabel => 'Your answer';

  @override
  String get exerciseSubmit => 'Submit';

  @override
  String get exerciseSkip => 'Skip';

  @override
  String get exerciseSnackbarCorrect => 'Great job!';

  @override
  String get exerciseSnackbarIncorrect => 'Oops, keep trying!';

  @override
  String get exerciseSnackbarDirectCorrect => 'Yes! Keep going!';

  @override
  String get exerciseSnackbarDirectIncorrect => 'Not quite, you can do it!';

  @override
  String get exerciseAnswerRequired => 'Enter an answer to continue.';

  @override
  String get exerciseDigitsOnly => 'Please enter digits only.';

  @override
  String get resultsNoSession => 'No session data found.';

  @override
  String get resultsBackHome => 'Back to home';

  @override
  String get resultsTitle => 'Results';

  @override
  String get resultsHeading => 'Well done!';

  @override
  String get resultsAccuracy => 'Accuracy';

  @override
  String get resultsCorrect => 'Correct';

  @override
  String get resultsMistakes => 'Mistakes';

  @override
  String get resultsTime => 'Time';

  @override
  String get resultsTimedGoal => 'Timed goal';

  @override
  String resultsTimedValue(int seconds) {
    return '${seconds}s challenge';
  }

  @override
  String resultsAnswerLabel(int answer) {
    return 'Answer: $answer';
  }

  @override
  String get resultsSkipped => 'Skipped';

  @override
  String get resultsReplay => 'Play again';

  @override
  String get resultsStatistics => 'View statistics';

  @override
  String statisticsTitle(String name) {
    return '$name — Statistics';
  }

  @override
  String get statisticsPageTitle => 'Statistics';

  @override
  String get statisticsEmpty => 'Complete an exercise to unlock your stats!';

  @override
  String get statisticsSessions => 'Sessions';

  @override
  String get statisticsAverageAccuracy => 'Avg accuracy';

  @override
  String get statisticsStars => 'Stars earned';

  @override
  String get statisticsPracticeTime => 'Practice time';

  @override
  String get statisticsRecentSessions => 'Recent sessions';

  @override
  String statisticsSessionSummary(String operation, String format) {
    return '$operation — $format';
  }

  @override
  String statisticsSessionAccuracy(int accuracy) {
    return '$accuracy% accuracy';
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
  String get statisticsFormatMultipleChoice => 'Multiple choice';

  @override
  String get statisticsFormatDirectInput => 'Direct input';

  @override
  String get statisticsFormatTimedChallenge => 'Timed challenge';

  @override
  String get parentSettingsSavingLabel => 'Saving...';

  @override
  String get loadingGeneric => 'Loading...';

  @override
  String errorRouteNotFound(String path) {
    return 'Route not found: $path';
  }

  @override
  String get avatarBraveLion => 'Brave Lion';

  @override
  String get avatarSparklyDino => 'Sparkly Dino';

  @override
  String get avatarSpaceExplorer => 'Space Explorer';

  @override
  String get avatarHappyRobot => 'Happy Robot';

  @override
  String get avatarMagicUnicorn => 'Magic Unicorn';

  @override
  String get avatarCreativePainter => 'Creative Painter';

  @override
  String get rewardBrilliantWork => 'Brilliant work!';

  @override
  String rewardScoredAccuracy(String accuracy) {
    return 'Scored $accuracy% accuracy.';
  }
}
