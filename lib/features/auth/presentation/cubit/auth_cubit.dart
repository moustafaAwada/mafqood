import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mafqood/features/auth/domain/entities/user.dart';
import 'package:mafqood/features/auth/domain/repositories/auth_repository.dart';
import 'package:mafqood/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthInitial());

  Future<void> initialize() async {
    emit(AuthLoading());

    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        final userData = await _authRepository.getStoredUserData();
        if (userData != null) {
          emit(AuthAuthenticated(User.fromJson(userData)));
          return;
        }
      }
      emit(const AuthUnauthenticated());
    } catch (e) {
      debugPrint('Auth init error: $e');
      emit(const AuthUnauthenticated());
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    emit(const RegisterLoading());

    final result = await _authRepository.register(
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
    );

    return result.fold(
      (failure) {
        emit(RegisterFailure(failure.message));
        return false;
      },
      (registerResult) {
        emit(RegisterSuccess(pendingUserId: registerResult.userId));
        return true;
      },
    );
  }

  Future<bool> resendConfirmationEmail({required String email}) async {
    emit(const ResendConfirmationLoading());

    final result = await _authRepository.resendConfirmationEmail(email: email);

    return result.fold(
      (failure) {
        emit(ResendConfirmationFailure(failure.message));
        return false;
      },
      (userId) {
        emit(ResendConfirmationSuccess(pendingUserId: userId));
        return true;
      },
    );
  }

  Future<bool> confirmEmail({required String code}) async {
    if (state.pendingUserId == null) {
      emit(const ConfirmEmailFailure('لا يوجد مستخدم في انتظار التأكيد'));
      return false;
    }

    emit(const ConfirmEmailLoading());

    final result = await _authRepository.confirmEmail(
      userId: state.pendingUserId!,
      code: code,
    );

    return result.fold(
      (failure) {
        emit(ConfirmEmailFailure(failure.message));
        return false;
      },
      (userResult) {
        emit(
          ConfirmEmailSuccess(
            User(
              id: userResult.id,
              email: userResult.email,
              name: userResult.name,
              phoneNumber: userResult.phoneNumber,
            ),
          ),
        );
        return true;
      },
    );
  }

  Future<bool> login({required String email, required String password}) async {
    emit(const SignInLoading());

    final result = await _authRepository.login(
      email: email,
      password: password,
    );

    return result.fold(
      (failure) {
        emit(SignInFailure(failure.message));
        return false;
      },
      (userResult) {
        emit(
          SignInSuccess(
            User(
              id: userResult.id,
              email: userResult.email,
              name: userResult.name,
              phoneNumber: userResult.phoneNumber,
            ),
          ),
        );
        return true;
      },
    );
  }

  Future<bool> forgetPassword({required String email}) async {
    emit(const ForgetPasswordLoading());

    final result = await _authRepository.forgetPassword(email: email);

    return result.fold(
      (failure) {
        emit(ForgetPasswordFailure(failure.message));
        return false;
      },
      (forgetResult) {
        emit(ForgetPasswordSuccess(pendingEmail: forgetResult.email));
        return true;
      },
    );
  }

  Future<bool> resetPassword({
    required String code,
    required String newPassword,
  }) async {
    if (state.pendingEmail == null) {
      emit(
        const ResetPasswordFailure(
          'لا يوجد بريد إلكتروني في انتظار إعادة التعيين',
        ),
      );
      return false;
    }

    emit(const ResetPasswordLoading());

    final result = await _authRepository.resetPassword(
      email: state.pendingEmail!,
      code: code,
      newPassword: newPassword,
    );

    return result.fold(
      (failure) {
        emit(ResetPasswordFailure(failure.message));
        return false;
      },
      (_) {
        emit(const ResetPasswordSuccess());
        return true;
      },
    );
  }

  Future<void> logout() async {
    emit(
      LogoutLoading(
        user: state.user,
        pendingUserId: state.pendingUserId,
        pendingEmail: state.pendingEmail,
      ),
    );
    try {
      await _authRepository.logout();
      emit(const LogoutSuccess());
    } catch (e) {
      emit(LogoutFailure(e.toString()));
    }
  }
}
