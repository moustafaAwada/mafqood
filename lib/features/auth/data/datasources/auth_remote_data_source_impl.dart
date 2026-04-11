import 'package:mafqood/core/api/api_consumer.dart';
import 'package:mafqood/core/api/end_points.dart';
import 'package:mafqood/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:mafqood/features/auth/data/models/auth_models.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiConsumer _api;

  AuthRemoteDataSourceImpl({required ApiConsumer api}) : _api = api;

  @override
  Future<RegisterResponse> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    final request = RegisterRequest(
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      deviceId: '',
    );
    final response = await _api.post(
      EndPoints.register,
      data: request.toJson(),
    );
    return RegisterResponse.fromJson(response);
  }

  @override
  Future<String> resendConfirmationEmail({required String email}) async {
    final request = ForgetPasswordRequest(email: email);
    final response = await _api.post(
      EndPoints.resendConfirmationEmail,
      data: request.toJson(),
    );
    return response['userId'];
  }

  @override
  Future<AuthResponse> confirmEmail({
    required String userId,
    required String code,
  }) async {
    final request = ConfirmEmailRequest(userId: userId, code: code);
    final response = await _api.post(
      EndPoints.confirmEmail,
      data: request.toJson(),
    );
    return AuthResponse.fromJson(response);
  }

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final request = LoginRequest(
      email: email,
      password: password,
      deviceId: '',
    );
    final response = await _api.post(EndPoints.login, data: request.toJson());
    return AuthResponse.fromJson(response);
  }

  @override
  Future<ForgetPasswordResponse> forgetPassword({required String email}) async {
    final request = ForgetPasswordRequest(email: email);
    final response = await _api.post(
      EndPoints.forgetPassword,
      data: request.toJson(),
    );
    return ForgetPasswordResponse.fromJson(response);
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final request = ResetPasswordRequest(
      email: email,
      code: code,
      newPassword: newPassword,
    );
    await _api.post(EndPoints.resetPassword, data: request.toJson());
  }

  @override
  Future<void> logout() async {
    // Implement if there's a logout endpoint
  }

  @override
  Future<void> revokeTokenIfNeeded() async {
    // Implement if needed
  }
}
