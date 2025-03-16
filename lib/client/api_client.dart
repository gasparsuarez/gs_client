import 'package:dio/dio.dart';
import 'package:gs_client/config/client_config.dart';
import 'package:gs_client/handlers/exception_handler.dart';

enum HttpMethod {
  get,
  post,
  put,
}

abstract class ApiClient {
  Future<Response<dynamic>> request({
    required HttpMethod method,
    required String path,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  });
}

class IApiClient implements ApiClient {
  late Dio _dio;

  final ClientConfig config;

  IApiClient({
    required this.config,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        sendTimeout: config.sendTimeout,
        receiveTimeout: config.receiveTimeout,
        connectTimeout: config.connectTimeout,
      ),
    )..interceptors.addAll(config.interceptors ?? []);
  }

  @override
  Future<Response> request({
    required HttpMethod method,
    required String path,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.request(
        path,
        data: body,
        queryParameters: queryParameters,
        options: Options(
          method: method.name.toUpperCase(),
        ),
      );
      return response;
    } on Exception catch (e) {
      throw ExceptionHandler.handle(e);
    }
  }
}
