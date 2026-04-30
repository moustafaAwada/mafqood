import 'package:equatable/equatable.dart';
import 'package:mafqood/features/posts/domain/entities/post_entities.dart';

abstract class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object?> get props => [];
}

class AccountInitial extends AccountState {}

class UpdateLocationLoading extends AccountState {}

class UpdateLocationSuccess extends AccountState {}

class UpdateLocationFailure extends AccountState {
  final String error;

  const UpdateLocationFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class UpdateProfileLoading extends AccountState {}

class UpdateProfileSuccess extends AccountState {
  final UserProfileEntity profile;

  const UpdateProfileSuccess(this.profile);

  @override
  List<Object?> get props => [profile];
}

class UpdateProfileFailure extends AccountState {
  final String error;

  const UpdateProfileFailure(this.error);

  @override
  List<Object?> get props => [error];
}

// States for fetching current user profile
class AccountLoading extends AccountState {}

class AccountLoaded extends AccountState {
  final UserProfileEntity profile;

  const AccountLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class AccountError extends AccountState {
  final String message;

  const AccountError(this.message);

  @override
  List<Object?> get props => [message];
}
