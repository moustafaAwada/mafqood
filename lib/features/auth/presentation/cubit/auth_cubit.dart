import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mafqood/features/auth/domain/entities/user.dart';
import 'package:mafqood/features/auth/domain/repositories/auth_repository.dart';
import 'package:mafqood/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthState());

  void _handleSessionExpired() {
    emit(state.copyWith(user: User.empty, status: AuthStatus.unauthenticated));
  }

  Future<void> initialize() async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        final userData = await _authRepository.getStoredUserData();
        if (userData != null) {
          emit(
            state.copyWith(
              status: AuthStatus.authenticated,
              user: User.fromJson(userData),
            ),
          );
          return;
        }
      }
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    } catch (e) {
      debugPrint('Auth init error: $e');
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    try {
      final result = await _authRepository.register(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          pendingUserId: result.userId,
        ),
      );
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          error: _extractErrorMessage(e),
        ),
      );
      return false;
    }
  }

  Future<bool> resendConfirmationEmail({required String email}) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    try {
      final userId = await _authRepository.resendConfirmationEmail(
        email: email,
      );
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          pendingUserId: userId,
        ),
      );
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          error: _extractErrorMessage(e),
        ),
      );
      return false;
    }
  }

  Future<bool> confirmEmail({required String code}) async {
    if (state.pendingUserId == null) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          error: 'لا يوجد مستخدم في انتظار التأكيد',
        ),
      );
      return false;
    }

    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    try {
      final result = await _authRepository.confirmEmail(
        userId: state.pendingUserId!,
        code: code,
      );
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: User(
            id: result.id,
            email: result.email,
            name: result.name,
            phoneNumber: result.phoneNumber,
          ),
          clearPendingUserId: true,
        ),
      );
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          error: _extractErrorMessage(e),
        ),
      );
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    try {
      final result = await _authRepository.login(
        email: email,
        password: password,
      );
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: User(
            id: result.id,
            email: result.email,
            name: result.name,
            phoneNumber: result.phoneNumber,
          ),
        ),
      );
      return true;
    } catch (e) {
      final errorMsg = _extractErrorMessage(e);
      final displayError =
          errorMsg.contains(
            'The device you are trying to login from is not recognized',
          )
          ? 'عذراً، هذا الجهاز غير معروف. يرجى تسجيل الدخول من جهازك المسجل أو إخبار مسؤولين السنتر بالمشكلة'
          : errorMsg;
      emit(state.copyWith(status: AuthStatus.error, error: displayError));
      return false;
    }
  }

  Future<bool> forgetPassword({required String email}) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    try {
      final result = await _authRepository.forgetPassword(email: email);
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          pendingEmail: result.email,
        ),
      );
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          error: _extractErrorMessage(e),
        ),
      );
      return false;
    }
  }

  Future<bool> resetPassword({
    required String code,
    required String newPassword,
  }) async {
    if (state.pendingEmail == null) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          error: 'لا يوجد بريد إلكتروني في انتظار إعادة التعيين',
        ),
      );
      return false;
    }

    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    try {
      await _authRepository.resetPassword(
        email: state.pendingEmail!,
        code: code,
        newPassword: newPassword,
      );
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          clearPendingEmail: true,
        ),
      );
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          error: _extractErrorMessage(e),
        ),
      );
      return false;
    }
  }

  Future<void> logout() async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _authRepository.logout();
    } catch (_) {
    } finally {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  void clearError() => emit(state.copyWith(clearError: true));
  void setPendingUserId(String userId) =>
      emit(state.copyWith(pendingUserId: userId));
  void setPendingEmail(String email) =>
      emit(state.copyWith(pendingEmail: email));

  void updateUser({String? name, String? phoneNumber}) {
    if (state.user.isEmpty) return;
    emit(
      state.copyWith(
        user: User(
          id: state.user.id,
          email: state.user.email,
          name: name ?? state.user.name,
          phoneNumber: phoneNumber ?? state.user.phoneNumber,
        ),
      ),
    );
  }

  String _extractErrorMessage(Object e) {
    return e.toString();
  }
}
