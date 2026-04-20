import 'package:dartz/dartz.dart';
import 'package:mafqood/core/error/failures.dart';
import 'package:mafqood/features/posts/domain/entities/post_entities.dart';

abstract class PostRepository {
  Future<Either<Failure, PaginatedResult<PostItem>>> getPosts({
    int pageNumber = 1,
    int pageSize = 10,
    String? searchKey,
    PostType? type,
  });

  Future<Either<Failure, Unit>> createPost({
    required String description,
    required int type,
    double? latitude,
    double? longitude,
    String? locationName,
    String? imagePath,
  });

  Future<Either<Failure, ReactCounts>> toggleReact({
    required int postId,
    required ReactType reactType,
  });

  Future<Either<Failure, Unit>> savePost(int postId);
  Future<Either<Failure, Unit>> unSavePost(int postId);
}
