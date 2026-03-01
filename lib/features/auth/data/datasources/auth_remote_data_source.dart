import 'package:mafqood/features/auth/data/models/auth_models.dart';

abstract class AuthRemoteDataSource {
  Future<RegisterResponse> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  });

  Future<String> resendConfirmationEmail({required String email});

  Future<AuthResponse> confirmEmail({
    required String userId,
    required String code,
  });

  Future<AuthResponse> login({required String email, required String password});

  Future<ForgetPasswordResponse> forgetPassword({required String email});

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });

  Future<void> logout();

  Future<void> revokeTokenIfNeeded();
}
