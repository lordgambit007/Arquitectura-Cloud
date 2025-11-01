// lib/features/auth/data/sources/remote_data_sources.dart
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutteractixapp/core/messages/errors/data_error.dart' as core_errors;
import 'package:flutteractixapp/features/auth/data/errors/data_error.dart' as auth_errors;

import 'package:flutteractixapp/features/auth/data/models/otp_model.dart';
import 'package:flutteractixapp/features/auth/data/models/otp_request_model.dart';
import 'package:flutteractixapp/features/auth/data/models/user_token_model.dart';
import 'package:flutteractixapp/features/auth/data/models/user_token_request_model.dart';

import 'package:http/http.dart' show Response, BaseResponse;
import 'package:http_interceptor/http_interceptor.dart';

class AuthRemoteDataSource {
  final InterceptedClient apiClient;
  final String baseUrl;

  AuthRemoteDataSource({required this.apiClient, required this.baseUrl});

  // ========= Helpers seguros =========

  dynamic _decodeBodySafe(BaseResponse response) {
    if (response is! Response) return null;
    final raw = response.body;
    if (raw.isEmpty) return null;
    try {
      return json.decode(raw);
    } catch (_) {
      throw core_errors.ParsingError();
    }
  }

  String? _extractCode(dynamic decoded) {
    if (decoded is Map && decoded['code'] is String) {
      return decoded['code'] as String;
    }
    return null;
  }

  Map<String, dynamic> _asStringMap(dynamic v) {
    if (v is Map) return Map<String, dynamic>.from(v);
    throw core_errors.ParsingError();
  }

  // ========== Endpoints ==========

  Future<UserTokenModel> signup(
    RegisterUserRequestModel registerUserRequestModel,
  ) async {
    final url = Uri.parse('$baseUrl/auth/signup');
    final response = await apiClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(registerUserRequestModel.toJson()),
    );

    final decoded = _decodeBodySafe(response);
    final responseCode = _extractCode(decoded);

    if (response.statusCode == 201) {
      try {
        return UserTokenModel.fromJson(_asStringMap(decoded));
      } catch (_) {
        throw core_errors.ParsingError();
      }
    }

    if (response.statusCode == 401) {
      if (responseCode == 'PASSWORD_TOO_SHORT') {
        throw auth_errors.PasswordTooShortError();
      }
      if (responseCode == 'PASSWORD_TOO_WEAK') {
        throw auth_errors.PasswordNotComplexEnoughError();
      }
      if (responseCode == 'USERNAME_WRONG_SIZE') {
        throw auth_errors.UsernameWrongSizeError();
      }
      if (responseCode == 'USERNAME_NOT_RESPECTING_RULES') {
        throw auth_errors.UsernameNotRespectingRulesError();
      }
      throw core_errors.UnauthorizedError();
    }

    if (response.statusCode == 409) {
      if (responseCode == 'USER_ALREADY_EXISTS') {
        throw auth_errors.UserAlreadyExistingError();
      }
    }

    if (response.statusCode == 500) {
      throw core_errors.InternalServerError();
    }

