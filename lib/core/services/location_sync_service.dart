import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mafqood/core/api/auth_interceptor.dart';
import 'package:mafqood/core/api/dio_consumer.dart';
import 'package:mafqood/core/database/auth_storage.dart';
import 'package:mafqood/features/account/data/datasources/account_remote_data_source_impl.dart';
import 'package:mafqood/features/account/data/repositories/account_repository_impl.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == LocationSyncService.syncLocationTaskName) {
      try {
        final authStorage = AuthStorage();
        final isLoggedIn = await authStorage.hasValidSession();
        if (!isLoggedIn) {
          return true;
        }

        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          return true;
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return true;
        }

        final position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(accuracy: LocationAccuracy.low));

        final dio = Dio();
        final apiConsumer = DioConsumer(
          dio: dio,
          interceptors: [AuthInterceptor(dio: dio, authStorage: authStorage)],
        );

        final remote = AccountRemoteDataSourceImpl(api: apiConsumer);
        final repository = AccountRepositoryImpl(remote: remote);

        final result = await repository.updateLocation(
          latitude: position.latitude,
          longitude: position.longitude,
        );

        return result.fold((l) => false, (r) => true);
      } catch (e) {
        return false;
      }
    }
    return true;
  });
}

class LocationSyncService {
  static const String syncLocationTaskName = 'sync_location_task';

  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  static void startLocationSync() {
    Workmanager().registerPeriodicTask(
      "location_sync_12h",
      syncLocationTaskName,
      frequency: const Duration(hours: 12),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }

  static void stopLocationSync() {
    Workmanager().cancelByUniqueName("location_sync_12h");
  }
}
