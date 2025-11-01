// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get alreadyAnAccountLogin => '¿Ya tienes una cuenta? Inicia sesión';

  @override
  String get about => 'Acerca de';

  @override
  String get aboutText => 'Esta aplicación es propuesta por Thomas Simmer.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get changePassword => 'Cambiar contraseña';

  @override
  String get challenges => 'Retos';

  @override
  String get confirmDeletion => 'Confirmar eliminación';

  @override
  String get confirmDeletionQuestion =>
      '¿Seguro que quieres eliminar la sesión en este dispositivo?';

  @override
  String get comeBack => 'Regresar';

  @override
  String get currentPassword => 'Contraseña actual';

  @override
  String get dark => 'Oscuro';

  @override
  String get defaultError => 'Ocurrió un error. Inténtalo de nuevo.';

  @override
  String get delete => 'Eliminar';

  @override
  String get devices => 'Mis dispositivos';

  @override
  String deviceInfo(String isMobile, String os, String browser, String model) {
    String _temp0 = intl.Intl.selectLogic(
      isMobile,
      {
        'true': 'Dispositivo móvil',
        'false': 'Computadora',
        'other': 'Desconocido',
      },
    );
    String _temp1 = intl.Intl.selectLogic(
      os,
      {
        'null': '. ',
        'other': ' con $os. ',
      },
    );
    String _temp2 = intl.Intl.selectLogic(
      browser,
      {
        'null': 'App',
        'other': 'Navegador: $browser',
      },
    );
    String _temp3 = intl.Intl.selectLogic(
      model,
      {
        'null': '',
        'other': 'Modelo: $model.',
      },
    );
    return '$_temp0$_temp1$_temp2. $_temp3';
  }

  @override
  String get deviceDeleteSuccessful =>
      'Detuviste la sesión en este dispositivo correctamente';

  @override
  String get disableTwoFA => 'Desactivar';

  @override
  String get enable => 'Activar';

  @override
  String get enterOneTimePassword =>
      'Ingresa el código de 6 dígitos generado por tu app para confirmar tu autenticación.';

  @override
  String get enterPassword => 'Ingresa tu contraseña.';

  @override
  String get enterRecoveryCode => 'Ingresa uno de tus códigos de recuperación.';

  @override
  String get enterUsername => 'Ingresa tu usuario.';

  @override
  String get enterValidationCode =>
      'Ingresa el código de tu app de autenticación.';

  @override
  String get failedToLoadProfile => 'No se pudo cargar el perfil';

  @override
  String get forbiddenError => 'No estás autorizado para realizar esta acción.';

  @override
  String get generateNewQrCode => 'Generar un nuevo código QR';

  @override
  String get goToTwoFASetup => 'Configurar autenticación de dos factores';

  @override
  String get habits => 'Hábitos';

  @override
  String hello(String userName) {
    return 'Hola $userName';
  }

  @override
  String get home => 'Inicio';

  @override
  String get internalServerError =>
      'Ocurrió un error interno. Inténtalo de nuevo.';

  @override
  String get invalidOneTimePasswordError =>
      'Código de un solo uso inválido. Inténtalo de nuevo.';

  @override
  String get invalidRequestError =>
      'Tu solicitud no fue aceptada por el servidor.';

  @override
  String get invalidResponseError =>
      'La respuesta del servidor no pudo procesarse.';

  @override
  String get invalidUsernameOrCodeOrRecoveryCodeError =>
      'Usuario, código de un solo uso o código de recuperación inválido.';

  @override
  String get invalidUsernameOrPasswordError =>
      'Usuario o contraseña inválidos.';

  @override
  String get invalidUsernameOrPasswordOrRecoveryCodeError =>
      'Usuario, contraseña o código de recuperación inválido.';

  @override
  String get invalidUsernameOrRecoveryCodeError =>
      'Usuario o código de recuperación inválido.';

  @override
  String get keepRecoveryCodesSafe =>
      'Por favor, guarda estos códigos de recuperación en un lugar seguro.\nSon necesarios si pierdes tu contraseña o el acceso a tu app 2FA.';

  @override
  String get language => 'Idioma';

  @override
  String get lastActivityDate => 'Última actividad:';

  @override
  String get light => 'Claro';

  @override
  String get logIn => 'Iniciar sesión';

  @override
  String get loginSuccessful => 'Inicio de sesión exitoso.';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get logoutSuccessful => 'Cerraste sesión correctamente.';

  @override
  String get messages => 'Mensajes';

  @override
  String get newPassword => 'Nueva contraseña';

  @override
  String get next => 'Siguiente';

  @override
  String get noAccountCreateOne => '¿Sin cuenta? Crea una aquí.';

  @override
  String get noContent => 'No hay contenido para mostrar';

  @override
  String get noDevices => 'No hay dispositivos para mostrar';

  @override
  String get noDeviceInfo => 'No hay información del dispositivo';

  @override
  String get noRecoveryCodeAvailable =>
      'No hay códigos de recuperación disponibles.';

  @override
  String get password => 'Contraseña';

  @override
  String get passwordForgotten => '¿Olvidaste tu contraseña?';

  @override
  String get passwordMustBeChangedError =>
      'Debes cambiar tu contraseña para iniciar sesión.';

  @override
  String get passwordNotComplexEnough =>
      'La contraseña debe contener al menos una letra, un dígito y un carácter especial.';

  @override
  String get passwordNotExpiredError =>
      'Tu contraseña no ha expirado; no puede cambiarse por esta vía.';

  @override
  String get passwordTooShortError =>
      'La contraseña debe tener al menos 8 caracteres.';

  @override
  String get passwordUpdateSuccessful =>
      'Tu contraseña se actualizó correctamente.';

  @override
  String get pleaseLoginOrSignUp =>
      'Inicia sesión o regístrate para continuar.';

  @override
  String get profile => 'Perfil';

  @override
  String get profileSettings => 'Configuración del perfil';

  @override
  String get profileUpdateSuccessful => 'Información de perfil guardada.';

  @override
  String get qrCodeSecretKeyCopied =>
      'Clave secreta del QR copiada al portapapeles.';

  @override
  String get recoverAccount => 'Recuperar cuenta';

  @override
  String get recoveryCode => 'Código de recuperación';

  @override
  String get recoveryCodesCopied => 'Códigos de recuperación copiados.';

  @override
  String get refreshTokenExpiredError =>
      'Tu sesión expiró. Inicia sesión nuevamente.';

  @override
  String get regenerateQrCode => 'Regenerar código QR';

  @override
  String get save => 'Guardar';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get selectTheme => 'Seleccionar tema';

  @override
  String get setNewPassword => 'Ingresa tu nueva contraseña.';

  @override
  String get signUp => 'Registrarse';

  @override
  String get theme => 'Tema';

  @override
  String get twoFA => 'Autenticación de dos factores';

  @override
  String get twoFAInvitation =>
      'La seguridad y la privacidad son prioridad.\nConfigura 2FA para proteger tu cuenta de ataques de fuerza bruta.';

  @override
  String get twoFAIsWellSetup =>
      'La autenticación de dos factores se configuró correctamente.';

  @override
  String get twoFAScanQrCode =>
      'Escanea este código QR con tu app de autenticación.';

  @override
  String twoFASecretKey(String secretKey) {
    return 'Tu clave secreta es: $secretKey';
  }

  @override
  String get twoFASetup =>
      'Activa la autenticación de dos factores para asegurar tu cuenta.';

  @override
  String get twoFactorAuthenticationNotEnabledError =>
      'La autenticación de dos factores no está activada en tu cuenta.';

  @override
  String get unableToLoadRecoveryCodes =>
      'No se pudieron cargar los códigos de recuperación.';

  @override
  String get unauthorizedError =>
      'No estás autorizado para realizar esta acción.';

  @override
  String get unknown => 'Desconocido';

  @override
  String get unknownError => 'Ocurrió un error inesperado. Inténtalo de nuevo.';

  @override
  String get updatePassword => 'Ingresa tu contraseña actual y la nueva.';

  @override
  String get userAlreadyExistingError =>
      'Ya existe un usuario con ese nombre. Elige otro.';

  @override
  String get userNotFoundError => 'Usuario no encontrado.';

  @override
  String get username => 'Usuario';

  @override
  String get usernameNotRespectingRulesError =>
      'El usuario debe seguir estas reglas:\n - Iniciar y terminar con letra o dígito\n - Caracteres especiales permitidos: . _ -\n - Sin caracteres especiales consecutivos';

  @override
  String get usernameWrongSizeError =>
      'La longitud del usuario debe estar entre 3 y 20 caracteres.';

  @override
  String get validationCode => 'Código de validación';

  @override
  String get validationCodeCorrect => '¡Tu código de validación es correcto!';

  @override
  String get verify => 'Verificar';

  @override
  String get welcome => 'Bienvenido a Flutter Actix App.';

  @override
  String get previous => 'Anterior';
}
