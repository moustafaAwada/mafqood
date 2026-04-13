import 'package:dartz/dartz.dart';
import 'package:mafqood/core/error/failures.dart';

abstract class AccountRepository {
  Future<Either<Failure, Unit>> updateLocation({
    required double latitude,
    required double longitude,
  });
}
