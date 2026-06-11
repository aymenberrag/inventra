import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../storage/token_storage.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static bool _initialized = false;

  static void init() {
    if (_initialized) return;
    _initialized = true;

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 &&
              error.requestOptions.path != '/auth/login' &&
              error.requestOptions.path != '/auth/register' &&
              error.requestOptions.path != '/auth/refresh') {
            final refreshed = await _refreshToken();
            if (refreshed) {
              final token = await TokenStorage.getAccessToken();
              error.requestOptions.headers['Authorization'] = 'Bearer $token';
              final response = await dio.fetch(error.requestOptions);
              return handler.resolve(response);
            }
            await TokenStorage.clear();
          }
          handler.next(error);
        },
      ),
    );
  }

  static Future<bool> _refreshToken() async {
    final refreshToken = await TokenStorage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          headers: {'Content-Type': 'application/json'},
        ),
      ).post(
        '/auth/refresh',
        options: Options(headers: {'Authorization': 'Bearer $refreshToken'}),
      );

      final accessToken = response.data['access_token'] as String?;
      if (accessToken != null) {
        await TokenStorage.saveAccessToken(accessToken);
        return true;
      }
    } catch (_) {}
    return false;
  }
}
