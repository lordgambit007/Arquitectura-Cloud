// lib/features/profile/data/errors/data_error.dart
import 'package:flutteractixapp/core/messages/errors/data_error.dart';

abstract class ProfileDataError extends DataError {}

/// Error propio de Profile: la contraseña aún no ha expirado,
/// por lo que no puede ser seteada mediante /set-password.
class PasswordNotExpiredError extends ProfileDataError {}
