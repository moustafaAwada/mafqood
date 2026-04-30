import 'package:dartz/dartz.dart';
import 'package:mafqood/core/error/failures.dart';
import 'package:mafqood/features/account/domain/usecases/update_user_profile_use_case.dart';
import 'package:mafqood/features/posts/domain/entities/post_entities.dart';

abstract class AccountRepository {
  Future<Either<Failure, Unit>> updateLocation({
    required double latitude,
    required double longitude,
  });

  Future<Either<Failure, UserProfileEntity>> updateUserProfile(UpdateProfileParams params);

  /// Fetch current user profile from API and cache locally
  Future<Either<Failure, UserProfileEntity>> getCurrentUserProfile();
}
