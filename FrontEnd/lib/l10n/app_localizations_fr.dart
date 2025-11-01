// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get alreadyAnAccountLogin => 'Déjà un compte ? Connectez-vous';

  @override
  String get about => 'À propos';

  @override
  String get aboutText =>
      'Cette application vous est proposée par Thomas Simmer.';

  @override
  String get cancel => 'Annuler';

  @override
  String get changePassword => 'Changer mon mot de passe';

  @override
  String get challenges => 'Défis';

  @override
  String get confirmDeletion => 'Confirmer la suppression';

  @override
  String get confirmDeletionQuestion =>
      'Confirmez-vous la suppression de la session sur cet appareil ?';

  @override
  String get comeBack => 'Revenir en arrière';

  @override
  String get currentPassword => 'Mot de passe actuel';

  @override
  String get dark => 'Sombre';

  @override
  String get defaultError => 'Une erreur s\'est produite. Veuillez réessayer.';

  @override
  String get delete => 'Supprimer';

  @override
  String get devices => 'Mes appareils';

  @override
  String deviceInfo(String isMobile, String os, String browser, String model) {
    String _temp0 = intl.Intl.selectLogic(
      isMobile,
      {
        'true': 'Appareil mobile',
        'false': 'Ordinateur',
        'other': 'Inconnu',
      },
    );
    String _temp1 = intl.Intl.selectLogic(
      os,
      {
        'null': '. ',
        'other': ' exécutant $os. ',
      },
    );
    String _temp2 = intl.Intl.selectLogic(
      browser,
      {
        'null': 'Application',
        'other': 'Navigateur : $browser',
      },
    );
    String _temp3 = intl.Intl.selectLogic(
      model,
      {
        'null': '',
        'other': 'Modèle: $model.',
      },
    );
    return '$_temp0$_temp1$_temp2. $_temp3';
  }

  @override
  String get deviceDeleteSuccessful =>
      'Vous avez arrêté la session sur cet appareil avec succès.';

  @override
  String get disableTwoFA => 'Désactiver';

  @override
  String get enable => 'Activer';

  @override
  String get enterOneTimePassword =>
      'Entrez le code à 6 chiffres généré par votre application pour confirmer votre authentification.';

  @override
  String get enterPassword => 'Entrez votre mot de passe.';

  @override
  String get enterRecoveryCode => 'Entrez un de vos codes de récupération.';

  @override
  String get enterUsername => 'Entrez votre nom d\'utilisateur.';

  @override
  String get enterValidationCode =>
      'Entrez le code de votre application d\'authentification.';

  @override
  String get failedToLoadProfile => 'Impossible de charger le profil.';

  @override
  String get forbiddenError =>
      'Vous n\'êtes pas autorisé à effectuer cette action.';

  @override
  String get generateNewQrCode => 'Générer un nouveau QR-code';

  @override
  String get goToTwoFASetup => 'Activer';

  @override
  String get habits => 'Habitudes';

  @override
  String hello(String userName) {
    return 'Bonjour $userName';
  }

  @override
  String get home => 'Accueil';

  @override
  String get internalServerError =>
      'Une erreur interne du serveur s\'est produite. Veuillez réessayer.';

  @override
  String get invalidOneTimePasswordError =>
      'Mot de passe à usage unique invalide. Veuillez réessayer.';

  @override
  String get invalidRequestError =>
      'La demande que vous avez effectuée n\'a pas été acceptée par le serveur.';

  @override
  String get invalidResponseError =>
      'La réponse du serveur n\'a pas pu être traitée.';

  @override
  String get invalidUsernameOrCodeOrRecoveryCodeError =>
      'Nom d\'utilisateur, mot de passe à usage unique ou code de récupération invalide. Veuillez réessayer.';

  @override
  String get invalidUsernameOrPasswordError =>
      'Nom d\'utilisateur ou mot de passe invalide. Veuillez réessayer.';

  @override
  String get invalidUsernameOrPasswordOrRecoveryCodeError =>
      'Nom d\'utilisateur, mot de passe ou code de récupération invalide. Veuillez réessayer.';

  @override
  String get invalidUsernameOrRecoveryCodeError =>
      'Nom d\'utilisateur ou code de récupération invalide. Veuillez réessayer.';

  @override
  String get keepRecoveryCodesSafe =>
      'Merci de garder ces codes de récupération bien à l\'abri.\nIls seront nécessaires si vous perdez votre mot de passe ou l\'acès à votre application d\'authentification.';

  @override
  String get language => 'Langue';

  @override
  String get lastActivityDate => 'Date de la dernière activité :';

  @override
  String get light => 'Clair';

  @override
  String get logIn => 'Se connecter';

  @override
  String get loginSuccessful => 'Vous êtes bien connecté.';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get logoutSuccessful => 'Vous vous êtes bien déconnecté.';

  @override
  String get messages => 'Messages';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get next => 'Suivant';

  @override
  String get noAccountCreateOne => 'Pas de compte ? Créez-le ici.';

  @override
  String get noContent => 'Aucun contenu à afficher';

  @override
  String get noDevices => 'Aucun appareil à afficher';

  @override
  String get noDeviceInfo => 'Aucune information sur l\'appareil à afficher';

  @override
  String get noRecoveryCodeAvailable =>
      'Aucun code de récupération disponible.';

  @override
  String get password => 'Mot de passe';

  @override
  String get passwordForgotten => 'Vous avez oublié votre mot de passe ?';

  @override
  String get passwordMustBeChangedError =>
      'Votre mot de passe doit être changé pour pouvoir vous connecter.';

  @override
  String get passwordNotComplexEnough =>
      'Votre mot de passe doit contenir au moins une lettre, un chiffre et un caractère spécial.';

  @override
  String get passwordNotExpiredError =>
      'Votre mot de passe n\'est pas expiré. Vous ne pouvez pas le changer de cette manière.';

  @override
  String get passwordTooShortError =>
      'Votre mot de passe doit contenir au moins 8 caractères.';

  @override
  String get passwordUpdateSuccessful =>
      'Votre mot de passe a bien été mis à jour';

  @override
  String get pleaseLoginOrSignUp =>
      'Merci de vous connecter ou de vous inscrire pour continuer.';

  @override
  String get profile => 'Profil';

  @override
  String get profileSettings => 'Paramètres du profil';

  @override
  String get profileUpdateSuccessful =>
      'Vos informations ont bien été sauvegardées.';

  @override
  String get qrCodeSecretKeyCopied =>
      'La clé secrète du QR-code a été copiée dans le presse-papiers.';

  @override
  String get recoverAccount => 'Récupération de compte';

  @override
  String get recoveryCode => 'Code de récupération';

  @override
  String get recoveryCodesCopied =>
      'Les codes de récupération ont été copiés dans le presse-papiers.';

  @override
  String get refreshTokenExpiredError =>
      'Votre session a expiré. Veuillez vous reconnecter.';

  @override
  String get regenerateQrCode => 'Régénérer un QR-code';

  @override
  String get save => 'Enregistrer';

  @override
  String get selectLanguage => 'Sélection de la langue';

  @override
  String get selectTheme => 'Sélection du thème';

  @override
  String get setNewPassword => 'Renseignez votre nouveau mot de passe.';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get theme => 'Thème';

  @override
  String get twoFA => 'Authentification à deux facteurs';

  @override
  String get twoFAInvitation =>
      'La sécurité et la confidentialité sont nos principales priorités.\nVeuillez activer l\'authentification à deux facteurs pour protéger votre compte des attaques par force brute.';

  @override
  String get twoFAIsWellSetup =>
      'L\'authentification à deux facteurs est correctement configurée sur votre compte.';

  @override
  String get twoFAScanQrCode =>
      'Scannez ce QR-code dans votre application d\'authentification.';

  @override
  String twoFASecretKey(String secretKey) {
    return 'Votre clé secrète est : $secretKey';
  }

  @override
  String get twoFASetup =>
      'Activez l\'authentification à deux facteurs pour sécuriser votre compte.';

  @override
  String get twoFactorAuthenticationNotEnabledError =>
      'L\'authentification à deux facteurs n\'est pas activée sur votre compte.';

  @override
  String get unableToLoadRecoveryCodes =>
      'Impossible de charger les codes de récupération.';

  @override
  String get unauthorizedError =>
      'Vous n\'êtes pas autorisé à effectuer cette opération.';

  @override
  String get unknown => 'Inconnue';

  @override
  String get unknownError =>
      'Une erreur inattendue s\'est produite. Veuillez réessayer.';

  @override
  String get updatePassword =>
      'Renseignez votre mot de passe actuel et le nouveau.';

  @override
  String get userAlreadyExistingError =>
      'Un utilisateur avec ce nom d\'utilisateur existe déjà. Veuillez en choisir un autre.';

  @override
  String get userNotFoundError => 'Utilisateur non trouvé.';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get usernameNotRespectingRulesError =>
      'Votre nom d\'utilisateur doit respecter ces règles :\n - commencer et finir par une lettre ou un chiffre\n - les caractères spéciaux autorisés sont . _ -\n - pas de caractères spéciaux consécutifs.';

  @override
  String get usernameWrongSizeError =>
      'La longueur de votre nom d\'utilisateur doit être comprise entre 3 et 20 caractères.';

  @override
  String get validationCode => 'Code de validation';

  @override
  String get validationCodeCorrect => 'Votre code de validation est correct !';

  @override
  String get verify => 'Vérifier';

  @override
  String get welcome => 'Bienvenue sur Flutter Actix App.';

  @override
  String get previous => 'Précédent';
}
