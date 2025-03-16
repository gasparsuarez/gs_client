import 'package:dio/dio.dart';
import 'package:gs_client/exceptions/custom_exception.dart';

class ExceptionHandler {
  ExceptionHandler._();

  static CustomException handle(Exception exception) {
    int statusCode = 500;
    String errorMessage = 'Internal Server Error';

    // Socket Exception
    if (exception is DioException) {
      if (exception.type == DioExceptionType.connectionError) {
        return InternetConnectionException(
          message: 'Error de conexión',
          statusCode: statusCode,
        );
      }

      if (exception.response != null) {
        statusCode = exception.response!.statusCode!;
        errorMessage = exception.response!.data['error'];
      }
    }

    if (exception is UnauthorizedException) {
      statusCode = exception.statusCode!;
      errorMessage = exception.message!;
    }

    return switch (statusCode) {
      400 => BadRequestException(message: errorMessage, statusCode: statusCode),
      401 => UnauthorizedException(message: errorMessage, statusCode: statusCode),
      404 => NotFoundException(message: errorMessage, statusCode: statusCode),
      int() => InternalServerException(message: errorMessage, statusCode: statusCode),
    };
  }
}
