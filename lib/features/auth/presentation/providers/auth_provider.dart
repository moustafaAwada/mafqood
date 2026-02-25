// import 'package:flutter/material.dart';

// class AuthProvider extends ChangeNotifier {
//   final AuthService _authService;

//   User _user = User.empty;
//   bool _isLoading = false;
//   String? _error;
//   String? _pendingUserId;
//   String? _pendingEmail;

//   AuthProvider({AuthService? authService})
//     : _authService = authService ?? AuthService() {
//     TokenService().onSessionExpired = _handleSessionExpired;
//   }

//   void _handleSessionExpired() {
//     _user = User.empty;
//     notifyListeners();
//   }

//   // ============ Getters ============

//   User get user => _user;
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//   bool get isLoggedIn => _user.isNotEmpty;
//   String? get pendingUserId => _pendingUserId;
//   String? get pendingEmail => _pendingEmail;

//   // ============ Auth Actions ============

//   /// Initialize auth state from stored data
//   Future<void> initialize() async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       final isLoggedIn = await _authService.isLoggedIn();
//       if (isLoggedIn) {
//         final userData = await _authService.getStoredUserData();
//         if (userData != null) {
//           _user = User.fromJson(userData);
//         }
//       }
//     } catch (e) {
//       debugPrint('Auth init error: $e');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<bool> register({
//     required String name,
//     required String email,
//     required String phoneNumber,
//     required String password,
//   }) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       final response = await _authService.register(
//         name: name,
//         email: email,
//         phoneNumber: phoneNumber,
//         password: password,
//       );

//       _pendingUserId = response.userId;
//       _isLoading = false;
//       notifyListeners();
//       return true;
//     } on ValidationException catch (e) {
//       _error = e.message;
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     } on ApiException catch (e) {
//       _error = e.message;
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     } catch (e) {
//       _error = e.toString();
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }

//   /// Resend confirmation code
//   /// On success, sets pendingUserId
//   Future<bool> resendConfirmationEmail({required String email}) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       final userId = await _authService.resendConfirmationEmail(email: email);
//       _pendingUserId = userId;
//       _isLoading = false;
//       notifyListeners();
//       return true;
//     } on ApiException catch (e) {
//       _error = e.message;
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     } catch (e) {
//       _error = e.toString();
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }

//   /// Confirm email with OTP code
//   /// On success, user is logged in
//   Future<bool> confirmEmail({required String code}) async {
//     if (_pendingUserId == null) {
//       _error = 'لا يوجد مستخدم في انتظار التأكيد';
//       return false;
//     }

//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       final response = await _authService.confirmEmail(
//         userId: _pendingUserId!,
//         code: code,
//       );

//       _user = User(
//         id: response.id,
//         email: response.email,
//         name: response.name,
//         phoneNumber: response.phoneNumber,
//       );
//       _pendingUserId = null;
//       _isLoading = false;
//       notifyListeners();
//       return true;
//     } on ApiException catch (e) {
//       _error = e.message;
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     } catch (e) {
//       _error = e.toString();
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }

//   /// Login with email and password
//   Future<bool> login({required String email, required String password}) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       final response = await _authService.login(
//         email: email,
//         password: password,
//       );

//       _user = User(
//         id: response.id,
//         email: response.email,
//         name: response.name,
//         phoneNumber: response.phoneNumber,
//       );
//       _isLoading = false;
//       notifyListeners();
//       return true;
//     } on ValidationException catch (e) {
//       _error = e.message;
//       _isLoading = false;
//       notifyListeners();
//       return false;
//       return false;
//     } on ApiException catch (e) {
//       if (e.message.contains(
//         'The device you are trying to login from is not recognized',
//       )) {
//         _error =
//             'عذراً، هذا الجهاز غير معروف. يرجى تسجيل الدخول من جهازك المسجل أو إخبار مسؤولين السنتر بالمشكلة';
//       } else {
//         _error = e.message;
//       }
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     } catch (e) {
//       _error = e.toString();
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }

//   /// Request password reset OTP
//   /// On success, sets pendingEmail for reset flow
//   Future<bool> forgetPassword({required String email}) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       final response = await _authService.forgetPassword(email: email);
//       _pendingEmail = response.email;
//       _isLoading = false;
//       notifyListeners();
//       return true;
//     } on ApiException catch (e) {
//       _error = e.message;
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     } catch (e) {
//       _error = e.toString();
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }

//   /// Reset password with OTP code
//   Future<bool> resetPassword({
//     required String code,
//     required String newPassword,
//   }) async {
//     if (_pendingEmail == null) {
//       _error = 'لا يوجد بريد إلكتروني في انتظار إعادة التعيين';
//       return false;
//     }

//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       await _authService.resetPassword(
//         email: _pendingEmail!,
//         code: code,
//         newPassword: newPassword,
//       );

//       _pendingEmail = null;
//       _isLoading = false;
//       notifyListeners();
//       return true;
//     } on ApiException catch (e) {
//       _error = e.message;
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     } catch (e) {
//       _error = e.toString();
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }

//   /// Logout and clear all data
//   Future<void> logout() async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       await _authService.logout();
//     } catch (_) {
//       // Ignore errors during logout
//     } finally {
//       _user = User.empty;
//       _error = null;
//       _pendingUserId = null;
//       _pendingEmail = null;
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   /// Clear error
//   void clearError() {
//     _error = null;
//     notifyListeners();
//   }

//   /// Set pending userId (for navigation from signup)
//   void setPendingUserId(String userId) {
//     _pendingUserId = userId;
//   }

//   /// Set pending email (for navigation from forgot password)
//   void setPendingEmail(String email) {
//     _pendingEmail = email;
//   }

//   /// Update local user data (called after profile update)
//   void updateUser({String? name, String? phoneNumber}) {
//     if (_user.isEmpty) return;

//     _user = User(
//       id: _user.id,
//       email: _user.email,
//       name: name ?? _user.name,
//       phoneNumber: phoneNumber ?? _user.phoneNumber,
//     );
//     notifyListeners();
//   }
// }
