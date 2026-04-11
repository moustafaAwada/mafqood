import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mafqood/features/auth/domain/entities/auth_results.dart';
import 'package:mafqood/features/auth/domain/entities/user.dart';
import 'package:mafqood/features/auth/domain/repositories/auth_repository.dart';
import 'package:mafqood/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthState());

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
              clearError: true,
            ),
          );
          return;
        }
      }
      emit(
        state.copyWith(status: AuthStatus.unauthenticated, clearError: true),
      );
    } catch (e) {
      debugPrint('Auth init error: $e');
      emit(
        state.copyWith(status: AuthStatus.unauthenticated, clearError: true),
      );
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    _emitLoading();

    final result = await _authRepository.register(
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
    );

    return result.fold(
      (failure) {
        _emitError(failure.message);
        return false;
      },
      (registerResult) {
        _emitUnauthenticated(
          pendingUserId: registerResult.userId,
          clearPendingEmail: true,
        );
        return true;
      },
    );
  }

  Future<bool> resendConfirmationEmail({required String email}) async {
    _emitLoading();

    final result = await _authRepository.resendConfirmationEmail(email: email);

    return result.fold(
      (failure) {
        _emitError(failure.message);
        return false;
      },
      (userId) {
        _emitUnauthenticated(pendingUserId: userId, clearPendingEmail: true);
        return true;
      },
    );
  }

  Future<bool> confirmEmail({required String code}) async {
    if (state.pendingUserId == null) {
      _emitError('لا يوجد مستخدم في انتظار التأكيد');
      return false;
    }

    _emitLoading();

    final result = await _authRepository.confirmEmail(
      userId: state.pendingUserId!,
      code: code,
    );

    return result.fold(
      (failure) {
        _emitError(failure.message);
        return false;
      },
      (userResult) {
        _emitAuthenticated(userResult);
        return true;
      },
    );
  }

  Future<bool> login({required String email, required String password}) async {
    _emitLoading();

    final result = await _authRepository.login(
      email: email,
      password: password,
    );

    return result.fold(
      (failure) {
        _emitError(failure.message);
        return false;
      },
      (userResult) {
        _emitAuthenticated(userResult);
        return true;
      },
    );
  }

  Future<bool> forgetPassword({required String email}) async {
    _emitLoading();

    final result = await _authRepository.forgetPassword(email: email);

    return result.fold(
      (failure) {
        _emitError(failure.message);
        return false;
      },
      (forgetResult) {
        _emitUnauthenticated(
          pendingEmail: forgetResult.email,
          clearPendingUserId: true,
        );
        return true;
      },
    );
  }

  Future<bool> resetPassword({
    required String code,
    required String newPassword,
  }) async {
    if (state.pendingEmail == null) {
      _emitError('لا يوجد بريد إلكتروني في انتظار إعادة التعيين');
      return false;
    }

    _emitLoading();

    final result = await _authRepository.resetPassword(
      email: state.pendingEmail!,
      code: code,
      newPassword: newPassword,
    );

    return result.fold(
      (failure) {
        _emitError(failure.message);
        return false;
      },
      (_) {
        _emitUnauthenticated(clearPendingEmail: true, clearPendingUserId: true);
        return true;
      },
    );
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
      emit(state.copyWith(pendingUserId: userId, clearError: true));

  void setPendingEmail(String email) =>
      emit(state.copyWith(pendingEmail: email, clearError: true));

  void updateUser({String? name, String? phoneNumber}) {
    if (state.user.isEmpty) return;
    emit(
      state.copyWith(
        user: state.user.copyWith(name: name, phoneNumber: phoneNumber),
        clearError: true,
      ),
    );
  }

  void _emitLoading() =>
      emit(state.copyWith(status: AuthStatus.loading, clearError: true));

  void _emitError(String message) =>
      emit(state.copyWith(status: AuthStatus.error, error: message));

  void _emitAuthenticated(AuthUserResult userResult) {
    emit(
      state.copyWith(
        status: AuthStatus.authenticated,
        user: User(
          id: userResult.id,
          email: userResult.email,
          name: userResult.name,
          phoneNumber: userResult.phoneNumber,
        ),
        clearError: true,
        clearPendingEmail: true,
        clearPendingUserId: true,
      ),
    );
  }

  void _emitUnauthenticated({
    String? pendingUserId,
    String? pendingEmail,
    bool clearPendingUserId = false,
    bool clearPendingEmail = false,
  }) {
    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated,
        pendingUserId: pendingUserId,
        pendingEmail: pendingEmail,
        clearError: true,
        clearPendingUserId: clearPendingUserId,
        clearPendingEmail: clearPendingEmail,
      ),
    );
  }
}
