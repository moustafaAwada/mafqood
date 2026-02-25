// import 'package:mafqood/features/auth/data/datasources/auth_remote_data_source.dart';
// import 'package:mafqood/features/auth/data/models/auth_models.dart';
// import 'package:mafqood/features/auth/domain/repositories/auth_repository.dart';

// class AuthRepositoryImpl implements AuthRepository {
//   final AuthService _authService;

//   AuthRepositoryImpl({AuthService? authService})
//       : _authService = authService ?? AuthService();

//   @override
//   Future<RegisterResponse> register({
//     required String name,
//     required String email,
//     required String phoneNumber,
//     required String password,
//   }) {
//     return _authService.register(
//       name: name,
//       email: email,
//       phoneNumber: phoneNumber,
//       password: password,
//     );
//   }

//   @override
//   Future<String> resendConfirmationEmail({required String email}) {
//     return _authService.resendConfirmationEmail(email: email);
//   }

//   @override
//   Future<AuthResponse> confirmEmail({
//     required String userId,
//     required String code,
//   }) {
//     return _authService.confirmEmail(userId: userId, code: code);
//   }

//   @override
//   Future<AuthResponse> login({
//     required String email,
//     required String password,
//   }) {
//     return _authService.login(email: email, password: password);
//   }

//   @override
//   Future<ForgetPasswordResponse> forgetPassword({required String email}) {
//     return _authService.forgetPassword(email: email);
//   }

//   @override
//   Future<void> resetPassword({
//     required String email,
//     required String code,
//     required String newPassword,
//   }) {
//     return _authService.resetPassword(
//       email: email,
//       code: code,
//       newPassword: newPassword,
//     );
//   }

//   @override
//   Future<void> logout() {
//     return _authService.logout();
//   }

//   @override
//   Future<bool> isLoggedIn() {
//     return _authService.isLoggedIn();
//   }

//   @override
//   Future<Map<String, dynamic>?> getStoredUserData() {
//     return _authService.getStoredUserData();
//   }
// }
