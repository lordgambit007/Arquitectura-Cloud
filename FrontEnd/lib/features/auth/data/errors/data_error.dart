// lib/features/auth/data/errors/data_error.dart
import 'package:flutteractixapp/core/messages/errors/data_error.dart';

/// Base de errores de la capa de datos de Auth
abstract class AuthDataError extends DataError {}

// ---------- Signup/Login/Username/Password ----------
class UserAlreadyExistingError extends AuthDataError {}
class InvalidUsernameOrPasswordError extends AuthDataError {}
class PasswordMustBeChangedError extends AuthDataError {}

class PasswordTooShortError extends AuthDataError {}
class PasswordNotComplexEnoughError extends AuthDataError {}

class UsernameWrongSizeError extends AuthDataError {}
class UsernameNotRespectingRulesError extends AuthDataError {}

// ---------------------- OTP / 2FA --------------------
class InvalidOneTimePasswordError extends AuthDataError {}
class UserNotFoundError extends AuthDataError {}
class TwoFactorAuthenticationNotEnabledError extends AuthDataError {}

// --------------------- Recovery ----------------------
class InvalidUsernameOrRecoveryCodeError extends AuthDataError {}
class InvalidUsernameOrPasswordOrRecoveryCodeError extends AuthDataError {}
class InvalidUsernameOrCodeOrRecoveryCodeError extends AuthDataError {}

// -------------------- Refresh Token ------------------
class InvalidRefreshTokenError extends AuthDataError {}
class RefreshTokenNotFoundError extends AuthDataError {}
class RefreshTokenExpiredError extends AuthDataError {}
