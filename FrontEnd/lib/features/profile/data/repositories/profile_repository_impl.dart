// lib/features/profile/data/repositories/profile_repository_impl.dart

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:logger/web.dart';

// Core data errors
import 'package:flutteractixapp/core/messages/errors/data_error.dart' as core_data_err;

// Data errors (auth/profile) con alias
import 'package:flutteractixapp/features/auth/data/errors/data_error.dart' as auth_data_err;
import 'package:flutteractixapp/features/profile/data/errors/data_error.dart' as profile_data_err;

// Remote DS
import 'package:flutteractixapp/features/profile/data/sources/remote_data_sources.dart';

// Models
import 'package:flutteractixapp/features/profile/data/models/profile_request_model.dart';
import 'package:flutteractixapp/features/profile/domain/entities/device.dart';
import 'package:flutteractixapp/features/profile/domain/entities/profile.dart';

// Domain errors (auth/profile/core)
import 'package:flutteractixapp/features/auth/domain/errors/domain_error.dart'
    as auth_dom;
import 'package:flutteractixapp/core/messages/errors/domain_error.dart' as core_dom;
import 'package:flutteractixapp/features/profile/domain/errors/domain_error.dart'
    as profile_dom;

// Domain repo interface
import 'package:flutteractixapp/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final logger = Logger();

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<core_dom.DomainError, Profile>> getProfileInformation() async {
    try {
      final profileModel = await remoteDataSource.getProfileInformation();

      return Right(
        Profile(
          username: profileModel.username,
          locale: profileModel.locale,
          theme: profileModel.theme,
          otpBase32: profileModel.otpBase32,
          otpAuthUrl: profileModel.otpAuthUrl,
          otpVerified: profileModel.otpVerified,
          passwordIsExpired: profileModel.passwordIsExpired,
        ),
      );
    } on core_data_err.ParsingError {
      logger.e('ParsingError occurred.');
      return Left(core_dom.InvalidResponseDomainError());
    } on core_data_err.UnauthorizedError {
      logger.e('UnauthorizedError occurred.');
      return Left(core_dom.UnauthorizedDomainError());
    } on core_data_err.ForbiddenError {
      logger.e('ForbiddenError occurred.');
      return Left(core_dom.ForbiddenDomainError());
    } on auth_data_err.InvalidRefreshTokenError {
      logger.e('InvalidRefreshTokenError occurred.');
      return Left(auth_dom.InvalidRefreshTokenDomainError());
    } on auth_data_err.RefreshTokenNotFoundError {
      logger.e('RefreshTokenNotFoundError occurred.');
      return Left(auth_dom.RefreshTokenNotFoundDomainError());
    } on auth_data_err.RefreshTokenExpiredError {
      logger.e('RefreshTokenExpiredError occurred.');
      return Left(auth_dom.RefreshTokenExpiredDomainError());
    } on core_data_err.InternalServerError {
      logger.e('InternalServerError occurred.');
      return Left(core_dom.InternalServerDomainError());
    } catch (e) {
      logger.e('Data error occurred: ${e.toString()}');
      return Left(core_dom.UnknownDomainError());
    }
  }

  @override
  Future<Either<core_dom.DomainError, Profile>> postProfileInformation(
    Profile profile,
  ) async {
    try {
      final profileModel = await remoteDataSource.postProfileInformation(
        UpdateProfileRequestModel(
          username: profile.username,
          locale: profile.locale,
          theme: profile.theme,
        ),
      );

      return Right(
        Profile(
          username: profileModel.username,
          locale: profileModel.locale,
          theme: profileModel.theme,
          otpBase32: profileModel.otpBase32,
          otpAuthUrl: profileModel.otpAuthUrl,
          otpVerified: profileModel.otpVerified,
          passwordIsExpired: profileModel.passwordIsExpired,
        ),
      );
    } on core_data_err.ParsingError {
      logger.e('ParsingError occurred.');
      return Left(core_dom.InvalidResponseDomainError());
    } on auth_data_err.InvalidUsernameOrPasswordError {
      logger.e('InvalidUsernameOrPasswordError occurred.');
      return Left(auth_dom.InvalidUsernameOrPasswordDomainError());
    } on core_data_err.UnauthorizedError {
      logger.e('UnauthorizedError occurred.');
      return Left(core_dom.UnauthorizedDomainError());
    } on core_data_err.ForbiddenError {
      logger.e('ForbiddenError occurred.');
      return Left(core_dom.ForbiddenDomainError());
    } on auth_data_err.InvalidRefreshTokenError {
      logger.e('InvalidRefreshTokenError occurred.');
      return Left(auth_dom.InvalidRefreshTokenDomainError());
    } on auth_data_err.RefreshTokenNotFoundError {
      logger.e('RefreshTokenNotFoundError occurred.');
      return Left(auth_dom.RefreshTokenNotFoundDomainError());
    } on auth_data_err.RefreshTokenExpiredError {
      logger.e('RefreshTokenExpiredError occurred.');
      return Left(auth_dom.RefreshTokenExpiredDomainError());
    } on core_data_err.InternalServerError {
      logger.e('InternalServerError occurred.');
      return Left(core_dom.InternalServerDomainError());
    } catch (e) {
      logger.e('Data error occurred: ${e.toString()}');
      return Left(core_dom.UnknownDomainError());
    }
  }

  @override
  Future<Either<core_dom.DomainError, Profile>> setPassword(
    String newPassword,
  ) async {
    try {
      final profileModel = await remoteDataSource
          .setPassword(SetPasswordRequestModel(newPassword: newPassword));

      return Right(
        Profile(
          username: profileModel.username,
          locale: profileModel.locale,
          theme: profileModel.theme,
          otpBase32: profileModel.otpBase32,
          otpAuthUrl: profileModel.otpAuthUrl,
          otpVerified: profileModel.otpVerified,
          passwordIsExpired: profileModel.passwordIsExpired,
        ),
      );
    } on core_data_err.ParsingError {
      logger.e('ParsingError occurred.');
      return Left(core_dom.InvalidResponseDomainError());
    } on profile_data_err.PasswordNotExpiredError {
      logger.e('PasswordNotExpiredError occurred.');
      return Left(profile_dom.PasswordNotExpiredDomainError());
    } on core_data_err.UnauthorizedError {
      logger.e('UnauthorizedError occurred.');
      return Left(core_dom.UnauthorizedDomainError());
    } on core_data_err.ForbiddenError {
      logger.e('ForbiddenError occurred.');
      return Left(core_dom.ForbiddenDomainError());
    } on auth_data_err.InvalidRefreshTokenError {
      logger.e('InvalidRefreshTokenError occurred.');
      return Left(auth_dom.InvalidRefreshTokenDomainError());
    } on auth_data_err.RefreshTokenNotFoundError {
      logger.e('RefreshTokenNotFoundError occurred.');
      return Left(auth_dom.RefreshTokenNotFoundDomainError());
    } on auth_data_err.RefreshTokenExpiredError {
      logger.e('RefreshTokenExpiredError occurred.');
      return Left(auth_dom.RefreshTokenExpiredDomainError());
    } on auth_data_err.PasswordTooShortError {
      logger.e('PasswordTooShortError occurred.');
      return Left(auth_dom.PasswordTooShortError());
    } on auth_data_err.PasswordNotComplexEnoughError {
      logger.e('PasswordNotComplexEnoughError occurred.');
      return Left(auth_dom.PasswordNotComplexEnoughError());
    } on core_data_err.InternalServerError {
      logger.e('InternalServerError occurred.');
      return Left(core_dom.InternalServerDomainError());
    } catch (e) {
      logger.e('Data error occurred: ${e.toString()}');
      return Left(core_dom.UnknownDomainError());
    }
  }

  @override
  Future<Either<core_dom.DomainError, Profile>> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final profileModel = await remoteDataSource.updatePassword(
        UpdatePasswordRequestModel(
          currentPassword: currentPassword,
          newPassword: newPassword,
        ),
      );

      return Right(
        Profile(
          username: profileModel.username,
          locale: profileModel.locale,
          theme: profileModel.theme,
          otpBase32: profileModel.otpBase32,
          otpAuthUrl: profileModel.otpAuthUrl,
          otpVerified: profileModel.otpVerified,
          passwordIsExpired: profileModel.passwordIsExpired,
        ),
      );
    } on core_data_err.ParsingError {
      logger.e('ParsingError occurred.');
      return Left(core_dom.InvalidResponseDomainError());
    } on auth_data_err.InvalidUsernameOrPasswordError {
      logger.e('InvalidUsernameOrPasswordError occurred.');
      return Left(auth_dom.InvalidUsernameOrPasswordDomainError());
    } on core_data_err.UnauthorizedError {
      logger.e('UnauthorizedError occurred.');
      return Left(core_dom.UnauthorizedDomainError());
    } on core_data_err.ForbiddenError {
      logger.e('ForbiddenError occurred.');
      return Left(core_dom.ForbiddenDomainError());
    } on auth_data_err.InvalidRefreshTokenError {
      logger.e('InvalidRefreshTokenError occurred.');
      return Left(auth_dom.InvalidRefreshTokenDomainError());
    } on auth_data_err.RefreshTokenNotFoundError {
      logger.e('RefreshTokenNotFoundError occurred.');
      return Left(auth_dom.RefreshTokenNotFoundDomainError());
    } on auth_data_err.RefreshTokenExpiredError {
      logger.e('RefreshTokenExpiredError occurred.');
      return Left(auth_dom.RefreshTokenExpiredDomainError());
    } on auth_data_err.PasswordTooShortError {
      logger.e('PasswordTooShortError occurred.');
      return Left(auth_dom.PasswordTooShortError());
    } on auth_data_err.PasswordNotComplexEnoughError {
      logger.e('PasswordNotComplexEnoughError occurred.');
      return Left(auth_dom.PasswordNotComplexEnoughError());
    } on core_data_err.InternalServerError {
      logger.e('InternalServerError occurred.');
      return Left(core_dom.InternalServerDomainError());
    } catch (e) {
      logger.e('Data error occurred: ${e.toString()}');
      return Left(core_dom.UnknownDomainError());
    }
  }

  @override
  Future<Either<core_dom.DomainError, List<Device>>> getDevices() async {
    try {
      final deviceModels = await remoteDataSource.getDevices();

      final devices = deviceModels
          .map(
            (m) => Device(
              tokenId: m.tokenId,
              parsedDeviceInfo: ParsedDeviceInfo(
                isMobile: m.parsedDeviceInfoModel.isMobile,
                os: m.parsedDeviceInfoModel.os,
                browser: m.parsedDeviceInfoModel.browser,
                appVersion: m.parsedDeviceInfoModel.appVersion,
                model: m.parsedDeviceInfoModel.model,
              ),
              lastActivityDate: m.lastActivityDate,
            ),
          )
          .toList();

      return Right(devices);
    } on core_data_err.ParsingError {
      logger.e('ParsingError occurred.');
      // si el cuerpo fue raro, devolvemos lista vacía en lugar de fallar
      return const Right([]);
    } on core_data_err.UnauthorizedError {
      logger.e('UnauthorizedError occurred.');
      return Left(core_dom.UnauthorizedDomainError());
    } on core_data_err.ForbiddenError {
      logger.e('ForbiddenError occurred.');
      return Left(core_dom.ForbiddenDomainError());
    } on auth_data_err.InvalidRefreshTokenError {
      logger.e('InvalidRefreshTokenError occurred.');
      return Left(auth_dom.InvalidRefreshTokenDomainError());
    } on auth_data_err.RefreshTokenNotFoundError {
      logger.e('RefreshTokenNotFoundError occurred.');
      return Left(auth_dom.RefreshTokenNotFoundDomainError());
    } on auth_data_err.RefreshTokenExpiredError {
      logger.e('RefreshTokenExpiredError occurred.');
      return Left(auth_dom.RefreshTokenExpiredDomainError());
    } on core_data_err.InternalServerError {
      logger.e('InternalServerError occurred.');
      return Left(core_dom.InternalServerDomainError());
    } catch (e) {
      // cualquier otra cosa inesperada → lista vacía
      logger.w('getDevices fallback to empty list due to: $e');
      return const Right([]);
    }
  }

  @override
  Future<Either<core_dom.DomainError, void>> deleteDevice(
    String deviceId,
  ) async {
    try {
      await remoteDataSource.deleteDevice(deviceId);
      return const Right(null);
    } on core_data_err.ParsingError {
      logger.e('ParsingError occurred.');
      return Left(core_dom.InvalidResponseDomainError());
    } on core_data_err.UnauthorizedError {
      logger.e('UnauthorizedError occurred.');
      return Left(core_dom.UnauthorizedDomainError());
    } on core_data_err.ForbiddenError {
      logger.e('ForbiddenError occurred.');
      return Left(core_dom.ForbiddenDomainError());
    } on auth_data_err.InvalidUsernameOrPasswordError {
      logger.e('InvalidUsernameOrPasswordError occurred.');
      return Left(auth_dom.InvalidUsernameOrPasswordDomainError());
    } on auth_data_err.InvalidRefreshTokenError {
      logger.e('InvalidRefreshTokenError occurred.');
      return Left(auth_dom.InvalidRefreshTokenDomainError());
    } on auth_data_err.RefreshTokenNotFoundError {
      logger.e('RefreshTokenNotFoundError occurred.');
      return Left(auth_dom.RefreshTokenNotFoundDomainError());
    } on auth_data_err.RefreshTokenExpiredError {
      logger.e('RefreshTokenExpiredError occurred.');
      return Left(auth_dom.RefreshTokenExpiredDomainError());
    } on auth_data_err.PasswordTooShortError {
      logger.e('PasswordTooShortError occurred.');
      return Left(auth_dom.PasswordTooShortError());
    } on auth_data_err.PasswordNotComplexEnoughError {
      logger.e('PasswordNotComplexEnoughError occurred.');
      return Left(auth_dom.PasswordNotComplexEnoughError());
    } on core_data_err.InternalServerError {
      logger.e('InternalServerError occurred.');
      return Left(core_dom.InternalServerDomainError());
    } catch (e) {
      logger.e('Data error occurred: ${e.toString()}');
      return Left(core_dom.UnknownDomainError());
    }
  }
}
