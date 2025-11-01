import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('es'),
    Locale('fr')
  ];

  /// No description provided for @alreadyAnAccountLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get alreadyAnAccountLogin;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutText.
  ///
  /// In en, this message translates to:
  /// **'This application is proposed to you by Thomas Simmer.'**
  String get aboutText;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @challenges.
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get challenges;

  /// No description provided for @confirmDeletion.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get confirmDeletion;

  /// No description provided for @confirmDeletionQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the session on this device?'**
  String get confirmDeletionQuestion;

  /// No description provided for @comeBack.
  ///
  /// In en, this message translates to:
  /// **'Come Back'**
  String get comeBack;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @defaultError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get defaultError;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @devices.
  ///
  /// In en, this message translates to:
  /// **'My devices'**
  String get devices;

  /// No description provided for @deviceInfo.
  ///
  /// In en, this message translates to:
  /// **'{isMobile, select, true {Mobile device} false {Computer} other {Unknown}}{os, select, null {. } other { running on {os}. }}{browser, select, null {App} other {Browser: {browser}}}. {model, select, null {} other {Model: {model}.}}'**
  String deviceInfo(String isMobile, String os, String browser, String model);

  /// No description provided for @deviceDeleteSuccessful.
  ///
  /// In en, this message translates to:
  /// **'You successfully stopped the session on this device'**
  String get deviceDeleteSuccessful;

  /// No description provided for @disableTwoFA.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disableTwoFA;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @enterOneTimePassword.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code generated by your app to confirm your authentication.'**
  String get enterOneTimePassword;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get enterPassword;

  /// No description provided for @enterRecoveryCode.
  ///
  /// In en, this message translates to:
  /// **'Enter one of your recovery codes.'**
  String get enterRecoveryCode;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter your username.'**
  String get enterUsername;

  /// No description provided for @enterValidationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the code from your authentication app.'**
  String get enterValidationCode;

  /// No description provided for @failedToLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile'**
  String get failedToLoadProfile;

  /// No description provided for @forbiddenError.
  ///
  /// In en, this message translates to:
  /// **'You are not authorized to perform this action.'**
  String get forbiddenError;

  /// No description provided for @generateNewQrCode.
  ///
  /// In en, this message translates to:
  /// **'Generate a new QR code'**
  String get generateNewQrCode;

  /// No description provided for @goToTwoFASetup.
  ///
  /// In en, this message translates to:
  /// **'Set up two-factor authentication'**
  String get goToTwoFASetup;

  /// No description provided for @habits.
  ///
  /// In en, this message translates to:
  /// **'Employees'**
  String get habits;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello {userName}'**
  String hello(String userName);

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @internalServerError.
  ///
  /// In en, this message translates to:
  /// **'An internal server error occurred. Please try again.'**
  String get internalServerError;

  /// No description provided for @invalidOneTimePasswordError.
  ///
  /// In en, this message translates to:
  /// **'Invalid one-time password. Please try again.'**
  String get invalidOneTimePasswordError;

  /// No description provided for @invalidRequestError.
  ///
  /// In en, this message translates to:
  /// **'The request you made was not accepted by the server.'**
  String get invalidRequestError;

  /// No description provided for @invalidResponseError.
  ///
  /// In en, this message translates to:
  /// **'The response from the server could not be processed.'**
  String get invalidResponseError;

  /// No description provided for @invalidUsernameOrCodeOrRecoveryCodeError.
  ///
  /// In en, this message translates to:
  /// **'Invalid username, one-time password, or recovery code. Please try again.'**
  String get invalidUsernameOrCodeOrRecoveryCodeError;

  /// No description provided for @invalidUsernameOrPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password. Please try again.'**
  String get invalidUsernameOrPasswordError;

  /// No description provided for @invalidUsernameOrPasswordOrRecoveryCodeError.
  ///
  /// In en, this message translates to:
  /// **'Invalid username, password, or recovery code. Please try again.'**
  String get invalidUsernameOrPasswordOrRecoveryCodeError;

  /// No description provided for @invalidUsernameOrRecoveryCodeError.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or recovery code. Please try again.'**
  String get invalidUsernameOrRecoveryCodeError;

  /// No description provided for @keepRecoveryCodesSafe.
  ///
  /// In en, this message translates to:
  /// **'Please keep these recovery codes safe.\nThey are necessary if you lose your password or access to your 2FA application.'**
  String get keepRecoveryCodesSafe;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @lastActivityDate.
  ///
  /// In en, this message translates to:
  /// **'Last activity date:'**
  String get lastActivityDate;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;

  /// No description provided for @loginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'You successfully logged in.'**
  String get loginSuccessful;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @logoutSuccessful.
  ///
  /// In en, this message translates to:
  /// **'You successfully logged out.'**
  String get logoutSuccessful;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @noAccountCreateOne.
  ///
  /// In en, this message translates to:
  /// **'No account? Create one here.'**
  String get noAccountCreateOne;

  /// No description provided for @noContent.
  ///
  /// In en, this message translates to:
  /// **'No content to display'**
  String get noContent;

  /// No description provided for @noDevices.
  ///
  /// In en, this message translates to:
  /// **'No device to display'**
  String get noDevices;

  /// No description provided for @noDeviceInfo.
  ///
  /// In en, this message translates to:
  /// **'No device information to display'**
  String get noDeviceInfo;

  /// No description provided for @noRecoveryCodeAvailable.
  ///
  /// In en, this message translates to:
  /// **'No recovery codes available.'**
  String get noRecoveryCodeAvailable;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordForgotten.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get passwordForgotten;

  /// No description provided for @passwordMustBeChangedError.
  ///
  /// In en, this message translates to:
  /// **'You need to change your password to log in.'**
  String get passwordMustBeChangedError;

  /// No description provided for @passwordNotComplexEnough.
  ///
  /// In en, this message translates to:
  /// **'Your password must contain at least a letter, a digit, and a special character.'**
  String get passwordNotComplexEnough;

  /// No description provided for @passwordNotExpiredError.
  ///
  /// In en, this message translates to:
  /// **'Your password is not expired, so it cannot be changed this way.'**
  String get passwordNotExpiredError;

  /// No description provided for @passwordTooShortError.
  ///
  /// In en, this message translates to:
  /// **'Your password must be at least 8 characters long.'**
  String get passwordTooShortError;

  /// No description provided for @passwordUpdateSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Your password was successfully updated.'**
  String get passwordUpdateSuccessful;

  /// No description provided for @pleaseLoginOrSignUp.
  ///
  /// In en, this message translates to:
  /// **'Please log in or sign up to continue.'**
  String get pleaseLoginOrSignUp;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile Settings'**
  String get profileSettings;

  /// No description provided for @profileUpdateSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Profile information saved.'**
  String get profileUpdateSuccessful;

  /// No description provided for @qrCodeSecretKeyCopied.
  ///
  /// In en, this message translates to:
  /// **'QR code secret key copied to clipboard.'**
  String get qrCodeSecretKeyCopied;

  /// No description provided for @recoverAccount.
  ///
  /// In en, this message translates to:
  /// **'Recover Account'**
  String get recoverAccount;

  /// No description provided for @recoveryCode.
  ///
  /// In en, this message translates to:
  /// **'Recovery code'**
  String get recoveryCode;

  /// No description provided for @recoveryCodesCopied.
  ///
  /// In en, this message translates to:
  /// **'Recovery codes copied to clipboard.'**
  String get recoveryCodesCopied;

  /// No description provided for @refreshTokenExpiredError.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again.'**
  String get refreshTokenExpiredError;

  /// No description provided for @regenerateQrCode.
  ///
  /// In en, this message translates to:
  /// **'Regenerate QR code'**
  String get regenerateQrCode;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @selectTheme.
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get selectTheme;

  /// No description provided for @setNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password.'**
  String get setNewPassword;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @twoFA.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication'**
  String get twoFA;

  /// No description provided for @twoFAInvitation.
  ///
  /// In en, this message translates to:
  /// **'Security and privacy are our top priorities.\nPlease set up two-factor authentication to protect your account from brute-force attacks.'**
  String get twoFAInvitation;

  /// No description provided for @twoFAIsWellSetup.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication is successfully set up for your account.'**
  String get twoFAIsWellSetup;

  /// No description provided for @twoFAScanQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan this QR code with your authentication app.'**
  String get twoFAScanQrCode;

  /// No description provided for @twoFASecretKey.
  ///
  /// In en, this message translates to:
  /// **'Your secret key is: {secretKey}'**
  String twoFASecretKey(String secretKey);

  /// No description provided for @twoFASetup.
  ///
  /// In en, this message translates to:
  /// **'Enable two-factor authentication to secure your account.'**
  String get twoFASetup;

  /// No description provided for @twoFactorAuthenticationNotEnabledError.
  ///
  /// In en, this message translates to:
  /// **'Two-factor authentication is not enabled for your account.'**
  String get twoFactorAuthenticationNotEnabledError;

  /// No description provided for @unableToLoadRecoveryCodes.
  ///
  /// In en, this message translates to:
  /// **'Unable to load recovery codes.'**
  String get unableToLoadRecoveryCodes;

  /// No description provided for @unauthorizedError.
  ///
  /// In en, this message translates to:
  /// **'You are not authorized to perform this action.'**
  String get unauthorizedError;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get unknownError;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your current and new password.'**
  String get updatePassword;

  /// No description provided for @userAlreadyExistingError.
  ///
  /// In en, this message translates to:
  /// **'A user with this username already exists. Please choose another.'**
  String get userAlreadyExistingError;

  /// No description provided for @userNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'User not found.'**
  String get userNotFoundError;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @usernameNotRespectingRulesError.
  ///
  /// In en, this message translates to:
  /// **'Your username must follow these rules:\n - Start and end with a letter or digit\n - Allowed special characters are . _ -\n - No consecutive special characters'**
  String get usernameNotRespectingRulesError;

  /// No description provided for @usernameWrongSizeError.
  ///
  /// In en, this message translates to:
  /// **'Username length must be between 3 and 20 characters.'**
  String get usernameWrongSizeError;

  /// No description provided for @validationCode.
  ///
  /// In en, this message translates to:
  /// **'Validation code'**
  String get validationCode;

  /// No description provided for @validationCodeCorrect.
  ///
  /// In en, this message translates to:
  /// **'Your validation code is correct!'**
  String get validationCodeCorrect;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome on the Flutter Actix App.'**
  String get welcome;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;
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
      <String>['en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
