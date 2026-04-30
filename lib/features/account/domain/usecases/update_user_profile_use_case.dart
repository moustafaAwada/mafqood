import 'dart:io';
import 'package:dartz/dartz.dart';

import 'package:mafqood/core/error/failures.dart';
import 'package:mafqood/features/account/domain/repositories/account_repository.dart';
import 'package:mafqood/features/posts/domain/entities/post_entities.dart';

class UpdateProfileParams {
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final File? profileImage;

  UpdateProfileParams({
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.profileImage,
  });

  String get name {
    final parts = <String>[];
    if (firstName != null && firstName!.trim().isNotEmpty) {
      parts.add(firstName!.trim());
    }
    if (lastName != null && lastName!.trim().isNotEmpty) {
      parts.add(lastName!.trim());
    }
    return parts.join(' ');
  }
}

class UpdateUserProfileUseCase {
  final AccountRepository repository;

  UpdateUserProfileUseCase(this.repository);

  Future<Either<Failure, UserProfileEntity>> call(UpdateProfileParams params) {
    return repository.updateUserProfile(params);
  }
}
