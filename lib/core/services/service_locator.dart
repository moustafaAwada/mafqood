import 'package:get_it/get_it.dart';
import 'package:mafqood/core/database/auth_storage.dart';
import 'package:mafqood/core/database/cache/cache_helper.dart';
import 'package:mafqood/features/chat/data/services/chat_hub_service.dart';
import 'package:mafqood/features/posts/data/services/post_interaction_hub_service.dart';

final getIt = GetIt.instance;
void setupServiceLocator() {
  getIt.registerSingleton<CacheHelper>(CacheHelper());
  getIt.registerSingleton<AuthStorage>(AuthStorage());
  getIt.registerLazySingleton<ChatHubService>(() => ChatHubService());
  getIt.registerLazySingleton<PostInteractionHubService>(
    () => PostInteractionHubService(),
  );
}

