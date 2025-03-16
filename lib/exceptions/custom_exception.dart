sealed class CustomException implements Exception {
  final String? message;
  final int? statusCode;

  CustomException({
    required this.message,
    required this.statusCode,
  });
}

final class BadRequestException extends CustomException {
  BadRequestException({required super.message, required super.statusCode});
}

final class UnauthorizedException extends CustomException {
  UnauthorizedException({required super.message, required super.statusCode});
}

final class NotFoundException extends CustomException {
  NotFoundException({required super.message, required super.statusCode});
}

final class InternetConnectionException extends CustomException {
  InternetConnectionException({required super.message, required super.statusCode});
}

final class InternalServerException extends CustomException {
  InternalServerException({required super.message, required super.statusCode});
}
