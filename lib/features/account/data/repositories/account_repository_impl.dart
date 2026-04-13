import 'package:dartz/dartz.dart';
import 'package:mafqood/core/error/exceptions.dart';
import 'package:mafqood/core/error/failures.dart';
import 'package:mafqood/features/account/data/datasources/account_remote_data_source.dart';
import 'package:mafqood/features/account/domain/repositories/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource _remote;

  AccountRepositoryImpl({required AccountRemoteDataSource remote})
      : _remote = remote;

  @override
  Future<Either<Failure, Unit>> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _remote.updateLocation(latitude: latitude, longitude: longitude);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
