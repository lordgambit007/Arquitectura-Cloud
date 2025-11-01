// lib/core/service_locator.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutteractixapp/core/network/auth_interceptor.dart';
import 'package:flutteractixapp/core/network/expired_token_retry_policy.dart';
import 'package:flutteractixapp/core/network/logging_interceptor.dart';

import 'package:flutteractixapp/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutteractixapp/features/auth/data/services/auth_service.dart';
import 'package:flutteractixapp/features/auth/data/sources/remote_data_sources.dart' as auth_ds;
import 'package:flutteractixapp/features/auth/data/storage/token_storage.dart';
import 'package:flutteractixapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutteractixapp/features/auth/domain/usecases/check_if_account_has_two_factor_authentication_enabled_use_case.dart';
import 'package:flutteractixapp/features/auth/domain/usecases/disable_two_factor_authentication_use_case.dart';
import 'package:flutteractixapp/features/auth/domain/usecases/generate_two_factor_authentication_config_use_case.dart';
import 'package:flutteractixapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutteractixapp/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutteractixapp/features/auth/domain/usecases/recover_account_with_two_factor_authentication_and_one_time_password_use_case.dart';
import 'package:flutteractixapp/features/auth/domain/usecases/recover_account_with_two_factor_authentication_and_password_use_case.dart';
import 'package:flutteractixapp/features/auth/domain/usecases/recover_account_without_two_factor_authentication_enabled_use_case.dart';
import 'package:flutteractixapp/features/auth/domain/usecases/signup_usecase.dart';
import 'package:flutteractixapp/features/auth/domain/usecases/validate_one_time_password_use_case.dart';
import 'package:flutteractixapp/features/auth/domain/usecases/verify_one_time_password_use_case.dart';

import 'package:flutteractixapp/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:flutteractixapp/features/profile/data/sources/remote_data_sources.dart' as profile_ds;
import 'package:flutteractixapp/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutteractixapp/features/profile/domain/usecases/delete_device.dart';
import 'package:flutteractixapp/features/profile/domain/usecases/get_devices.dart';
import 'package:flutteractixapp/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:flutteractixapp/features/profile/domain/usecases/post_profile_usecase.dart';
import 'package:flutteractixapp/features/profile/domain/usecases/set_password_use_case.dart';
import 'package:flutteractixapp/features/profile/domain/usecases/update_password_use_case.dart';

import 'package:get_it/get_it.dart';
import 'package:http_interceptor/http_interceptor.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  // ===== Base URL desde .env =====
  final envUrl = dotenv.env['BASE_URL'] ?? '';
  if (envUrl.isEmpty) {
    throw Exception('❌ BASE_URL no está definido en el archivo .env');
  }
  final baseUrl = envUrl.endsWith('/')
      ? envUrl.substring(0, envUrl.length - 1)
      : envUrl;

  print('🔗 Base URL cargada desde .env: $baseUrl');

  // ===== Infraestructura común =====
  final tokenStorage = TokenStorage();
  final authService = AuthService(baseUrl: baseUrl, tokenStorage: tokenStorage);

  final apiClient = InterceptedClient.build(
    interceptors: [
      AuthInterceptor(
        baseUrl: baseUrl,
        tokenStorage: tokenStorage,
        clearToken: () async => await tokenStorage.deleteTokens(),
      ),
      LoggingInterceptor(), // logs útiles para debug
    ],
    requestTimeout: const Duration(seconds: 20),
    retryPolicy: ExpiredTokenRetryPolicy(authService: authService),
  );

  // ===== Remote Data Sources =====
  sl.registerSingleton<auth_ds.AuthRemoteDataSource>(
    auth_ds.AuthRemoteDataSource(apiClient: apiClient, baseUrl: baseUrl),
  );

  sl.registerSingleton<profile_ds.ProfileRemoteDataSource>(
    profile_ds.ProfileRemoteDataSource(apiClient: apiClient, baseUrl: baseUrl),
  );

  // ===== Repositories =====
  sl.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(sl<auth_ds.AuthRemoteDataSource>()),
  );

  sl.registerSingleton<ProfileRepository>(
    ProfileRepositoryImpl(sl<profile_ds.ProfileRemoteDataSource>()),
  );

  // ===== Use Cases (Auth) =====
  sl.registerSingleton<LoginUseCase>(LoginUseCase(sl<AuthRepository>()));
  sl.registerSingleton<LogoutUseCase>(LogoutUseCase(sl<AuthRepository>()));
  sl.registerSingleton<SignupUseCase>(SignupUseCase(sl<AuthRepository>()));
  sl.registerSingleton<VerifyOneTimePasswordUseCase>(
    VerifyOneTimePasswordUseCase(sl<AuthRepository>()),
  );
  sl.registerSingleton<ValidateOneTimePasswordUseCase>(
    ValidateOneTimePasswordUseCase(sl<AuthRepository>()),
  );
  sl.registerSingleton<GenerateTwoFactorAuthenticationConfigUseCase>(
    GenerateTwoFactorAuthenticationConfigUseCase(sl<AuthRepository>()),
  );
  sl.registerSingleton<DisableTwoFactorAuthenticationUseCase>(
    DisableTwoFactorAuthenticationUseCase(sl<AuthRepository>()),
  );
  sl.registerSingleton<CheckIfAccountHasTwoFactorAuthenticationEnabledUseCase>(
    CheckIfAccountHasTwoFactorAuthenticationEnabledUseCase(sl<AuthRepository>()),
  );
  sl.registerSingleton<RecoverAccountWithTwoFactorAuthenticationAndPasswordUseCase>(
    RecoverAccountWithTwoFactorAuthenticationAndPasswordUseCase(sl<AuthRepository>()),
  );
  sl.registerSingleton<RecoverAccountWithTwoFactorAuthenticationAndOneTimePasswordUseCase>(
    RecoverAccountWithTwoFactorAuthenticationAndOneTimePasswordUseCase(sl<AuthRepository>()),
  );
  sl.registerSingleton<RecoverAccountWithoutTwoFactorAuthenticationEnabledUseCase>(
    RecoverAccountWithoutTwoFactorAuthenticationEnabledUseCase(sl<AuthRepository>()),
  );

  // ===== Use Cases (Profile) =====
  sl.registerSingleton<GetProfileUsecase>(GetProfileUsecase(sl<ProfileRepository>()));
  sl.registerSingleton<PostProfileUsecase>(PostProfileUsecase(sl<ProfileRepository>()));
  sl.registerSingleton<SetPasswordUseCase>(SetPasswordUseCase(sl<ProfileRepository>()));
  sl.registerSingleton<UpdatePasswordUseCase>(UpdatePasswordUseCase(sl<ProfileRepository>()));
  sl.registerSingleton<GetDevicesUsecase>(GetDevicesUsecase(sl<ProfileRepository>()));
  sl.registerSingleton<DeleteDeviceUseCase>(DeleteDeviceUseCase(sl<ProfileRepository>()));
}
  