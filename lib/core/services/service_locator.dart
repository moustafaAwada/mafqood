import 'package:get_it/get_it.dart';
import 'package:mafqood/core/database/auth_storage.dart';
import 'package:mafqood/core/database/cache/cache_helper.dart';

final getIt = GetIt.instance;
void setupServiceLocator() {
  getIt.registerSingleton<CacheHelper>(CacheHelper());
  getIt.registerSingleton<AuthStorage>(AuthStorage());
}
