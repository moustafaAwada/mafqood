import 'package:equatable/equatable.dart';
import 'package:mafqood/features/auth/domain/entities/user.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

abstract class AuthState extends Equatable {
  final User user;
  final String? error;
  final String? pendingUserId;
  final String? pendingEmail;

  const AuthState({
    this.user = User.empty,
    this.error,
    this.pendingUserId,
    this.pendingEmail,
  });

  bool get isLoading => false;
  bool get isLoggedIn => user.isNotEmpty;
  AuthStatus get status => AuthStatus.initial;

  @override
  List<Object?> get props => [user, error, pendingUserId, pendingEmail];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading({super.user, super.pendingUserId, super.pendingEmail});

  @override
  bool get isLoading => true;

  @override
  AuthStatus get status => AuthStatus.loading;
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(User user) : super(user: user);

  @override
  AuthStatus get status => AuthStatus.authenticated;
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({
    super.user,
    super.pendingUserId,
    super.pendingEmail,
  });

  @override
  AuthStatus get status => AuthStatus.unauthenticated;
}

class AuthFailure extends AuthState {
  const AuthFailure(
    String error, {
    super.user,
    super.pendingUserId,
    super.pendingEmail,
  }) : super(error: error);

  @override
  AuthStatus get status => AuthStatus.error;
}

class SignInLoading extends AuthLoading {
  const SignInLoading({super.user, super.pendingUserId, super.pendingEmail});
}

class SignInSuccess extends AuthAuthenticated {
  const SignInSuccess(super.user);
}

class SignInFailure extends AuthFailure {
  const SignInFailure(super.error);
}

class RegisterLoading extends AuthLoading {
  const RegisterLoading({super.user, super.pendingUserId, super.pendingEmail});
}

class RegisterSuccess extends AuthUnauthenticated {
  const RegisterSuccess({super.pendingUserId});
}

class RegisterFailure extends AuthFailure {
  const RegisterFailure(super.error);
}

class ResendConfirmationLoading extends AuthLoading {
  const ResendConfirmationLoading({
    super.user,
    super.pendingUserId,
    super.pendingEmail,
  });
}

class ResendConfirmationSuccess extends AuthUnauthenticated {
  const ResendConfirmationSuccess({super.pendingUserId});
}

class ResendConfirmationFailure extends AuthFailure {
  const ResendConfirmationFailure(super.error);
}

class ConfirmEmailLoading extends AuthLoading {
  const ConfirmEmailLoading({
    super.user,
    super.pendingUserId,
    super.pendingEmail,
  });
}

class ConfirmEmailSuccess extends AuthAuthenticated {
  const ConfirmEmailSuccess(super.user);
}

class ConfirmEmailFailure extends AuthFailure {
  const ConfirmEmailFailure(super.error);
}

class ForgetPasswordLoading extends AuthLoading {
  const ForgetPasswordLoading({
    super.user,
    super.pendingUserId,
    super.pendingEmail,
  });
}

class ForgetPasswordSuccess extends AuthUnauthenticated {
  const ForgetPasswordSuccess({super.pendingEmail});
}

class ForgetPasswordFailure extends AuthFailure {
  const ForgetPasswordFailure(super.error);
}

class ResetPasswordLoading extends AuthLoading {
  const ResetPasswordLoading({
    super.user,
    super.pendingUserId,
    super.pendingEmail,
  });
}

class ResetPasswordSuccess extends AuthUnauthenticated {
  const ResetPasswordSuccess() : super();
}

class ResetPasswordFailure extends AuthFailure {
  const ResetPasswordFailure(super.error);
}

class LogoutLoading extends AuthLoading {
  const LogoutLoading({super.user, super.pendingUserId, super.pendingEmail});
}

class LogoutSuccess extends AuthUnauthenticated {
  const LogoutSuccess() : super();
}

class LogoutFailure extends AuthFailure {
  const LogoutFailure(super.error);
}
