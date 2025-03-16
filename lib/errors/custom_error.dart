abstract final class CustomError {
  final String message;

  CustomError({required this.message});
}

final class UnauthorizedError extends CustomError {
  UnauthorizedError({required super.message});
}

final class InternetConnectionError extends CustomError {
  InternetConnectionError({required super.message});
}

final class BadRequestError extends CustomError {
  BadRequestError({required super.message});
}

final class NotFoundError extends CustomError {
  NotFoundError({required super.message});
}

final class InternalServerError extends CustomError {
  InternalServerError({required super.message});
}
