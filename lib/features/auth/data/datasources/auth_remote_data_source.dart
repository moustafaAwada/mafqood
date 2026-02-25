

// import '../models/auth_models.dart';

// class AuthService {
//   final ApiClient _apiClient;
//   final StorageService _storageService;
//   final DeviceService _deviceService;
//   final TokenService _tokenService;

//   AuthService({
//     ApiClient? apiClient,
//     StorageService? storageService,
//     DeviceService? deviceService,
//     TokenService? tokenService,
//   })  : _apiClient = apiClient ?? ApiClient(),
//         _storageService = storageService ?? StorageService(),
//         _deviceService = deviceService ?? DeviceService(),
//         _tokenService = tokenService ?? TokenService();

//   Future<RegisterResponse> register({
//     required String name,
//     required String email,
//     required String phoneNumber,
//     required String password,
//   }) async {
//     final deviceId = await _deviceService.getDeviceId();

//     final request = RegisterRequest(
//       name: name,
//       email: email,
//       phoneNumber: phoneNumber,
//       password: password,
//       deviceId: deviceId,
//     );

//     final response = await _apiClient.post<Map<String, dynamic>>(
//       ApiEndpoints.register,
//       body: request.toJson(),
//       fromJson: (data) => data as Map<String, dynamic>,
//     );

//     if (response.isSuccess && response.data != null) {
//       return RegisterResponse.fromJson(response.data!);
//     }

//     throw Exception(response.errorMessage);
//   }

//   /// Resend confirmation email
//   Future<String> resendConfirmationEmail({required String email}) async {
//     try {
//       final response = await _apiClient.post<Map<String, dynamic>>(
//         ApiEndpoints.resendConfirmationEmail,
//         body: {'email': email},
//         fromJson: (data) => data as Map<String, dynamic>,
//       );

//       if (response.isSuccess && response.data != null) {
//         return response.data!['userId'] ?? '';
//       }
      
//       throw Exception(response.errorMessage);
//     } on ApiException catch (e) {
//       // Special handling for backend flaw:
//       if (e.statusCode == 400 && e.data != null && e.data is Map) {
//          final data = e.data as Map<String, dynamic>;
//          if (data.containsKey('userId')) {
//            return data['userId'];
//          }
//       }
//       rethrow;
//     }
//   }

//   Future<AuthResponse> confirmEmail({
//     required String userId,
//     required String code,
//   }) async {
//     final request = ConfirmEmailRequest(userId: userId, code: code);

//     final response = await _apiClient.post<Map<String, dynamic>>(
//       ApiEndpoints.confirmEmail,
//       body: request.toJson(),
//       fromJson: (data) => data as Map<String, dynamic>,
//     );

//     if (response.isSuccess && response.data != null) {
//       final authResponse = AuthResponse.fromJson(response.data!);
//       await _saveAuthData(authResponse);
//       return authResponse;
//     }

//     throw Exception(response.errorMessage);
//   }

//   /// Login with email and password
//   Future<AuthResponse> login({
//     required String email,
//     required String password,
//   }) async {
//     final deviceId = await _deviceService.getDeviceId();

//     final request = LoginRequest(
//       email: email,
//       password: password,
//       deviceId: deviceId,
//     );

//     final response = await _apiClient.post<Map<String, dynamic>>(
//       ApiEndpoints.login,
//       body: request.toJson(),
//       fromJson: (data) => data as Map<String, dynamic>,
//     );

//     if (response.isSuccess && response.data != null) {
//       final authResponse = AuthResponse.fromJson(response.data!);
//       await _saveAuthData(authResponse);
//       return authResponse;
//     }

//     throw Exception(response.errorMessage);
//   }

//   /// Request password reset OTP
//   Future<ForgetPasswordResponse> forgetPassword({
//     required String email,
//   }) async {
//     final request = ForgetPasswordRequest(email: email);

//     final response = await _apiClient.post<Map<String, dynamic>>(
//       ApiEndpoints.forgetPassword,
//       body: request.toJson(),
//       fromJson: (data) => data as Map<String, dynamic>,
//     );

//     if (response.isSuccess && response.data != null) {
//       return ForgetPasswordResponse.fromJson(response.data!);
//     }

//     throw Exception(response.errorMessage);
//   }

//   /// Reset password with OTP code
//   Future<void> resetPassword({
//     required String email,
//     required String code,
//     required String newPassword,
//   }) async {
//     final request = ResetPasswordRequest(
//       email: email,
//       code: code,
//       newPassword: newPassword,
//     );

//     final response = await _apiClient.post<void>(
//       ApiEndpoints.resetPassword,
//       body: request.toJson(),
//     );

//     if (!response.isSuccess) {
//       throw Exception(response.errorMessage);
//     }
//   }

//   // NOTE: refreshToken is now handled automatically by ApiClient via TokenService.
//   // We don't expose it manually here unless needed for specific UI actions.

//   /// Logout - revoke refresh token and clear local storage
//   Future<void> logout() async {
//     final token = await _tokenService.getAccessToken(); // Use TokenService
//     // We can't easily get refreshToken via TokenService public API if we hid it...
//     // But StorageService is still available if we really need it.
//     // However, clean architecture suggests `TokenService` should handle token operations.
//     // Let's use storage service for the revocation payload since TokenService is high-level.
//     final refreshToken = await _storageService.getRefreshToken();

//     if (token != null && refreshToken != null) {
//       final request = RevokeTokenRequest(
//         token: token,
//         refreshToken: refreshToken,
//       );

//       try {
//         await _apiClient.post<void>(
//           ApiEndpoints.revokeToken,
//           body: request.toJson(),
//         );
//       } catch (_) {
//         // Ignore errors, we'll clear local storage anyway
//       }
//     }

//     await _tokenService.clearTokens();

//     // CRITICAL: Clear ALL SharedPreferences (user data, cached data, etc.)
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
//   }

//   /// Check if user is logged in (has valid session)
//   Future<bool> isLoggedIn() async {
//     return await _tokenService.hasValidSession();
//   }

//   /// Get stored user data
//   Future<Map<String, dynamic>?> getStoredUserData() async {
//     return await _storageService.getUserData();
//   }

//   // ============ Private Helpers ============

//   Future<void> _saveAuthData(AuthResponse authResponse) async {
//     await _tokenService.saveTokens(
//       accessToken: authResponse.token,
//       refreshToken: authResponse.refreshToken,
//       expiresIn: authResponse.expiresIn,
//       refreshTokenExpiration: authResponse.refreshTokenExpiration,
//     );

//     await _storageService.saveUserData({
//       'id': authResponse.id,
//       'email': authResponse.email,
//       'name': authResponse.name,
//       'phoneNumber': authResponse.phoneNumber,
//     });
//   }
// }
