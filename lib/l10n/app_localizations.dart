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

  /// No description provided for @questionOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'Question Order'**
  String get questionOrderLabel;

  /// No description provided for @questionOrderShuffled.
  ///
  /// In en, this message translates to:
  /// **'Shuffled (Random)'**
  String get questionOrderShuffled;

  /// No description provided for @questionOrderOrdered.
  ///
  /// In en, this message translates to:
  /// **'Ordered (Sequential)'**
  String get questionOrderOrdered;

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

  /// No description provided for @tableSelectorSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 table selected} other{{count} tables selected}}'**
  String tableSelectorSelectedCount(int count);

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

  /// No description provided for @exerciseDifficultyLabel.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get exerciseDifficultyLabel;

  /// No description provided for @exerciseDifficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get exerciseDifficultyEasy;

  /// No description provided for @exerciseDifficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get exerciseDifficultyMedium;

  /// No description provided for @exerciseDifficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get exerciseDifficultyHard;

  /// No description provided for @exerciseDifficultyEasyDescription.
  ///
  /// In en, this message translates to:
  /// **'No time limit per question.'**
  String get exerciseDifficultyEasyDescription;

  /// No description provided for @exerciseDifficultyMediumDescription.
  ///
  /// In en, this message translates to:
  /// **'{seconds} seconds per question. Keep a steady pace!'**
  String exerciseDifficultyMediumDescription(int seconds);

  /// No description provided for @exerciseDifficultyHardDescription.
  ///
  /// In en, this message translates to:
  /// **'Only {seconds} seconds per question. Stay sharp!'**
  String exerciseDifficultyHardDescription(int seconds);

  /// No description provided for @exerciseQuestionTimer.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s left'**
  String exerciseQuestionTimer(int seconds);

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

  /// No description provided for @revisionModeTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Revision Style'**
  String get revisionModeTypeTitle;

  /// No description provided for @revisionModePrompt.
  ///
  /// In en, this message translates to:
  /// **'How would you like to revise?'**
  String get revisionModePrompt;

  /// No description provided for @revisionListViewTitle.
  ///
  /// In en, this message translates to:
  /// **'List View'**
  String get revisionListViewTitle;

  /// No description provided for @revisionListViewDescription.
  ///
  /// In en, this message translates to:
  /// **'See all operations and answers in a scrollable list.'**
  String get revisionListViewDescription;

  /// No description provided for @revisionFlashCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Flash Cards'**
  String get revisionFlashCardTitle;

  /// No description provided for @revisionFlashCardDescription.
  ///
  /// In en, this message translates to:
  /// **'Interactive cards to test your recall. Flip to see answers!'**
  String get revisionFlashCardDescription;

  /// No description provided for @flashCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Flash Card Revision'**
  String get flashCardTitle;

  /// No description provided for @flashCardProgress.
  ///
  /// In en, this message translates to:
  /// **'Card {current} of {total}'**
  String flashCardProgress(int current, int total);

  /// No description provided for @flashCardTapToReveal.
  ///
  /// In en, this message translates to:
  /// **'Tap to reveal answer'**
  String get flashCardTapToReveal;

  /// No description provided for @flashCardPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get flashCardPrevious;

  /// No description provided for @flashCardNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get flashCardNext;

  /// No description provided for @flashCardGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get flashCardGotIt;

  /// No description provided for @flashCardReviewAgain.
  ///
  /// In en, this message translates to:
  /// **'Review Again'**
  String get flashCardReviewAgain;

  /// No description provided for @flashCardSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Revision Complete!'**
  String get flashCardSummaryTitle;

  /// No description provided for @flashCardSummaryMastered.
  ///
  /// In en, this message translates to:
  /// **'Cards mastered'**
  String get flashCardSummaryMastered;

  /// No description provided for @flashCardSummaryToReview.
  ///
  /// In en, this message translates to:
  /// **'To review'**
  String get flashCardSummaryToReview;

  /// No description provided for @flashCardSummaryNotAnswered.
  ///
  /// In en, this message translates to:
  /// **'Not answered'**
  String get flashCardSummaryNotAnswered;

  /// No description provided for @flashCardRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get flashCardRestart;

  /// No description provided for @flashCardReviewMarked.
  ///
  /// In en, this message translates to:
  /// **'Review Marked Cards'**
  String get flashCardReviewMarked;

  /// No description provided for @parentDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Advanced Analytics'**
  String get parentDashboardTitle;

  /// No description provided for @parentDashboardSelectProfile.
  ///
  /// In en, this message translates to:
  /// **'Select Child'**
  String get parentDashboardSelectProfile;

  /// No description provided for @parentDashboardNoProfile.
  ///
  /// In en, this message translates to:
  /// **'No profile selected'**
  String get parentDashboardNoProfile;

  /// No description provided for @parentDashboardMultiplication.
  ///
  /// In en, this message translates to:
  /// **'Multiplication'**
  String get parentDashboardMultiplication;

  /// No description provided for @parentDashboardAddition.
  ///
  /// In en, this message translates to:
  /// **'Addition'**
  String get parentDashboardAddition;

  /// No description provided for @parentDashboardTableLabel.
  ///
  /// In en, this message translates to:
  /// **'Table {table}'**
  String parentDashboardTableLabel(int table);

  /// No description provided for @parentDashboardExerciseStats.
  ///
  /// In en, this message translates to:
  /// **'Exercise Statistics'**
  String get parentDashboardExerciseStats;

  /// No description provided for @parentDashboardFlashCardStats.
  ///
  /// In en, this message translates to:
  /// **'Flash Card Status'**
  String get parentDashboardFlashCardStats;

  /// No description provided for @parentDashboardTotalAttempts.
  ///
  /// In en, this message translates to:
  /// **'Total attempts'**
  String get parentDashboardTotalAttempts;

  /// No description provided for @parentDashboardTotalQuestions.
  ///
  /// In en, this message translates to:
  /// **'Total questions answered'**
  String get parentDashboardTotalQuestions;

  /// No description provided for @parentDashboardSuccessRate.
  ///
  /// In en, this message translates to:
  /// **'Success rate'**
  String get parentDashboardSuccessRate;

  /// No description provided for @parentDashboardProblemOperations.
  ///
  /// In en, this message translates to:
  /// **'Problem Operations'**
  String get parentDashboardProblemOperations;

  /// No description provided for @parentDashboardNoProblemOperations.
  ///
  /// In en, this message translates to:
  /// **'No problem operations identified'**
  String get parentDashboardNoProblemOperations;

  /// No description provided for @parentDashboardNoExerciseData.
  ///
  /// In en, this message translates to:
  /// **'No exercise data yet'**
  String get parentDashboardNoExerciseData;

  /// No description provided for @parentDashboardOperationFailed.
  ///
  /// In en, this message translates to:
  /// **'{expression} — Failed {failures}/{total} times ({rate}%)'**
  String parentDashboardOperationFailed(
    String expression,
    int failures,
    int total,
    String rate,
  );

  /// No description provided for @parentDashboardCardsReviewed.
  ///
  /// In en, this message translates to:
  /// **'Cards reviewed'**
  String get parentDashboardCardsReviewed;

  /// No description provided for @parentDashboardCardsMastered.
  ///
  /// In en, this message translates to:
  /// **'Cards mastered'**
  String get parentDashboardCardsMastered;

  /// No description provided for @parentDashboardCardsToReview.
  ///
  /// In en, this message translates to:
  /// **'Cards to review'**
  String get parentDashboardCardsToReview;

  /// No description provided for @parentDashboardMasteryRate.
  ///
  /// In en, this message translates to:
  /// **'Mastery rate'**
  String get parentDashboardMasteryRate;

  /// No description provided for @parentDashboardNoFlashCardData.
  ///
  /// In en, this message translates to:
  /// **'No flash card data yet'**
  String get parentDashboardNoFlashCardData;

  /// No description provided for @parentDashboardMasteredCards.
  ///
  /// In en, this message translates to:
  /// **'Mastered Cards'**
  String get parentDashboardMasteredCards;

  /// No description provided for @parentDashboardReviewCards.
  ///
  /// In en, this message translates to:
  /// **'Cards to Review'**
  String get parentDashboardReviewCards;

  /// No description provided for @parentDashboardResetTable.
  ///
  /// In en, this message translates to:
  /// **'Reset Table Progress'**
  String get parentDashboardResetTable;

  /// No description provided for @parentDashboardResetAll.
  ///
  /// In en, this message translates to:
  /// **'Reset All Progress'**
  String get parentDashboardResetAll;

  /// No description provided for @parentDashboardResetTableConfirm.
  ///
  /// In en, this message translates to:
  /// **'Reset progress for table {table}?'**
  String parentDashboardResetTableConfirm(int table);

  /// No description provided for @parentDashboardResetTableMessage.
  ///
  /// In en, this message translates to:
  /// **'This will delete all exercise sessions and flash card results for this table. This action cannot be undone.'**
  String get parentDashboardResetTableMessage;

  /// No description provided for @parentDashboardResetAllConfirm.
  ///
  /// In en, this message translates to:
  /// **'Reset all progress?'**
  String get parentDashboardResetAllConfirm;

  /// No description provided for @parentDashboardResetAllMessage.
  ///
  /// In en, this message translates to:
  /// **'This will delete all exercise sessions and flash card results for {name}. This action cannot be undone.'**
  String parentDashboardResetAllMessage(String name);

  /// No description provided for @parentDashboardResetCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get parentDashboardResetCancel;

  /// No description provided for @parentDashboardResetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get parentDashboardResetConfirm;

  /// No description provided for @parentDashboardResetTableSuccess.
  ///
  /// In en, this message translates to:
  /// **'Table {table} progress reset'**
  String parentDashboardResetTableSuccess(int table);

  /// No description provided for @parentDashboardResetAllSuccess.
  ///
  /// In en, this message translates to:
  /// **'All progress reset'**
  String get parentDashboardResetAllSuccess;

  /// No description provided for @parentDashboardAdvancedAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Advanced Analytics'**
  String get parentDashboardAdvancedAnalytics;

  /// No description provided for @difficultyLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Difficulty Level'**
  String get difficultyLevelLabel;

  /// No description provided for @difficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// No description provided for @timerWarning.
  ///
  /// In en, this message translates to:
  /// **'Time running out!'**
  String get timerWarning;

  /// No description provided for @exerciseVoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get exerciseVoiceTitle;

  /// No description provided for @exerciseVoiceDescription.
  ///
  /// In en, this message translates to:
  /// **'The app reads the question aloud: say your answer!'**
  String get exerciseVoiceDescription;

  /// No description provided for @exerciseVoiceDownloadRequired.
  ///
  /// In en, this message translates to:
  /// **'Download required ({size})'**
  String exerciseVoiceDownloadRequired(String size);

  /// No description provided for @exerciseVoiceDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading… {percent}%'**
  String exerciseVoiceDownloading(int percent);

  /// No description provided for @exerciseVoiceDownloadError.
  ///
  /// In en, this message translates to:
  /// **'Download failed. Tap to try again.'**
  String get exerciseVoiceDownloadError;

  /// No description provided for @exerciseVoiceTtsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The English voice is not installed on this device: ask a grown-up to install it in the device\'s text-to-speech settings.'**
  String get exerciseVoiceTtsUnavailable;

  /// No description provided for @exerciseVoiceMicDenied.
  ///
  /// In en, this message translates to:
  /// **'Allow microphone access in the device settings to use this mode.'**
  String get exerciseVoiceMicDenied;

  /// No description provided for @voiceListening.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get voiceListening;

  /// No description provided for @voiceSpeaking.
  ///
  /// In en, this message translates to:
  /// **'Listen carefully…'**
  String get voiceSpeaking;

  /// No description provided for @voiceReplay.
  ///
  /// In en, this message translates to:
  /// **'Listen again'**
  String get voiceReplay;

  /// No description provided for @voiceReadMultiplication.
  ///
  /// In en, this message translates to:
  /// **'{a} times {b}'**
  String voiceReadMultiplication(int a, int b);

  /// No description provided for @voiceReadAddition.
  ///
  /// In en, this message translates to:
  /// **'{a} plus {b}'**
  String voiceReadAddition(int a, int b);

  /// No description provided for @voiceRetry.
  ///
  /// In en, this message translates to:
  /// **'I didn\'t catch that, please say it again.'**
  String get voiceRetry;

  /// No description provided for @voiceCorrect.
  ///
  /// In en, this message translates to:
  /// **'Well done!'**
  String get voiceCorrect;

  /// No description provided for @voiceIncorrect.
  ///
  /// In en, this message translates to:
  /// **'No, it was {answer}.'**
  String voiceIncorrect(int answer);

  /// No description provided for @voiceEngineError.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition could not start.'**
  String get voiceEngineError;

  /// No description provided for @resultsVoiceAnswerTime.
  ///
  /// In en, this message translates to:
  /// **'{answer} · {seconds} s'**
  String resultsVoiceAnswerTime(String answer, String seconds);

  /// No description provided for @statisticsFormatVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get statisticsFormatVoice;

  /// No description provided for @parentSettingsVoiceModels.
  ///
  /// In en, this message translates to:
  /// **'Voice models: {size}'**
  String parentSettingsVoiceModels(String size);

  /// No description provided for @parentSettingsVoiceModelsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get parentSettingsVoiceModelsDelete;

  /// No description provided for @parentSettingsVoiceModelsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete the voice models? They will have to be downloaded again to use the Voice mode.'**
  String get parentSettingsVoiceModelsDeleteConfirm;

  /// No description provided for @parentSettingsVoiceModelsDeleted.
  ///
  /// In en, this message translates to:
  /// **'Voice models deleted'**
  String get parentSettingsVoiceModelsDeleted;

  /// No description provided for @parentSettingsVoiceCredits.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition: sherpa-onnx (k2-fsa, Apache-2.0) · Kroko ASR models (Banafo, CC-BY-SA)'**
  String get parentSettingsVoiceCredits;

  /// No description provided for @voiceTtsFailed.
  ///
  /// In en, this message translates to:
  /// **'I can\'t speak on this device: read the question on the screen and say your answer.'**
  String get voiceTtsFailed;

  /// No description provided for @voicePaused.
  ///
  /// In en, this message translates to:
  /// **'Paused. Tap Listen again to continue.'**
  String get voicePaused;

  /// No description provided for @voiceLoading.
  ///
  /// In en, this message translates to:
  /// **'Getting the voice ready… (the first time can take a few seconds)'**
  String get voiceLoading;
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
