import 'package:mafqood/features/auth/domain/entities/auth_results.dart';

abstract class AuthRepository {
  Future<RegisterResult> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  });

  Future<String> resendConfirmationEmail({required String email});

  Future<AuthUserResult> confirmEmail({
    required String userId,
    required String code,
  });

  Future<AuthUserResult> login({
    required String email,
    required String password,
  });

  Future<ForgetPasswordResult> forgetPassword({required String email});

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });

  Future<void> logout();

  Future<bool> isLoggedIn();

  Future<Map<String, dynamic>?> getStoredUserData();
}
