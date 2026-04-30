import 'package:dartz/dartz.dart';
import 'package:mafqood/core/api/end_points.dart';
import 'package:mafqood/core/api/result_envelope.dart';
import 'package:mafqood/core/error/exceptions.dart';
import 'package:mafqood/core/error/failures.dart';
import 'package:mafqood/core/error/error_model.dart';
import 'package:mafqood/core/database/auth_storage.dart';
import 'package:mafqood/features/account/data/datasources/account_remote_data_source.dart';
import 'package:mafqood/features/account/domain/repositories/account_repository.dart';
import 'package:mafqood/features/account/domain/usecases/update_user_profile_use_case.dart';
import 'package:mafqood/features/posts/domain/entities/post_entities.dart';
import 'package:mafqood/features/posts/data/models/user_profile_model.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource _remote;
  final AuthStorage _authStorage;

  AccountRepositoryImpl({
    required AccountRemoteDataSource remote,
    required AuthStorage authStorage,
  })  : _remote = remote,
        _authStorage = authStorage;

  @override
  Future<Either<Failure, Unit>> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _remote.updateLocation(latitude: latitude, longitude: longitude);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserProfileEntity>> updateUserProfile(UpdateProfileParams params) async {
    try {
      // Start from stored user data (source-of-truth for UI, since update endpoints
      // don't necessarily return a full profile object).
      final stored = await _authStorage.getUserData() ?? <String, dynamic>{};
      final merged = Map<String, dynamic>.from(stored);

      // 1) Update profile picture (returns data.profilePictureUrl)
      if (params.profileImage != null) {
        final raw = await _remote.updateProfilePicture(params.profileImage!);
        final envelope = ResultEnvelope.tryParse(raw);
        if (envelope == null) {
          throw ServerException(
            errorModel: ErrorModel(
              status: -1,
              errorMessage: 'استجابة غير صالحة من السيرفر',
            ),
          );
        }
        if (!envelope.isSuccess) {
          throw ServerException(errorModel: envelope.error ?? ErrorModel(status: envelope.statusCode ?? -1, errorMessage: 'حدث خطأ غير معروف'));
        }

        final dataMap = envelope.dataAsMapOrNull();
        var url = dataMap?['profilePictureUrl'] as String?;
        if (url != null && url.isNotEmpty) {
          // Ensure full URL (backend may return relative path)
          if (!url.startsWith('http')) {
            url = '${EndPoints.baseUrl}${url.startsWith('/') ? url.substring(1) : url}';
          }
          merged['profilePictureUrl'] = url;
        }
      }

      // 2) Update name + phone (success hasData=false per spec)
      final shouldUpdateInfo =
          params.name.trim().isNotEmpty ||
          (params.phoneNumber != null && params.phoneNumber!.trim().isNotEmpty);

      if (shouldUpdateInfo) {
        final raw = await _remote.updateUserInfo(
          name: params.name.trim(),
          phoneNumber: (params.phoneNumber ?? '').trim(),
        );
        final envelope = ResultEnvelope.tryParse(raw);
        if (envelope == null) {
          throw ServerException(
            errorModel: ErrorModel(
              status: -1,
              errorMessage: 'استجابة غير صالحة من السيرفر',
            ),
          );
        }
        if (!envelope.isSuccess) {
          throw ServerException(errorModel: envelope.error ?? ErrorModel(status: envelope.statusCode ?? -1, errorMessage: 'حدث خطأ غير معروف'));
        }

        // Persist locally (backend returns no data for this endpoint).
        if (params.name.trim().isNotEmpty) {
          merged['name'] = params.name.trim();
          if (params.firstName != null) merged['firstName'] = params.firstName!.trim();
          if (params.lastName != null) merged['lastName'] = params.lastName!.trim();
        }
        if (params.phoneNumber != null && params.phoneNumber!.trim().isNotEmpty) {
          merged['phoneNumber'] = params.phoneNumber!.trim();
        }
      }

      // Persist merged user data so UI (EditProfilePage/ProfileCard) reflects updates immediately.
      await _authStorage.saveUserData(merged);

      // Build entity for UI state emission.
      final userProfileModel = UserProfileModel.fromJson({
        'id': (merged['id'] ?? '') as String,
        'email': (merged['email'] ?? '') as String,
        'name': (merged['name'] ?? params.name).toString(),
        'phoneNumber': merged['phoneNumber'] as String?,
        'profilePictureUrl': merged['profilePictureUrl'] as String?,
        'isFollowedByCurrentUser': merged['isFollowedByCurrentUser'] as bool? ?? false,
      });

      return Right(
        UserProfileEntity(
          id: userProfileModel.id,
          email: userProfileModel.email,
          name: userProfileModel.name,
          phoneNumber: userProfileModel.phoneNumber,
          profilePictureUrl: userProfileModel.profilePictureUrl,
          isFollowedByCurrentUser: userProfileModel.isFollowedByCurrentUser,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserProfileEntity>> getCurrentUserProfile() async {
    try {
      final raw = await _remote.getCurrentUserProfile();
      final envelope = ResultEnvelope.tryParse(raw);
      if (envelope == null) {
        throw ServerException(
          errorModel: ErrorModel(
            status: -1,
            errorMessage: 'استجابة غير صالحة من السيرفر',
          ),
        );
      }
      if (!envelope.isSuccess) {
        throw ServerException(errorModel: envelope.error ?? ErrorModel(status: envelope.statusCode ?? -1, errorMessage: 'حدث خطأ غير معروف'));
      }

      final dataMap = envelope.dataAsMapOrNull();
      if (dataMap == null) {
        throw ServerException(
          errorModel: ErrorModel(
            status: -1,
            errorMessage: 'لا توجد بيانات مستخدم',
          ),
        );
      }

      final profile = UserProfileModel.fromJson(dataMap);
      
      // Ensure full URL for profile picture (backend may return relative path)
      var profilePictureUrl = profile.profilePictureUrl;
      if (profilePictureUrl != null && profilePictureUrl.isNotEmpty && !profilePictureUrl.startsWith('http')) {
        profilePictureUrl = '${EndPoints.baseUrl}${profilePictureUrl.startsWith('/') ? profilePictureUrl.substring(1) : profilePictureUrl}';
      }
      
      // Cache user data for UI
      await _authStorage.saveUserData({
        'id': profile.id,
        'email': profile.email,
        'name': profile.name,
        'phoneNumber': profile.phoneNumber,
        'profilePictureUrl': profilePictureUrl,
        'isFollowedByCurrentUser': profile.isFollowedByCurrentUser,
      });

      return Right(
        UserProfileEntity(
          id: profile.id,
          email: profile.email,
          name: profile.name,
          phoneNumber: profile.phoneNumber,
          profilePictureUrl: profilePictureUrl,
          isFollowedByCurrentUser: profile.isFollowedByCurrentUser,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
