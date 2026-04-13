import 'package:mafqood/core/api/api_consumer.dart';
import 'package:mafqood/core/api/end_points.dart';
import 'package:mafqood/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:mafqood/features/auth/data/models/auth_models.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiConsumer _api;

  AuthRemoteDataSourceImpl({required ApiConsumer api}) : _api = api;

  Map<String, dynamic> _unwrapData(dynamic response) {
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
    }
    return response as Map<String, dynamic>;
  }

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
    );
    final response = await _api.post(
      EndPoints.register,
      data: request.toJson(),
    );
    return RegisterResponse.fromJson(_unwrapData(response));
  }

  @override
  Future<String> resendConfirmationEmail({required String email}) async {
    final request = ForgetPasswordRequest(email: email);
    final response = await _api.post(
      EndPoints.resendConfirmationEmail,
      data: request.toJson(),
    );
    final data = _unwrapData(response);
    return data['userId'] as String? ?? '';
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
    return AuthResponse.fromJson(_unwrapData(response));
  }

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final request = LoginRequest(
      email: email,
      password: password,
    );
    final response = await _api.post(EndPoints.login, data: request.toJson());
    return AuthResponse.fromJson(_unwrapData(response));
  }

  @override
  Future<ForgetPasswordResponse> forgetPassword({required String email}) async {
    final request = ForgetPasswordRequest(email: email);
    final response = await _api.post(
      EndPoints.forgetPassword,
      data: request.toJson(),
    );
    return ForgetPasswordResponse.fromJson(_unwrapData(response));
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
  Future<AuthResponse> refreshToken({
    required String token,
    required String refreshToken,
  }) async {
    final response = await _api.post(
      EndPoints.refreshToken,
      data: {'token': token, 'refreshToken': refreshToken},
    );
    return AuthResponse.fromJson(_unwrapData(response));
  }

  @override
  Future<void> revokeRefreshToken({
    required String token,
    required String refreshToken,
  }) async {
    await _api.post(
      EndPoints.revokeRefreshToken,
      data: {'token': token, 'refreshToken': refreshToken},
    );
  }
}
