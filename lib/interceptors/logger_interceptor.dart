import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class LoggerInterceptor {
  LoggerInterceptor._();

  static PrettyDioLogger get instance => PrettyDioLogger(
        requestBody: true,
        enabled: true,
      );
}
