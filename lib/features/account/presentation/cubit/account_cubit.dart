import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mafqood/features/account/domain/repositories/account_repository.dart';
import 'package:mafqood/features/account/presentation/cubit/account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  final AccountRepository _accountRepository;

  AccountCubit({required AccountRepository accountRepository})
      : _accountRepository = accountRepository,
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
}
