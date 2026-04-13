import 'package:dio/dio.dart';
import 'package:mafqood/core/api/end_points.dart';
import 'package:mafqood/core/database/auth_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final AuthStorage authStorage;

  AuthInterceptor({required this.dio, required this.authStorage});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await authStorage.getToken();
    if (token != null && options.headers['Authorization'] == null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    final shouldRetry = requestOptions.extra['retry'] != true;
    final isAuthEndpoint =
        requestOptions.path.contains(EndPoints.refreshToken) ||
        requestOptions.path.contains(EndPoints.revokeRefreshToken);

    if (err.response?.statusCode == 401 && shouldRetry && !isAuthEndpoint) {
      final currentToken = await authStorage.getToken();
      final refreshToken = await authStorage.getRefreshToken();

      if (currentToken != null && refreshToken != null) {
        try {
          final refreshResponse =
              await Dio(BaseOptions(baseUrl: dio.options.baseUrl)).post(
                EndPoints.refreshToken,
                data: {'token': currentToken, 'refreshToken': refreshToken},
              );

          final data = refreshResponse.data['data'] as Map<String, dynamic>?;
          if (data != null) {
            final expiresIn =
                data['expiresIn'] as int? ?? data['expirseIn'] as int? ?? 3600;
            final refreshTokenExpirationRaw =
                data['refreshTokenExpiration'] as String?;
            final refreshTokenExpiration = refreshTokenExpirationRaw != null
                ? DateTime.parse(refreshTokenExpirationRaw)
                : DateTime.now().add(const Duration(days: 7));

            await authStorage.saveAuthResponse(
              token: data['token'] as String,
              refreshToken: data['refreshToken'] as String,
              expiresIn: expiresIn,
              refreshTokenExpiration: refreshTokenExpiration,
            );

            requestOptions.headers['Authorization'] =
                'Bearer ${data['token'] as String}';
            requestOptions.extra['retry'] = true;

            final retryResponse = await dio.fetch(requestOptions);
            return handler.resolve(retryResponse);
          }
        } catch (_) {
          await authStorage.clear();
        }
      }
    }

    handler.next(err);
  }
}
