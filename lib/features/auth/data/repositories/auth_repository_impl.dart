import 'package:mafqood/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:mafqood/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:mafqood/features/auth/data/models/auth_models.dart';
import 'package:mafqood/features/auth/domain/entities/auth_results.dart';
import 'package:mafqood/features/auth/domain/repositories/auth_repository.dart';

/// Repository implementation lives in data layer.
/// Depends on remote and local data sources; maps data models to domain types.
/// Cubit depends only on domain [AuthRepository]; this class is injected at app level.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  AuthUserResult _authResponseToResult(AuthResponse r) => AuthUserResult(
        id: r.id,
        email: r.email,
        name: r.name,
        phoneNumber: r.phoneNumber,
      );

  @override
  Future<RegisterResult> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    final response = await _remote.register(
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
    );
    return RegisterResult(userId: response.userId);
  }

  @override
  Future<String> resendConfirmationEmail({required String email}) async {
    return _remote.resendConfirmationEmail(email: email);
  }

  @override
  Future<AuthUserResult> confirmEmail({
    required String userId,
    required String code,
  }) async {
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
    return _authResponseToResult(response);
  }

  @override
  Future<AuthUserResult> login({
    required String email,
    required String password,
  }) async {
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
    return _authResponseToResult(response);
  }

  @override
  Future<ForgetPasswordResult> forgetPassword({required String email}) async {
    final response = await _remote.forgetPassword(email: email);
    return ForgetPasswordResult(email: response.email);
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _remote.resetPassword(
      email: email,
      code: code,
      newPassword: newPassword,
    );
  }

  @override
  Future<void> logout() async {
    await _remote.revokeTokenIfNeeded();
    await _local.clearAll();
  }

  @override
  Future<bool> isLoggedIn() async => _local.isLoggedIn();

  @override
  Future<Map<String, dynamic>?> getStoredUserData() async =>
      _local.getStoredUserData();
}
