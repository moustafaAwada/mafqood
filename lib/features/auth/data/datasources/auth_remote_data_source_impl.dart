import 'package:mafqood/core/error/exceptions.dart';
import 'package:mafqood/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:mafqood/features/auth/data/models/auth_models.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<RegisterResponse> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    throw const ServerException(
      'Auth API not configured. Implement AuthRemoteDataSourceImpl with your backend.',
    );
  }

  @override
  Future<String> resendConfirmationEmail({required String email}) async {
    throw const ServerException('Auth API not configured.');
  }

  @override
  Future<AuthResponse> confirmEmail({
    required String userId,
    required String code,
  }) async {
    throw const ServerException('Auth API not configured.');
  }

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    throw const ServerException('Auth API not configured.');
  }

  @override
  Future<ForgetPasswordResponse> forgetPassword({required String email}) async {
    throw const ServerException('Auth API not configured.');
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    throw const ServerException('Auth API not configured.');
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> revokeTokenIfNeeded() async {}
}
