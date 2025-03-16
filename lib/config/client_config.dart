import 'package:dio/dio.dart';

class ClientConfig {
  ClientConfig({
    required this.baseUrl,
    this.sendTimeout = const Duration(milliseconds: 15000),
    this.receiveTimeout = const Duration(milliseconds: 15000),
    this.connectTimeout = const Duration(milliseconds: 15000),
    this.interceptors = const [],
  });

  final String baseUrl;
  final Duration? sendTimeout;
  final Duration? receiveTimeout;
  final Duration? connectTimeout;
  final List<Interceptor>? interceptors;
}
