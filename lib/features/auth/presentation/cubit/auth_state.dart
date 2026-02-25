import 'package:equatable/equatable.dart';
import 'package:mafqood/features/auth/domain/entities/user.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final User user;
  final String? error;
  final String? pendingUserId;
  final String? pendingEmail;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user = User.empty,
    this.error,
    this.pendingUserId,
    this.pendingEmail,
  });

  bool get isLoading => status == AuthStatus.loading;
  bool get isLoggedIn => user.isNotEmpty;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
    String? pendingUserId,
    String? pendingEmail,
    bool clearError = false,
    bool clearPendingUserId = false,
    bool clearPendingEmail = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: clearError ? null : (error ?? this.error),
      pendingUserId: clearPendingUserId
          ? null
          : (pendingUserId ?? this.pendingUserId),
      pendingEmail: clearPendingEmail
          ? null
          : (pendingEmail ?? this.pendingEmail),
    );
  }

  @override
  List<Object?> get props => [status, user, error, pendingUserId, pendingEmail];
}