    throw core_errors.UnknownError();
  }

  Future<Either<UserTokenModel, String>> login(
    LoginUserRequestModel loginUserRequestModel,
  ) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final response = await apiClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(loginUserRequestModel.toJson()),
    );

    final decoded = _decodeBodySafe(response);
    final responseCode = _extractCode(decoded);

    if (response.statusCode == 200) {
      try {
        if (decoded is! Map) throw core_errors.ParsingError();

        if (responseCode == 'USER_LOGGED_IN_WITHOUT_OTP') {
          return Left(UserTokenModel.fromJson(_asStringMap(decoded)));
        }

        if (responseCode == 'USER_LOGS_IN_WITH_OTP_ENABLED') {
          final uid = decoded['user_id'];
          if (uid is String && uid.isNotEmpty) return Right(uid);
          throw core_errors.ParsingError();
        }

        throw core_errors.ParsingError();
      } catch (_) {
        throw core_errors.ParsingError();
      }
    }

    if (response.statusCode == 401) {
      if (responseCode == 'INVALID_USERNAME_OR_PASSWORD') {
        throw auth_errors.InvalidUsernameOrPasswordError();
      }
      throw core_errors.UnauthorizedError();
    }

    if (response.statusCode == 403) {
      if (responseCode == 'PASSWORD_MUST_BE_CHANGED') {
        throw auth_errors.PasswordMustBeChangedError();
      }
      throw core_errors.ForbiddenError();
    }

    if (response.statusCode == 500) {
      throw core_errors.InternalServerError();
    }

    throw core_errors.UnknownError();
  }

  Future<TwoFactorAuthenticationConfigModel> generateTwoFactorAuthenticationConfig() async {
    final url = Uri.parse('$baseUrl/auth/otp/generate');
    final response = await apiClient.get(url);

    if (response.statusCode == 200) {
      final decoded = _decodeBodySafe(response);
      try {
        return TwoFactorAuthenticationConfigModel.fromJson(_asStringMap(decoded));
      } catch (_) {
        throw core_errors.ParsingError();
      }
    }

    if (response.statusCode == 401) {
      throw core_errors.UnauthorizedError();
    }

    if (response.statusCode == 500) {
      throw core_errors.InternalServerError();
    }

    throw core_errors.UnknownError();
  }

  Future<bool> verifyOneTimePassword(
    VerifyOneTimePasswordRequestModel verifyOneTimePasswordRequestModel,
  ) async {
    final url = Uri.parse('$baseUrl/auth/otp/verify');
    final response = await apiClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(verifyOneTimePasswordRequestModel.toJson()),
    );

    final decoded = _decodeBodySafe(response);
    final responseCode = _extractCode(decoded);

    if (response.statusCode == 200) {
      try {
        if (decoded is Map && decoded['otp_verified'] is bool) {
          return decoded['otp_verified'] as bool;
        }
        throw core_errors.ParsingError();
      } catch (_) {
        throw core_errors.ParsingError();
      }
    }

    if (response.statusCode == 401) {
      if (responseCode == 'INVALID_ONE_TIME_PASSWORD') {
        throw auth_errors.InvalidOneTimePasswordError();
      }
      throw core_errors.UnauthorizedError();
    }

    if (response.statusCode == 500) {
      throw core_errors.InternalServerError();
    }

    throw core_errors.UnknownError();
  }

  Future<UserTokenModel> validateOneTimePassword(
    ValidateOneTimePasswordRequestModel validateOneTimePasswordRequestModel,
  ) async {
    final url = Uri.parse('$baseUrl/auth/otp/validate');
    final response = await apiClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(validateOneTimePasswordRequestModel.toJson()),
    );

    final decoded = _decodeBodySafe(response);
    final responseCode = _extractCode(decoded);

    if (response.statusCode == 200) {
      try {
        return UserTokenModel.fromJson(_asStringMap(decoded));
      } catch (_) {
        throw core_errors.ParsingError();
      }
    }

    if (response.statusCode == 401) {
      if (responseCode == 'InvalidOneTimePassword' ||
          responseCode == 'INVALID_ONE_TIME_PASSWORD') {
        throw auth_errors.InvalidOneTimePasswordError();
      }
      throw core_errors.UnauthorizedError();
    }

    if (response.statusCode == 404) {
      if (responseCode == 'USER_NOT_FOUND') {
        throw auth_errors.UserNotFoundError();
      }
    }

    if (response.statusCode == 500) {
      throw core_errors.InternalServerError();
    }

    throw core_errors.UnknownError();
  }

  Future<bool> disableTwoFactorAuthentication() async {
    final url = Uri.parse('$baseUrl/auth/otp/disable');
    final response = await apiClient.get(url);

    if (response.statusCode == 200) {
      final decoded = _decodeBodySafe(response);
      try {
        if (decoded is Map && decoded['two_fa_enabled'] is bool) {
          return decoded['two_fa_enabled'] as bool;
        }
        throw core_errors.ParsingError();
      } catch (_) {
        throw core_errors.ParsingError();
      }
    }

    if (response.statusCode == 401) {
      throw core_errors.UnauthorizedError();
    }

    if (response.statusCode == 500) {
      throw core_errors.InternalServerError();
    }

    throw core_errors.UnknownError();
  }

  Future<bool> checkIfAccountHasTwoFactorAuthenticationEnabled(
    CheckIfAccountHasTwoFactorAuthenticationEnabledRequestModel body,
  ) async {
    final url = Uri.parse('$baseUrl/users/is-otp-enabled');
    final response = await apiClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body.toJson()),
    );

    if (response.statusCode == 200) {
      final decoded = _decodeBodySafe(response);
      try {
        if (decoded is Map && decoded['otp_enabled'] is bool) {
          return decoded['otp_enabled'] as bool;
        }
        throw core_errors.ParsingError();
      } catch (_) {
        throw core_errors.ParsingError();
      }
    }

    if (response.statusCode == 500) {
      throw core_errors.InternalServerError();
    }

    throw core_errors.UnknownError();
  }

  Future<UserTokenModel> recoverAccountWithTwoFactorAuthenticationAndPassword(
    RecoverAccountWithRecoveryCodeAndPasswordRequestModel body,
  ) async {
    final url = Uri.parse('$baseUrl/auth/recover-using-password');
    final response = await apiClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body.toJson()),
    );

    final decoded = _decodeBodySafe(response);
    final responseCode = _extractCode(decoded);

    if (response.statusCode == 200) {
      try {
        return UserTokenModel.fromJson(_asStringMap(decoded));
      } catch (_) {
        throw core_errors.ParsingError();
      }
    }

    if (response.statusCode == 401) {
      if (responseCode == 'INVALID_USERNAME_OR_PASSWORD_OR_RECOVERY_CODE') {
        throw auth_errors.InvalidUsernameOrPasswordOrRecoveryCodeError();
      }
      throw core_errors.UnauthorizedError();
    }

    if (response.statusCode == 403) {
      if (responseCode == 'TWO_FACTOR_AUTHENTICATION_NOT_ENABLED') {
        throw auth_errors.TwoFactorAuthenticationNotEnabledError();
      }
      throw core_errors.ForbiddenError();
    }

    if (response.statusCode == 500) {
      throw core_errors.InternalServerError();
    }

    throw core_errors.UnknownError();
  }

  Future<UserTokenModel> recoverAccountWithTwoFactorAuthenticationAndOneTimePassword(
    RecoverAccountWithRecoveryCodeAndOneTimePasswordRequestModel body,
  ) async {
    final url = Uri.parse('$baseUrl/auth/recover-using-2fa');
    final response = await apiClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body.toJson()),
    );

    final decoded = _decodeBodySafe(response);
    final responseCode = _extractCode(decoded);

    if (response.statusCode == 200) {
      try {
        return UserTokenModel.fromJson(_asStringMap(decoded));
      } catch (_) {
        throw core_errors.ParsingError();
      }
    }

    if (response.statusCode == 401) {
      if (responseCode == 'INVALID_USERNAME_OR_CODE_OR_RECOVERY_CODE') {
        throw auth_errors.InvalidUsernameOrCodeOrRecoveryCodeError();
      }
      throw core_errors.UnauthorizedError();
    }

    if (response.statusCode == 403) {
      if (responseCode == 'TWO_FACTOR_AUTHENTICATION_NOT_ENABLED') {
        throw auth_errors.TwoFactorAuthenticationNotEnabledError();
      }
      throw core_errors.ForbiddenError();
    }

    if (response.statusCode == 500) {
      throw core_errors.InternalServerError();
    }

    throw core_errors.UnknownError();
  }

  Future<UserTokenModel> recoverAccountWithoutTwoFactorAuthenticationEnabled(
    RecoverAccountWithRecoveryCodeRequestModel body,
  ) async {
    final url = Uri.parse('$baseUrl/auth/recover');
    final response = await apiClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body.toJson()),
    );

    final decoded = _decodeBodySafe(response);
    final responseCode = _extractCode(decoded);

    if (response.statusCode == 200) {
      try {
        return UserTokenModel.fromJson(_asStringMap(decoded));
      } catch (_) {
        throw core_errors.ParsingError();
      }
    }

    if (response.statusCode == 401) {
      if (responseCode == 'INVALID_USERNAME_OR_RECOVERY_CODE') {
        throw auth_errors.InvalidUsernameOrRecoveryCodeError();
      }
      throw core_errors.UnauthorizedError();
    }

    if (response.statusCode == 500) {
      throw core_errors.InternalServerError();
    }

    throw core_errors.UnknownError();
  }

  Future<void> logout() async {
    final url = Uri.parse('$baseUrl/auth/logout');
    final response = await apiClient.get(url);

    if (response.statusCode == 200) return;

    if (response.statusCode == 401) {
      throw core_errors.UnauthorizedError();
    }

    if (response.statusCode == 500) {
      throw core_errors.InternalServerError();
    }

    throw core_errors.UnknownError();
  }
}
