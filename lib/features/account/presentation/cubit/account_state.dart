import 'package:equatable/equatable.dart';

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
