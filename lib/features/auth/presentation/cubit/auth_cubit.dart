import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mafqood/features/auth/domain/entities/user.dart';
import 'package:mafqood/features/auth/domain/repositories/auth_repository.dart';
import 'package:mafqood/features/auth/presentation/cubit/auth_state.dart';


class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState()) {

  }

  void _handleSessionExpired() {
    emit(state.copyWith(
      user: User.empty,
      status: AuthStatus.unauthenticated,
    ));
  }


  Future<void> initialize() async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        final userData = await _authRepository.getStoredUserData();
        if (userData != null) {
          emit(state.copyWith(
            status: AuthStatus.authenticated,
            user: User.fromJson(userData),
          ));
          return;
        }
      }
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    } catch (e) {
      debugPrint('Auth init error: $e');
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  /// Register a new user
  /// On success, sets pendingUserId for email confirmation
  Future<bool> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    try {
      final response = await _authRepository.register(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );

      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        pendingUserId: response.userId,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: _extractErrorMessage(e),
      ));
      return false;
    }
  }

  /// Resend confirmation code
  /// On success, sets pendingUserId
  Future<bool> resendConfirmationEmail({required String email}) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    try {
      final userId = await _authRepository.resendConfirmationEmail(email: email);
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        pendingUserId: userId,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: _extractErrorMessage(e),
      ));
      return false;
    }
  }

  /// Confirm email with OTP code
  /// On success, user is logged in
  Future<bool> confirmEmail({required String code}) async {
    if (state.pendingUserId == null) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: 'لا يوجد مستخدم في انتظار التأكيد',
      ));
      return false;
    }

    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    try {
      final response = await _authRepository.confirmEmail(
        userId: state.pendingUserId!,
        code: code,
      );

      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: User(
          id: response.id,
          email: response.email,
          name: response.name,
          phoneNumber: response.phoneNumber,
        ),
        clearPendingUserId: true,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: _extractErrorMessage(e),
      ));
      return false;
    }
  }

  /// Login with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    try {
      final response = await _authRepository.login(
        email: email,
        password: password,
      );

      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: User(
          id: response.id,
          email: response.email,
          name: response.name,
          phoneNumber: response.phoneNumber,
        ),
      ));
      return true;
    } catch (e) {
      final errorMsg = _extractErrorMessage(e);
      // Preserve the device-not-recognized Arabic message
      final displayError = errorMsg.contains(
              'The device you are trying to login from is not recognized')
          ? 'عذراً، هذا الجهاز غير معروف. يرجى تسجيل الدخول من جهازك المسجل أو إخبار مسؤولين السنتر بالمشكلة'
          : errorMsg;

      emit(state.copyWith(
        status: AuthStatus.error,
        error: displayError,
      ));
      return false;
    }
  }

  /// Request password reset OTP
  /// On success, sets pendingEmail for reset flow
  Future<bool> forgetPassword({required String email}) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    try {
      final response = await _authRepository.forgetPassword(email: email);
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        pendingEmail: response.email,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: _extractErrorMessage(e),
      ));
      return false;
    }
  }

  /// Reset password with OTP code
  Future<bool> resetPassword({
    required String code,
    required String newPassword,
  }) async {
    if (state.pendingEmail == null) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: 'لا يوجد بريد إلكتروني في انتظار إعادة التعيين',
      ));
      return false;
    }

    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    try {
      await _authRepository.resetPassword(
        email: state.pendingEmail!,
        code: code,
        newPassword: newPassword,
      );

      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        clearPendingEmail: true,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: _extractErrorMessage(e),
      ));
      return false;
    }
  }

  /// Logout and clear all data
  Future<void> logout() async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      await _authRepository.logout();
    } catch (_) {
      // Ignore errors during logout
    } finally {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  /// Clear error
  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  /// Set pending userId (for navigation from signup)
  void setPendingUserId(String userId) {
    emit(state.copyWith(pendingUserId: userId));
  }

  /// Set pending email (for navigation from forgot password)
  void setPendingEmail(String email) {
    emit(state.copyWith(pendingEmail: email));
  }

  /// Update local user data (called after profile update)
  void updateUser({String? name, String? phoneNumber}) {
    if (state.user.isEmpty) return;

    emit(state.copyWith(
      user: User(
        id: state.user.id,
        email: state.user.email,
        name: name ?? state.user.name,
        phoneNumber: phoneNumber ?? state.user.phoneNumber,
      ),
    ));
  }

  // ============ Private Helpers ============

  String _extractErrorMessage(Object e) {
    // TODO: When your ApiException / ValidationException are available,
    // add specific catch blocks here or handle in the calling methods.
    return e.toString();
  }
}
