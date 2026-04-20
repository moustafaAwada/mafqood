import 'package:mafqood/features/posts/domain/entities/post_entities.dart';

abstract class PostRemoteDataSource {
  Future<PaginatedResult<PostItem>> getPosts({
    int pageNumber = 1,
    int pageSize = 10,
    String? searchKey,
    PostType? type,
  });

  Future<ReactCounts> getReactCounts(int postId);

  Future<ReactCounts> toggleReact({
    required int postId,
    required ReactType reactType,
  });

  Future<void> savePost(int postId);
  Future<void> unSavePost(int postId);

  Future<void> createPost({
    required String description,
    required int type,
    double? latitude,
    double? longitude,
    String? locationName,
    String? imagePath,
  });
}
