import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mafqood/features/account/domain/repositories/account_repository.dart';
import 'package:mafqood/features/account/domain/usecases/update_user_profile_use_case.dart';
import 'package:mafqood/features/account/presentation/cubit/account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  final AccountRepository _accountRepository;
  final UpdateUserProfileUseCase _updateUserProfileUseCase;

  AccountCubit({
    required AccountRepository accountRepository,
    required UpdateUserProfileUseCase updateUserProfileUseCase,
  })  : _accountRepository = accountRepository,
        _updateUserProfileUseCase = updateUserProfileUseCase,
        super(AccountInitial());

  Future<bool> updateLocation() async {
    emit(UpdateLocationLoading());

    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(const UpdateLocationFailure('تم تعطيل خدمات الموقع.'));
        return false;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(const UpdateLocationFailure('تم رفض أذونات الموقع.'));
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(const UpdateLocationFailure('تم رفض أذونات الموقع نهائيًا. برجاء تفعيلها من الإعدادات.'));
        return false;
      }

      final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium));

      final result = await _accountRepository.updateLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      return result.fold(
        (failure) {
          emit(UpdateLocationFailure(failure.message));
          return false;
        },
        (_) {
          emit(UpdateLocationSuccess());
          return true;
        },
      );
    } catch (e) {
      emit(UpdateLocationFailure(e.toString()));
      return false;
    }
  }
  Future<void> updateProfile(UpdateProfileParams params) async {
    final validationError = _validateUpdateProfileParams(params);
    if (validationError != null) {
      emit(UpdateProfileFailure(validationError));
      return;
    }

    emit(UpdateProfileLoading());

    final result = await _updateUserProfileUseCase(params);

    result.fold(
      (failure) => emit(UpdateProfileFailure(failure.message)),
      (profile) => emit(UpdateProfileSuccess(profile)),
    );
  }

  Future<void> fetchCurrentUserProfile() async {
    emit(AccountLoading());
    final result = await _accountRepository.getCurrentUserProfile();
    result.fold(
      (failure) => emit(AccountError(failure.message)),
      (profile) => emit(AccountLoaded(profile)),
    );
  }

  String? _validateUpdateProfileParams(UpdateProfileParams params) {
    final name = params.name.trim();
    final phone = params.phoneNumber?.trim() ?? '';

    // Name is required by backend when calling /me/info, but user might be only
    // updating photo. So validate name length only if provided.
    if (name.isNotEmpty && (name.length < 3 || name.length > 100)) {
      return 'الاسم يجب أن يكون بين 3 و 100 حرف';
    }

    // Phone is required by backend when calling /me/info, but user might be only
    // updating photo. So validate phone only if provided.
    if (phone.isNotEmpty) {
      final phoneRegex = RegExp(r'^(010|011|012|015)\d{8}$');
      if (!phoneRegex.hasMatch(phone)) {
        return 'رقم الهاتف غير صحيح. يجب أن يكون 11 رقم ويبدأ بـ 010 أو 011 أو 012 أو 015';
      }
    }

    if (params.profileImage != null) {
      final file = params.profileImage!;
      final lower = file.path.toLowerCase();
      final allowed = ['.jpg', '.jpeg', '.png', '.gif'];
      final okExt = allowed.any(lower.endsWith);
      if (!okExt) {
        return 'يجب اختيار صورة بصيغة jpg أو jpeg أو png أو gif';
      }
      if (!file.existsSync()) {
        return 'ملف الصورة غير موجود';
      }
      final maxBytes = 5 * 1024 * 1024;
      final size = file.lengthSync();
      if (size > maxBytes) {
        return 'حجم الصورة يجب ألا يتجاوز 5 ميجا';
      }
    }

    // If user is trying to update info, enforce required fields (name + phone).
    final isUpdatingInfo = name.isNotEmpty || phone.isNotEmpty;
    if (isUpdatingInfo) {
      if (name.isEmpty) return 'الاسم مطلوب';
      if (phone.isEmpty) return 'رقم الهاتف مطلوب';
    }

    // If nothing is being updated, block to avoid meaningless request.
    final isUpdatingPhoto = params.profileImage != null;
    if (!isUpdatingInfo && !isUpdatingPhoto) {
      return 'لا توجد تغييرات لحفظها';
    }

    return null;
  }
}
