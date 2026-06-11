import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/storage/token_storage.dart';

class AuthService {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> googleSignIn({
    required String idToken,
    String? fullName,
    String? email,
  }) async {
    final response = await ApiClient.dio.post(
      '/auth/google',
      data: {
        'id_token': idToken,
        if (fullName != null) 'full_name': fullName,
        if (email != null) 'email': email,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.dio.post(
      '/auth/register',
      data: {
        'full_name': fullName,
        'email': email,
        'password': password,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMe() async {
    final response = await ApiClient.dio.get('/auth/me');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    String? language,
  }) async {
    final data = <String, dynamic>{};
    if (fullName != null) data['full_name'] = fullName;
    if (language != null) data['language'] = language;

    final response = await ApiClient.dio.patch('/auth/me', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<void> saveAuthResponse(Map<String, dynamic> response) async {
    await TokenStorage.saveTokens(
      accessToken: response['access_token'] as String,
      refreshToken: response['refresh_token'] as String,
    );
  }

  Future<void> logout() async {
    await TokenStorage.clear();
  }

  String parseError(dynamic error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        if (data['message'] != null) return data['message'].toString();
        if (data['errors'] is Map) {
          return (data['errors'] as Map).values.first.toString();
        }
      }
      return error.message ?? 'Something went wrong';
    }
    return error.toString();
  }
}

class UserModel {
  final int id;
  final String fullName;
  final String email;
  final String language;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.language,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      language: json['language'] as String? ?? 'en',
    );
  }
}
