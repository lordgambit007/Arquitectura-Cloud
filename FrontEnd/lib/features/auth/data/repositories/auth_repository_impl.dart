// features/auth/data/repositories/auth_repository_impl.dart

import 'dart:async';

import 'package:dartz/dartz.dart';

// Alias para evitar colisiones de nombres entre errores de core y de auth
import 'package:flutteractixapp/core/messages/errors/data_error.dart'
    as core_errors;

import 'package:flutteractixapp/core/messages/errors/domain_error.dart';
import 'package:flutteractixapp/features/auth/data/errors/data_error.dart'
    as auth_errors;

import 'package:flutteractixapp/features/auth/data/models/otp_request_model.dart';
import 'package:flutteractixapp/features/auth/data/models/user_token_request_model.dart';
import 'package:flutteractixapp/features/auth/data/sources/remote_data_sources.dart';

import 'package:flutteractixapp/features/auth/domain/entities/otp_generation.dart';
import 'package:flutteractixapp/features/auth/domain/entities/user_token.dart';
import 'package:flutteractixapp/features/auth/domain/errors/domain_error.dart';
import 'package:flutteractixapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:logger/web.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final logger = Logger();

  AuthRepositoryImpl(this.remoteDataSource);

  // ------------------- SIGNUP -------------------
  @override
  Future<Either<DomainError, UserToken>> signup({
    required String username,
    required String password,
    required String locale,
    required String theme,
  }) async {
    try {
      final userTokenModel = await remoteDataSource.signup(
        RegisterUserRequestModel(
          username: username,
          password: password,
          locale: locale,
          theme: theme,
        ),
      );

      if (userTokenModel.accessToken.isEmpty ||
          userTokenModel.refreshToken.isEmpty) {
        logger.w('⚠️ Signup response is empty or incomplete.');
        throw core_errors.ParsingError();
        // parsing de capa data -> mapeamos a DomainError abajo
      }

      return Right(
        UserToken(
          accessToken: userTokenModel.accessToken,
          refreshToken: userTokenModel.refreshToken,
          recoveryCodes: userTokenModel.recoveryCodes,
        ),
      );
    } on core_errors.ParsingError {
      logger.e('ParsingError occurred.');
      return Left(InvalidResponseDomainError());
    } on auth_errors.UserAlreadyExistingError {
      logger.e('UserAlreadyExistingError occurred.');
      return Left(UserAlreadyExistingDomainError());
    } on auth_errors.PasswordTooShortError {
      logger.e('PasswordTooShortError occurred.');
      return Left(PasswordTooShortError());
    } on auth_errors.PasswordNotComplexEnoughError {
      logger.e('PasswordNotComplexEnoughError occurred.');
      return Left(PasswordNotComplexEnoughError());
    } on auth_errors.UsernameWrongSizeError {
      logger.e('UsernameWrongSizeError occurred.');
      return Left(UsernameWrongSizeError());
    } on auth_errors.UsernameNotRespectingRulesError {
      logger.e('UsernameNotRespectingRulesError occurred.');
      return Left(UsernameNotRespectingRulesError());
    } on core_errors.InternalServerError {
      logger.e('InternalServerError occurred.');
      return Left(InternalServerDomainError());
    } catch (e) {
      logger.e('Data error occurred during signup: $e');
      return Left(UnknownDomainError());
    }
  }

  // ------------------- LOGIN -------------------
  @override
  Future<Either<DomainError, Either<UserToken, String>>> login({
    required String username,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.login(
        LoginUserRequestModel(username: username, password: password),
      );

      if (result == null) {
        logger.w('⚠️ Login response is null or empty.');
        return Left(InvalidResponseDomainError());
      }

      return result.fold(
        (userTokenModel) {
          if (userTokenModel.accessToken.isEmpty) {
            logger.w('⚠️ Empty access token on login response.');
            throw core_errors.ParsingError();
          }
          return Right(Left(UserToken(
            accessToken: userTokenModel.accessToken,
            refreshToken: userTokenModel.refreshToken,
          )));
        },
        (string) {
          if (string.isEmpty) {
            logger.w('⚠️ Empty response string on login result.');
            throw core_errors.ParsingError();
          }
          return Right(Right(string));
        },
      );
    } on core_errors.ParsingError {
      logger.e('ParsingError occurred.');
      return Left(InvalidResponseDomainError());
    } on auth_errors.InvalidUsernameOrPasswordError {
      logger.e('InvalidUsernameOrPasswordError occurred.');
      return Left(InvalidUsernameOrPasswordDomainError());
    } on core_errors.ForbiddenError {
      logger.e('ForbiddenError occurred.');
      return Left(ForbiddenDomainError());
    } on auth_errors.PasswordMustBeChangedError {
      logger.e('PasswordMustBeChangedError occurred.');
      return Left(PasswordMustBeChangedDomainError());
    } on core_errors.UnauthorizedError {
      logger.e('UnauthorizedError occurred.');
      return Left(UnauthorizedDomainError());
    } on core_errors.InternalServerError {
      logger.e('InternalServerError occurred.');
      return Left(InternalServerDomainError());
    } catch (e) {
      logger.e('Data error occurred during login: $e');
      return Left(UnknownDomainError());
    }
  }

  // ------------------- GENERATE 2FA CONFIG -------------------
  @override
  Future<Either<DomainError, TwoFactorAuthenticationConfig>>
      generateTwoFactorAuthenticationConfig() async {
    try {
      final config =
          await remoteDataSource.generateTwoFactorAuthenticationConfig();
      if (config.otpBase32.isEmpty) {
        logger.w('⚠️ Empty 2FA config received.');
        throw core_errors.ParsingError();
      }

      return Right(
        TwoFactorAuthenticationConfig(
          otpBase32: config.otpBase32,
          otpAuthUrl: config.otpAuthUrl,
        ),
      );
    } on core_errors.ParsingError {
      return Left(InvalidResponseDomainError());
    } on core_errors.UnauthorizedError {
      return Left(UnauthorizedDomainError());
    } on core_errors.InternalServerError {
      return Left(InternalServerDomainError());
    } catch (e) {
      logger.e('Data error during 2FA generation: $e');
      return Left(UnknownDomainError());
    }
  }

  // ------------------- VERIFY OTP -------------------
  @override
  Future<Either<DomainError, bool>> verifyOneTimePassword({
    required String code,
  }) async {
    try {
      final result = await remoteDataSource
          .verifyOneTimePassword(VerifyOneTimePasswordRequestModel(code: code));
      return Right(result);
    } on core_errors.ParsingError {
      return Left(InvalidResponseDomainError());
    } on core_errors.UnauthorizedError {
      return Left(UnauthorizedDomainError());
    } on auth_errors.InvalidOneTimePasswordError {
      return Left(InvalidOneTimePasswordDomainError());
    } catch (e) {
      logger.e('Data error during OTP verification: $e');
      return Left(UnknownDomainError());
    }
  }

  // ------------------- VALIDATE OTP -------------------
  @override
  Future<Either<DomainError, UserToken>> validateOneTimePassword({
    required String userId,
    required String code,
  }) async {
    try {
      final userTokenModel = await remoteDataSource.validateOneTimePassword(
        ValidateOneTimePasswordRequestModel(userId: userId, code: code),
      );

      if (userTokenModel.accessToken.isEmpty) {
        logger.w('⚠️ Empty access token in validateOneTimePassword.');
        throw core_errors.ParsingError();
      }

      return Right(UserToken(
        accessToken: userTokenModel.accessToken,
        refreshToken: userTokenModel.refreshToken,
      ));
    } on core_errors.ParsingError {
      return Left(InvalidResponseDomainError());
    } on core_errors.UnauthorizedError {
      return Left(UnauthorizedDomainError());
    } catch (e) {
      logger.e('Data error during OTP validation: $e');
      return Left(UnknownDomainError());
    }
  }

  // ------------------- DISABLE 2FA -------------------
  @override
  Future<Either<DomainError, bool>> disableTwoFactorAuthentication() async {
    try {
      final result = await remoteDataSource.disableTwoFactorAuthentication();
      return Right(result);
    } on core_errors.ParsingError {
      return Left(InvalidResponseDomainError());
    } on core_errors.UnauthorizedError {
      return Left(UnauthorizedDomainError());
    } catch (e) {
      logger.e('Data error during 2FA disable: $e');
      return Left(UnknownDomainError());
    }
  }

  // ------------------- CHECK 2FA ENABLED -------------------
  @override
  Future<Either<DomainError, bool>>
      checkIfAccountHasTwoFactorAuthenticationEnabled({
    required String username,
  }) async {
    try {
      final result = await remoteDataSource
          .checkIfAccountHasTwoFactorAuthenticationEnabled(
        CheckIfAccountHasTwoFactorAuthenticationEnabledRequestModel(
          username: username,
        ),
      );
      return Right(result);
    } on core_errors.ParsingError {
      return Left(InvalidResponseDomainError());
    } catch (e) {
      logger.e('Data error while checking 2FA status: $e');
      return Left(UnknownDomainError());
    }
  }

  // ------------------- RECOVERY METHODS -------------------
  @override
  Future<Either<DomainError, UserToken>>
      recoverAccountWithTwoFactorAuthenticationAndPassword({
    required String username,
    required String password,
    required String recoveryCode,
  }) async {
    try {
      final userTokenModel = await remoteDataSource
          .recoverAccountWithTwoFactorAuthenticationAndPassword(
        RecoverAccountWithRecoveryCodeAndPasswordRequestModel(
          username: username,
          password: password,
          recoveryCode: recoveryCode,
        ),
      );

      return Right(UserToken(
        accessToken: userTokenModel.accessToken,
        refreshToken: userTokenModel.refreshToken,
      ));
    } catch (e) {
      logger.e('Data error during recoverAccountWithPassword: $e');
      return Left(UnknownDomainError());
    }
  }

  @override
  Future<Either<DomainError, UserToken>>
      recoverAccountWithTwoFactorAuthenticationAndOneTimePassword({
    required String username,
    required String code,
    required String recoveryCode,
  }) async {
    try {
      final userTokenModel = await remoteDataSource
          .recoverAccountWithTwoFactorAuthenticationAndOneTimePassword(
        RecoverAccountWithRecoveryCodeAndOneTimePasswordRequestModel(
          username: username,
          code: code,
          recoveryCode: recoveryCode,
        ),
      );

      return Right(UserToken(
        accessToken: userTokenModel.accessToken,
        refreshToken: userTokenModel.refreshToken,
      ));
    } catch (e) {
      logger.e('Data error during recoverAccountWithOTP: $e');
      return Left(UnknownDomainError());
    }
  }

  @override
  Future<Either<DomainError, UserToken>>
      recoverAccountWithoutTwoFactorAuthenticationEnabled({
    required String username,
    required String recoveryCode,
  }) async {
    try {
      final userTokenModel = await remoteDataSource
          .recoverAccountWithoutTwoFactorAuthenticationEnabled(
        RecoverAccountWithRecoveryCodeRequestModel(
          username: username,
          recoveryCode: recoveryCode,
        ),
      );

      return Right(UserToken(
        accessToken: userTokenModel.accessToken,
        refreshToken: userTokenModel.refreshToken,
      ));
    } catch (e) {
      logger.e('Data error during recoverAccountWithout2FA: $e');
      return Left(UnknownDomainError());
    }
  }

  // ------------------- LOGOUT -------------------
  @override
  Future<Either<DomainError, void>> logout() async {
    try {
      final result = await remoteDataSource.logout();
      return Right(result);
    } on core_errors.ParsingError {
      return Left(InvalidResponseDomainError());
    } on core_errors.UnauthorizedError {
      return Left(UnauthorizedDomainError());
    } catch (e) {
      logger.e('Data error during logout: $e');
      return Left(UnknownDomainError());
    }
  }
}
