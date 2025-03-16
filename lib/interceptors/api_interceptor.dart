import 'dart:io';

import 'package:dio/dio.dart';
import 'package:gs_client/exceptions/custom_exception.dart';

class ApiInterceptor extends InterceptorsWrapper {
  bool _isRefreshing = false;

  static final Dio dio = Dio();

  /// Constructor
  /// [onTokenRefresh] Function to refresh token
  ///
  /// [setBearerTokenInRequest] Function to set token for request
  ///
  /// [onUnauthorizedError] Function to handle unauthorized failure
  ///
  /// [handleUnauthorizedFailure] If true, the interceptor will handle unauthorized errors
  ///
  /// [setRefreshToken] should get refresh storage from the storage
  ///
  /// [setTokenInRequest] If true, the interceptor will set the token in the request
  ApiInterceptor({
    this.onTokenRefresh,
    this.setBearerTokenInRequest,
    this.onUnauthorizedError,
    this.handleUnauthorizedFailure = false,
    this.setRefreshToken,
    this.setTokenInRequest = false,
  });

  /// Function to refresh token
  ///
  /// should call the API to refresh the token and save it in the storage
  ///
  /// then put new token in the headers
  ///
  /// this function should return a Future with the new token
  final Future<String> Function()? onTokenRefresh;

  /// Function to set token for request
  ///
  /// should get the token from the storage
  final Future<String?> Function()? setBearerTokenInRequest;

  /// Function to handle unauthorized failure
  ///
  /// should emit an event to handle unauthorized failure
  ///
  /// should remove the credentials from the storage
  final void Function()? onUnauthorizedError;

  ///
  /// should get refresh storage from the storage
  final Future<String?> Function()? setRefreshToken;

  /// If true, the interceptor will handle unauthorized errors
  final bool handleUnauthorizedFailure;

  /// If true, the interceptor will set the token in the request
  final bool setTokenInRequest;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!setTokenInRequest) {
      return handler.next(options);
    }

    assert(setBearerTokenInRequest != null, 'setBearerTokenInRequest is required');

    final token = await setBearerTokenInRequest!();

    /// Add token to headers
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (!handleUnauthorizedFailure) {
      return handler.next(err);
    }

    assert(onTokenRefresh != null, 'generateNewToken is required');
    assert(setRefreshToken != null, 'setRefreshToken is required');
    assert(onUnauthorizedError != null, 'onUnauthorizedFailure is required');

    if (err.response?.statusCode == HttpStatus.unauthorized && !_isRefreshing) {
      try {
        _isRefreshing = true;
        final refreshToken = await setRefreshToken!();

        /// Si no hay credenciales, no podemos hacer refresh
        if (refreshToken == null) {
          onUnauthorizedError!();
          return handler.next(err);
        }
        // Intentamos refrescar el token
        try {
          final token = onTokenRefresh!();
          // Actualizamos la petición con el nuevo token
          err.requestOptions.headers['Authorization'] = 'Bearer $token';
          return handler.resolve(await dio.fetch(err.requestOptions));
        } catch (e) {
          // Si falla el refresh, eliminamos las credenciales y emitimos estado de no autorizado
          if (e is UnauthorizedException) {
            String errorMessage = 'Unauthorized';
            if (err.response != null) {
              errorMessage = e.message!;
            }

            // Devolvemos un error con status 401
            // para que el interceptor de error de la petición
            // lo maneje correctamente
            // y no se ejecute el handler.next(err)
            return handler.reject(
              DioException(
                requestOptions: err.requestOptions,
                response: Response(
                  statusCode: HttpStatus.unauthorized,
                  statusMessage: errorMessage,
                  data: {'error': errorMessage},
                  requestOptions: err.requestOptions,
                ),
              ),
            );
          }
        }
      } catch (e) {
        onUnauthorizedError!();
        return handler.reject(err);
      } finally {
        _isRefreshing = false;
      }
    }
    handler.next(err);
  }
}
