import 'package:dartz/dartz.dart';
import 'package:mafqood/core/error/exceptions.dart';
import 'package:mafqood/core/error/failures.dart';
import 'package:mafqood/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:mafqood/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:mafqood/features/auth/data/models/auth_models.dart';
import 'package:mafqood/features/auth/domain/entities/auth_results.dart';
import 'package:mafqood/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
  }) : _remote = remote,
       _local = local;

  AuthUserResult _authResponseToResult(AuthResponse r) => AuthUserResult(
    id: r.id,
    email: r.email,
    name: r.name,
    phoneNumber: r.phoneNumber,
  );

  @override
  Future<Either<Failure, RegisterResult>> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final response = await _remote.register(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );
      return Right(RegisterResult(userId: response.userId));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> resendConfirmationEmail({
    required String email,
  }) async {
    try {
      final userId = await _remote.resendConfirmationEmail(email: email);
      return Right(userId);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthUserResult>> confirmEmail({
    required String userId,
    required String code,
  }) async {
    try {
      final response = await _remote.confirmEmail(userId: userId, code: code);
      await _local.saveTokens(
        accessToken: response.token,
        refreshToken: response.refreshToken,
        expiresIn: response.expiresIn,
        refreshTokenExpiration: response.refreshTokenExpiration,
      );
      await _local.saveUserData({
        'id': response.id,
        'email': response.email,
        'name': response.name,
        'phoneNumber': response.phoneNumber,
      });
      return Right(_authResponseToResult(response));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthUserResult>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remote.login(email: email, password: password);
      await _local.saveTokens(
        accessToken: response.token,
        refreshToken: response.refreshToken,
        expiresIn: response.expiresIn,
        refreshTokenExpiration: response.refreshTokenExpiration,
      );
      await _local.saveUserData({
        'id': response.id,
        'email': response.email,
        'name': response.name,
        'phoneNumber': response.phoneNumber,
      });
      return Right(_authResponseToResult(response));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ForgetPasswordResult>> forgetPassword({
    required String email,
  }) async {
    try {
      final response = await _remote.forgetPassword(email: email);
      return Right(ForgetPasswordResult(email: response.email));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _remote.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      );
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _remote.revokeTokenIfNeeded();
      await _local.clearAll();
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<bool> isLoggedIn() async => _local.isLoggedIn();

  @override
  Future<Map<String, dynamic>?> getStoredUserData() async =>
      _local.getStoredUserData();
}
