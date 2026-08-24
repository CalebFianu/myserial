import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._ref);
  final Ref _ref;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final storage = _ref.read(secureStorageProvider);
    final token = await storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Attempt token refresh
      final storage = _ref.read(secureStorageProvider);
      final refreshToken = await storage.getRefreshToken();

      if (refreshToken != null) {
        try {
          final dio = Dio(BaseOptions(
            baseUrl: err.requestOptions.baseUrl,
          ));
          final response = await dio.post<dynamic>('/auth/refresh', data: {
            'refreshToken': refreshToken,
          });

          final newToken = response.data['accessToken'] as String?;
          final newRefresh = response.data['refreshToken'] as String?;

          if (newToken != null) {
            await storage.saveTokens(
              accessToken: newToken,
              refreshToken: newRefresh ?? refreshToken,
            );

            // Retry original request
            err.requestOptions.headers['Authorization'] =
                'Bearer $newToken';
            final retryResponse = await Dio().fetch<dynamic>(
              err.requestOptions,
            );
            return handler.resolve(retryResponse);
          }
        } catch (_) {
          // Refresh failed — clear tokens and propagate error
          await storage.clearTokens();
        }
      }
    }
    handler.next(err);
  }
}
