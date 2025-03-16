import 'package:dartz/dartz.dart';
import 'package:gs_client/errors/custom_error.dart';
import 'package:gs_client/exceptions/custom_exception.dart';

class ApiHandler<T> {
  static Future<Either<CustomError, T>> execute<T>(Function() callback) async {
    try {
      final T response = await callback();
      return Right(response);
    } on CustomException catch (e) {
      return Left(_getError(e));
    }
  }

  static CustomError _getError(CustomException e) => switch (e) {
        UnauthorizedException(:final message) => UnauthorizedError(message: message!),
        InternetConnectionException(:final message) => InternetConnectionError(message: message!),
        BadRequestException(:final message) => BadRequestError(message: message!),
        NotFoundException(:final message) => NotFoundError(message: message!),
        CustomException(:final message) => InternalServerError(message: message!),
      };
}
