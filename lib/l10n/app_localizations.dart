import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'MathsFun'**
  String get appTitle;

  /// No description provided for @splashLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading MathsFun...'**
  String get splashLoading;

  /// No description provided for @profileCreationTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Profile'**
  String get profileCreationTitle;

  /// No description provided for @profileCreationHeading.
  ///
  /// In en, this message translates to:
  /// **'Who is playing?'**
  String get profileCreationHeading;

  /// No description provided for @profileCreationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a fun profile so we can track progress.'**
  String get profileCreationSubtitle;

  /// No description provided for @profileNicknameLabel.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get profileNicknameLabel;

  /// No description provided for @profileNicknameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Super Sophie'**
  String get profileNicknameHint;

  /// No description provided for @profileNicknameErrorEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please choose a nickname'**
  String get profileNicknameErrorEmpty;

  /// No description provided for @profileNicknameErrorShort.
  ///
  /// In en, this message translates to:
  /// **'Nickname should be at least 3 characters'**
  String get profileNicknameErrorShort;

  /// No description provided for @profileClassLabel.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get profileClassLabel;

  /// No description provided for @profileAvatarLabel.
  ///
  /// In en, this message translates to:
  /// **'Pick an avatar'**
  String get profileAvatarLabel;

  /// No description provided for @profileSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get profileSaveButton;

  /// No description provided for @profileCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile created!'**
  String get profileCreateSuccess;

  /// No description provided for @profileCreateError.
  ///
  /// In en, this message translates to:
  /// **'Could not create profile: {error}'**
  String profileCreateError(String error);

  /// No description provided for @profileSelectorTitle.
  ///
  /// In en, this message translates to:
  /// **'Who is playing today?'**
  String get profileSelectorTitle;

  /// No description provided for @profileSelectorParentSettings.
  ///
  /// In en, this message translates to:
  /// **'Parent settings'**
  String get profileSelectorParentSettings;

  /// No description provided for @profileSelectorNewProfile.
  ///
  /// In en, this message translates to:
  /// **'New profile'**
  String get profileSelectorNewProfile;

  /// No description provided for @profileSelectorGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello {name}!'**
  String profileSelectorGreeting(String name);

  /// No description provided for @profileSelectorDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This will remove {name}\'s progress and rewards. This action cannot be undone.'**
  String profileSelectorDeleteMessage(String name);

  /// No description provided for @profileSelectorDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete profile?'**
  String get profileSelectorDeleteTitle;

  /// No description provided for @profileSelectorDeleteCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profileSelectorDeleteCancel;

  /// No description provided for @profileSelectorDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get profileSelectorDeleteConfirm;

  /// No description provided for @profileSelectorDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s profile removed'**
  String profileSelectorDeleteSuccess(String name);

  /// No description provided for @profileSelectorEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No profiles yet'**
  String get profileSelectorEmptyTitle;

  /// No description provided for @profileSelectorEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a profile so we can keep track of scores and rewards.'**
  String get profileSelectorEmptySubtitle;

  /// No description provided for @profileSelectorEmptyButton.
  ///
  /// In en, this message translates to:
  /// **'Create profile'**
  String get profileSelectorEmptyButton;

  /// No description provided for @parentSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Parent Settings'**
  String get parentSettingsTitle;

  /// No description provided for @parentSettingsDescriptionWithPin.
  ///
  /// In en, this message translates to:
  /// **'Update your parent PIN to keep sensitive actions protected.'**
  String get parentSettingsDescriptionWithPin;

  /// No description provided for @parentSettingsDescriptionNoPin.
  ///
  /// In en, this message translates to:
  /// **'Set a parent PIN to control profile deletion and access to settings.'**
  String get parentSettingsDescriptionNoPin;

  /// No description provided for @parentSettingsPinLabelCreate.
  ///
  /// In en, this message translates to:
  /// **'Create PIN'**
  String get parentSettingsPinLabelCreate;

  /// No description provided for @parentSettingsPinLabelNew.
  ///
  /// In en, this message translates to:
  /// **'New PIN'**
  String get parentSettingsPinLabelNew;

  /// No description provided for @parentSettingsPinConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get parentSettingsPinConfirmLabel;

  /// No description provided for @parentSettingsPinValidationDigits.
  ///
  /// In en, this message translates to:
  /// **'PIN must be 4 digits'**
  String get parentSettingsPinValidationDigits;

  /// No description provided for @parentSettingsPinValidationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter a 4-digit PIN'**
  String get parentSettingsPinValidationEmpty;

  /// No description provided for @parentSettingsPinConfirmValidationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Confirm your PIN'**
  String get parentSettingsPinConfirmValidationEmpty;

  /// No description provided for @parentSettingsPinConfirmValidationMismatch.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match'**
  String get parentSettingsPinConfirmValidationMismatch;

  /// No description provided for @parentSettingsSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save PIN'**
  String get parentSettingsSaveButton;

  /// No description provided for @parentSettingsRemovePin.
  ///
  /// In en, this message translates to:
  /// **'Remove PIN'**
  String get parentSettingsRemovePin;

  /// No description provided for @parentSettingsSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get parentSettingsSaving;

  /// No description provided for @parentSettingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Parent PIN updated'**
  String get parentSettingsSaved;

  /// No description provided for @parentSettingsRemoved.
  ///
  /// In en, this message translates to:
  /// **'Parent PIN removed'**
  String get parentSettingsRemoved;

  /// No description provided for @parentSettingsLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get parentSettingsLanguageLabel;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// No description provided for @parentGateTitle.
  ///
  /// In en, this message translates to:
  /// **'Parent Access'**
  String get parentGateTitle;

  /// No description provided for @parentGateMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter your 4-digit PIN to continue.'**
  String get parentGateMessage;

  /// No description provided for @parentGatePinLabel.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get parentGatePinLabel;

  /// No description provided for @parentGatePinEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your PIN'**
  String get parentGatePinEmpty;

  /// No description provided for @parentGatePinInvalid.
  ///
  /// In en, this message translates to:
  /// **'PIN must be 4 digits'**
  String get parentGatePinInvalid;

  /// No description provided for @parentGatePinIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN'**
  String get parentGatePinIncorrect;

  /// No description provided for @parentGateErrorFix.
  ///
  /// In en, this message translates to:
  /// **'Please fix the errors above.'**
  String get parentGateErrorFix;

  /// No description provided for @parentGateCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get parentGateCancel;

  /// No description provided for @parentGateUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get parentGateUnlock;

  /// No description provided for @exerciseTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Adventure'**
  String get exerciseTypeTitle;

  /// No description provided for @exerciseTypeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What would you like to practise?'**
  String get exerciseTypeSubtitle;

  /// No description provided for @exerciseTypeChangeProfile.
  ///
  /// In en, this message translates to:
  /// **'Change profile'**
  String get exerciseTypeChangeProfile;

  /// No description provided for @exerciseTypeWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get exerciseTypeWelcomeBack;

  /// No description provided for @exerciseDefaultNickname.
  ///
  /// In en, this message translates to:
  /// **'Explorer'**
  String get exerciseDefaultNickname;

  /// No description provided for @profileMenuEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileMenuEdit;

  /// No description provided for @profileMenuSwitch.
  ///
  /// In en, this message translates to:
  /// **'Switch Account'**
  String get profileMenuSwitch;

  /// No description provided for @profileMenuStatistics.
  ///
  /// In en, this message translates to:
  /// **'My Statistics'**
  String get profileMenuStatistics;

  /// No description provided for @profileEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditTitle;

  /// No description provided for @profileUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated!'**
  String get profileUpdateSuccess;

  /// No description provided for @profileUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Could not update profile: {error}'**
  String profileUpdateError(String error);

  /// No description provided for @exerciseMultiplication.
  ///
  /// In en, this message translates to:
  /// **'Multiplication'**
  String get exerciseMultiplication;

  /// No description provided for @exerciseAddition.
  ///
  /// In en, this message translates to:
  /// **'Addition'**
  String get exerciseAddition;

  /// No description provided for @exerciseMultiplicationDescription.
  ///
  /// In en, this message translates to:
  /// **'Master times tables with games and revision.'**
  String get exerciseMultiplicationDescription;

  /// No description provided for @exerciseAdditionDescription.
  ///
  /// In en, this message translates to:
  /// **'Grow your mental maths superpowers.'**
  String get exerciseAdditionDescription;

  /// No description provided for @modeSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a Mode'**
  String get modeSelectionTitle;

  /// No description provided for @modeSelectionHeadingMultiplication.
  ///
  /// In en, this message translates to:
  /// **'Multiplication table'**
  String get modeSelectionHeadingMultiplication;

  /// No description provided for @modeSelectionHeadingAddition.
  ///
  /// In en, this message translates to:
  /// **'Addition facts'**
  String get modeSelectionHeadingAddition;

  /// No description provided for @modeSelectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a number to practise.'**
  String get modeSelectionSubtitle;

  /// No description provided for @modeRevisionCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Revision Mode'**
  String get modeRevisionCardTitle;

  /// No description provided for @modeRevisionCardDescription.
  ///
  /// In en, this message translates to:
  /// **'Review the full table with answers and animations.'**
  String get modeRevisionCardDescription;

  /// No description provided for @modeExerciseCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise Mode'**
  String get modeExerciseCardTitle;

  /// No description provided for @modeExerciseCardDescription.
  ///
  /// In en, this message translates to:
  /// **'Answer questions and earn stars for great accuracy!'**
  String get modeExerciseCardDescription;

  /// No description provided for @tableSelectorLabel.
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get tableSelectorLabel;

  /// No description provided for @revisionTitleMultiplication.
  ///
  /// In en, this message translates to:
  /// **'Multiplication Revision'**
  String get revisionTitleMultiplication;

  /// No description provided for @revisionTitleAddition.
  ///
  /// In en, this message translates to:
  /// **'Addition Revision'**
  String get revisionTitleAddition;

  /// No description provided for @revisionHeadingMultiplication.
  ///
  /// In en, this message translates to:
  /// **'Practise the ×{table} table'**
  String revisionHeadingMultiplication(int table);

  /// No description provided for @revisionHeadingAddition.
  ///
  /// In en, this message translates to:
  /// **'Practise adding {table}'**
  String revisionHeadingAddition(int table);

  /// No description provided for @exerciseModeTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise Style'**
  String get exerciseModeTypeTitle;

  /// No description provided for @exerciseModePrompt.
  ///
  /// In en, this message translates to:
  /// **'How would you like to practise?'**
  String get exerciseModePrompt;

  /// No description provided for @exerciseMultipleChoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Multiple Choice'**
  String get exerciseMultipleChoiceTitle;

  /// No description provided for @exerciseMultipleChoiceDescription.
  ///
  /// In en, this message translates to:
  /// **'Pick the correct answer out of four options. Great for warm-ups!'**
  String get exerciseMultipleChoiceDescription;

  /// No description provided for @exerciseDirectInputTitle.
  ///
  /// In en, this message translates to:
  /// **'Direct Input'**
  String get exerciseDirectInputTitle;

  /// No description provided for @exerciseDirectInputDescription.
  ///
  /// In en, this message translates to:
  /// **'Type the answer yourself to build strong recall.'**
  String get exerciseDirectInputDescription;

  /// No description provided for @exerciseTimedChallengeTitle.
  ///
  /// In en, this message translates to:
  /// **'Timed Challenge'**
  String get exerciseTimedChallengeTitle;

  /// No description provided for @exerciseTimedChallengeDescription.
  ///
  /// In en, this message translates to:
  /// **'Answer as many as you can in {seconds} seconds for bonus stars!'**
  String exerciseTimedChallengeDescription(int seconds);

  /// No description provided for @exerciseNoProfile.
  ///
  /// In en, this message translates to:
  /// **'No profile selected. Please choose a profile first.'**
  String get exerciseNoProfile;

  /// No description provided for @exerciseSolvePrompt.
  ///
  /// In en, this message translates to:
  /// **'Solve:'**
  String get exerciseSolvePrompt;

  /// No description provided for @exerciseTimedBanner.
  ///
  /// In en, this message translates to:
  /// **'Answer as fast as you can!'**
  String get exerciseTimedBanner;

  /// No description provided for @exerciseTimedCountdown.
  ///
  /// In en, this message translates to:
  /// **'{seconds} seconds left'**
  String exerciseTimedCountdown(int seconds);

  /// No description provided for @exerciseTimedGo.
  ///
  /// In en, this message translates to:
  /// **'Go!'**
  String get exerciseTimedGo;

  /// No description provided for @exerciseQuestionProgress.
  ///
  /// In en, this message translates to:
  /// **'Question {current} / {total}'**
  String exerciseQuestionProgress(int current, int total);

  /// No description provided for @exerciseAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get exerciseAnswerLabel;

  /// No description provided for @exerciseSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get exerciseSubmit;

  /// No description provided for @exerciseSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get exerciseSkip;

  /// No description provided for @exerciseSnackbarCorrect.
  ///
  /// In en, this message translates to:
  /// **'Great job!'**
  String get exerciseSnackbarCorrect;

  /// No description provided for @exerciseSnackbarIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Oops, keep trying!'**
  String get exerciseSnackbarIncorrect;

  /// No description provided for @exerciseSnackbarDirectCorrect.
  ///
  /// In en, this message translates to:
  /// **'Yes! Keep going!'**
  String get exerciseSnackbarDirectCorrect;

  /// No description provided for @exerciseSnackbarDirectIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Not quite, you can do it!'**
  String get exerciseSnackbarDirectIncorrect;

  /// No description provided for @exerciseAnswerRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter an answer to continue.'**
  String get exerciseAnswerRequired;

  /// No description provided for @exerciseDigitsOnly.
  ///
  /// In en, this message translates to:
  /// **'Please enter digits only.'**
  String get exerciseDigitsOnly;

  /// No description provided for @resultsNoSession.
  ///
  /// In en, this message translates to:
  /// **'No session data found.'**
  String get resultsNoSession;

  /// No description provided for @resultsBackHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get resultsBackHome;

  /// No description provided for @resultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get resultsTitle;

  /// No description provided for @resultsHeading.
  ///
  /// In en, this message translates to:
  /// **'Well done!'**
  String get resultsHeading;

  /// No description provided for @resultsAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get resultsAccuracy;

  /// No description provided for @resultsCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get resultsCorrect;

  /// No description provided for @resultsMistakes.
  ///
  /// In en, this message translates to:
  /// **'Mistakes'**
  String get resultsMistakes;

  /// No description provided for @resultsTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get resultsTime;

  /// No description provided for @resultsTimedGoal.
  ///
  /// In en, this message translates to:
  /// **'Timed goal'**
  String get resultsTimedGoal;

  /// No description provided for @resultsTimedValue.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s challenge'**
  String resultsTimedValue(int seconds);

  /// No description provided for @resultsAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'Answer: {answer}'**
  String resultsAnswerLabel(int answer);

  /// No description provided for @resultsSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get resultsSkipped;

  /// No description provided for @resultsReplay.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get resultsReplay;

  /// No description provided for @resultsStatistics.
  ///
  /// In en, this message translates to:
  /// **'View statistics'**
  String get resultsStatistics;

  /// No description provided for @statisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} — Statistics'**
  String statisticsTitle(String name);

  /// No description provided for @statisticsPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsPageTitle;

  /// No description provided for @statisticsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Complete an exercise to unlock your stats!'**
  String get statisticsEmpty;

  /// No description provided for @statisticsSessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get statisticsSessions;

  /// No description provided for @statisticsAverageAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Avg accuracy'**
  String get statisticsAverageAccuracy;

  /// No description provided for @statisticsStars.
  ///
  /// In en, this message translates to:
  /// **'Stars earned'**
  String get statisticsStars;

  /// No description provided for @statisticsPracticeTime.
  ///
  /// In en, this message translates to:
  /// **'Practice time'**
  String get statisticsPracticeTime;

  /// No description provided for @statisticsRecentSessions.
  ///
  /// In en, this message translates to:
  /// **'Recent sessions'**
  String get statisticsRecentSessions;

  /// No description provided for @statisticsSessionSummary.
  ///
  /// In en, this message translates to:
  /// **'{operation} — {format}'**
  String statisticsSessionSummary(String operation, String format);

  /// No description provided for @statisticsSessionAccuracy.
  ///
  /// In en, this message translates to:
  /// **'{accuracy}% accuracy'**
  String statisticsSessionAccuracy(int accuracy);

  /// No description provided for @statisticsSessionScore.
  ///
  /// In en, this message translates to:
  /// **'{correct}/{total}'**
  String statisticsSessionScore(int correct, int total);

  /// No description provided for @statisticsOperationMultiplication.
  ///
  /// In en, this message translates to:
  /// **'Multiplication'**
  String get statisticsOperationMultiplication;

  /// No description provided for @statisticsOperationAddition.
  ///
  /// In en, this message translates to:
  /// **'Addition'**
  String get statisticsOperationAddition;

  /// No description provided for @statisticsFormatMultipleChoice.
  ///
  /// In en, this message translates to:
  /// **'Multiple choice'**
  String get statisticsFormatMultipleChoice;

  /// No description provided for @statisticsFormatDirectInput.
  ///
  /// In en, this message translates to:
  /// **'Direct input'**
  String get statisticsFormatDirectInput;

  /// No description provided for @statisticsFormatTimedChallenge.
  ///
  /// In en, this message translates to:
  /// **'Timed challenge'**
  String get statisticsFormatTimedChallenge;

  /// No description provided for @parentSettingsSavingLabel.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get parentSettingsSavingLabel;

  /// No description provided for @loadingGeneric.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingGeneric;

  /// No description provided for @errorRouteNotFound.
  ///
  /// In en, this message translates to:
  /// **'Route not found: {path}'**
  String errorRouteNotFound(String path);

  /// No description provided for @avatarBraveLion.
  ///
  /// In en, this message translates to:
  /// **'Brave Lion'**
  String get avatarBraveLion;

  /// No description provided for @avatarSparklyDino.
  ///
  /// In en, this message translates to:
  /// **'Sparkly Dino'**
  String get avatarSparklyDino;

  /// No description provided for @avatarSpaceExplorer.
  ///
  /// In en, this message translates to:
  /// **'Space Explorer'**
  String get avatarSpaceExplorer;

  /// No description provided for @avatarHappyRobot.
  ///
  /// In en, this message translates to:
  /// **'Happy Robot'**
  String get avatarHappyRobot;

  /// No description provided for @avatarMagicUnicorn.
  ///
  /// In en, this message translates to:
  /// **'Magic Unicorn'**
  String get avatarMagicUnicorn;

  /// No description provided for @avatarCreativePainter.
  ///
  /// In en, this message translates to:
  /// **'Creative Painter'**
  String get avatarCreativePainter;

  /// No description provided for @rewardBrilliantWork.
  ///
  /// In en, this message translates to:
  /// **'Brilliant work!'**
  String get rewardBrilliantWork;

  /// No description provided for @rewardScoredAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Scored {accuracy}% accuracy.'**
  String rewardScoredAccuracy(String accuracy);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
