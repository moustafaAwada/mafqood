import 'package:dartz/dartz.dart';
import 'package:mafqood/core/error/failures.dart';
import 'package:mafqood/features/auth/domain/entities/auth_results.dart';

abstract class AuthRepository {
  Future<Either<Failure, RegisterResult>> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  });

  Future<Either<Failure, String>> resendConfirmationEmail({
    required String email,
  });

  Future<Either<Failure, AuthUserResult>> confirmEmail({
    required String userId,
    required String code,
  });

  Future<Either<Failure, AuthUserResult>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, ForgetPasswordResult>> forgetPassword({
    required String email,
  });

  Future<Either<Failure, Unit>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });

  Future<Either<Failure, AuthUserResult>> refreshToken({
    required String token,
    required String refreshToken,
  });

  Future<Either<Failure, Unit>> revokeRefreshToken({
    required String token,
    required String refreshToken,
  });

  Future<Either<Failure, Unit>> logout();

  Future<bool> isLoggedIn();

  Future<Map<String, dynamic>?> getStoredUserData();

  Future<String?> getAccessToken();

  Future<String?> getRefreshToken();
}
