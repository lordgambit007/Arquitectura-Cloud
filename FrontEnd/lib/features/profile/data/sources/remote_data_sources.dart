// lib/features/profile/data/sources/remote_data_sources.dart
import 'dart:convert';

import 'package:flutteractixapp/core/messages/errors/data_error.dart' as core_errors;
import 'package:flutteractixapp/features/auth/data/errors/data_error.dart' as auth_errors;

import 'package:flutteractixapp/features/profile/data/errors/data_error.dart' as profile_errors;
import 'package:flutteractixapp/features/profile/data/models/device_model.dart';
import 'package:flutteractixapp/features/profile/data/models/profile_model.dart';
import 'package:flutteractixapp/features/profile/data/models/profile_request_model.dart';
import 'package:http_interceptor/http_interceptor.dart';

class ProfileRemoteDataSource {
  final InterceptedClient apiClient;
  final String baseUrl;

  ProfileRemoteDataSource({required this.apiClient, required this.baseUrl});

  Future<ProfileModel> getProfileInformation() async {
    final url = Uri.parse('$baseUrl/users/me');
    final response = await apiClient.get(url);

    final raw = response.body;
    final decoded = raw.isEmpty ? null : json.decode(raw);

    if (response.statusCode == 200) {
      try {
        return ProfileModel.fromJson(decoded['user']);
      } catch (_) {
        throw core_errors.ParsingError();
      }
    }

    if (response.statusCode == 401) throw core_errors.UnauthorizedError();
    if (response.statusCode == 500) throw core_errors.InternalServerError();
    throw core_errors.UnknownError();
  }

  Future<ProfileModel> postProfileInformation(
      UpdateProfileRequestModel profile) async {
    final url = Uri.parse('$baseUrl/users/me');
    final response = await apiClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(profile.toJson()),
    );

    final raw = response.body;
    final decoded = raw.isEmpty ? null : json.decode(raw);

    if (response.statusCode == 200) {
      try {
        return ProfileModel.fromJson(decoded['user']);
      } catch (_) {
        throw core_errors.ParsingError();
      }
    }

    if (response.statusCode == 401) throw core_errors.UnauthorizedError();
    if (response.statusCode == 500) throw core_errors.InternalServerError();
    throw core_errors.UnknownError();
  }

  Future<ProfileModel> setPassword(
      SetPasswordRequestModel setPasswordRequestModel) async {
    final url = Uri.parse('$baseUrl/users/set-password');
    final response = await apiClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(setPasswordRequestModel.toJson()),
    );

    final raw = response.body;
    final decoded = raw.isEmpty ? null : json.decode(raw);
    final responseCode =
        (decoded is Map && decoded['code'] is String) ? decoded['code'] as String : null;

    if (response.statusCode == 200) {
      try {
        return ProfileModel.fromJson(decoded['user']);
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
      throw core_errors.UnauthorizedError();
    }

    if (response.statusCode == 403) {
      if (responseCode == 'PASSWORD_NOT_EXPIRED') {
        throw profile_errors.PasswordNotExpiredError();
      }
      throw core_errors.ForbiddenError();
    }

    if (response.statusCode == 500) throw core_errors.InternalServerError();
    throw core_errors.UnknownError();
  }

  Future<ProfileModel> updatePassword(
      UpdatePasswordRequestModel updatePasswordRequestModel) async {
    final url = Uri.parse('$baseUrl/users/update-password');
    final response = await apiClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatePasswordRequestModel.toJson()),
    );

    final raw = response.body;
    final decoded = raw.isEmpty ? null : json.decode(raw);
    final responseCode =
        (decoded is Map && decoded['code'] is String) ? decoded['code'] as String : null;

    if (response.statusCode == 200) {
      try {
        return ProfileModel.fromJson(decoded['user']);
      } catch (_) {
        throw core_errors.ParsingError();
      }
    }

    if (response.statusCode == 401) {
      if (responseCode == 'INVALID_USERNAME_OR_PASSWORD') {
        throw auth_errors.InvalidUsernameOrPasswordError();
      }
      if (responseCode == 'PASSWORD_TOO_SHORT') {
        throw auth_errors.PasswordTooShortError();
      }
      if (responseCode == 'PASSWORD_TOO_WEAK') {
        throw auth_errors.PasswordNotComplexEnoughError();
      }
      throw core_errors.UnauthorizedError();
    }

    if (response.statusCode == 500) throw core_errors.InternalServerError();
    throw core_errors.UnknownError();
  }

  /// DEVUELVE LISTA VACÍA si el backend responde 200 con cuerpo vacío o no-JSON.
  Future<List<DeviceModel>> getDevices() async {
    final url = Uri.parse('$baseUrl/devices/');
    final response = await apiClient.get(url);

    final body = response.body;
    final trimmed = body.trim();

    // ✅ cuerpos vacíos o whitespace → lista vacía
    if (trimmed.isEmpty) return [];

    try {
      final decoded = json.decode(trimmed);

      if (response.statusCode == 200) {
        if (decoded is Map && decoded['devices'] is List) {
          final List<dynamic> devices = decoded['devices'];
          return devices.map((d) => DeviceModel.fromJson(d)).toList();
        }
        if (decoded is List) {
          return decoded.map((d) => DeviceModel.fromJson(d)).toList();
        }
        // si vino algo raro pero es 200, no rompas la app
        return [];
      }

      if (response.statusCode == 401) throw core_errors.UnauthorizedError();
      if (response.statusCode == 500) throw core_errors.InternalServerError();
      throw core_errors.UnknownError();
    } on FormatException {
      // ✅ contenido no-JSON → lista vacía
      return [];
    }
  }

  Future<void> deleteDevice(String deviceId) async {
    final url = Uri.parse('$baseUrl/devices/$deviceId');
    final response = await apiClient.delete(url);

    if (response.statusCode == 200) return;

    if (response.statusCode == 401) throw core_errors.UnauthorizedError();
    if (response.statusCode == 500) throw core_errors.InternalServerError();
    throw core_errors.UnknownError();
  }
}
