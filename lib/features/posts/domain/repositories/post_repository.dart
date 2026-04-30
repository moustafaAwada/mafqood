import 'package:dartz/dartz.dart';
import 'package:mafqood/core/error/failures.dart';
import 'package:mafqood/features/posts/domain/entities/post_entities.dart';

abstract class PostRepository {
  // ─── Post Management ──────────────────────────────────────────────────

  Future<Either<Failure, PaginatedResult<PostItem>>> getPosts({
    int pageNumber = 1,
    int pageSize = 10,
    String? searchKey,
    PostType? type,
  });

  Future<Either<Failure, PostItem>> getPostById(int postId);

  Future<Either<Failure, Unit>> createPost({
    required String description,
    required int type,
    required double latitude,
    required double longitude,
    String? imagePath,
  });

  Future<Either<Failure, Unit>> updatePost({
    required int postId,
    int? type,
    String? description,
    double? latitude,
    double? longitude,
    String? imagePath,
  });

  Future<Either<Failure, Unit>> deletePost(int postId);

  // ─── Comments ─────────────────────────────────────────────────────────

  Future<Either<Failure, PaginatedResult<CommentEntity>>> getComments({
    required int postId,
    int pageNumber = 1,
    int pageSize = 10,
  });

  Future<Either<Failure, CommentEntity>> addComment({
    required int postId,
    required String text,
  });

  Future<Either<Failure, CommentEntity>> updateComment({
    required int postId,
    required int commentId,
    required String text,
  });

  Future<Either<Failure, Unit>> deleteComment({
    required int postId,
    required int commentId,
  });

  // ─── Replies ──────────────────────────────────────────────────────────

  Future<Either<Failure, PaginatedResult<ReplyEntity>>> getReplies({
    required int postId,
    required int commentId,
    int pageNumber = 1,
    int pageSize = 10,
  });

  Future<Either<Failure, ReplyEntity>> addReply({
    required int postId,
    required int parentCommentId,
    required String text,
  });

  // ─── Reactions ────────────────────────────────────────────────────────

  Future<Either<Failure, ReactCounts>> toggleReact({
    required int postId,
    required ReactType reactType,
  });

  Future<Either<Failure, Unit>> removeReact(int postId);

  Future<Either<Failure, ReactCounts>> getReactCounts(int postId);

  // ─── Saved Posts ──────────────────────────────────────────────────────

  Future<Either<Failure, PaginatedResult<SavedPostItem>>> getSavedPosts({
    int pageNumber = 1,
    int pageSize = 10,
  });

  Future<Either<Failure, Unit>> savePost(int postId);

  Future<Either<Failure, Unit>> unSavePost(int postId);

  // ─── Followers ────────────────────────────────────────────────────────

  Future<Either<Failure, Unit>> followUser(String userId);

  Future<Either<Failure, Unit>> unfollowUser(String userId);

  // ─── User Profile ────────────────────────────────────────────────────

  Future<Either<Failure, UserProfileEntity>> getUserProfile(String userId);

  // ─── Report (stub — no endpoint yet) ──────────────────────────────────

  /// TODO: Wire to backend when the report endpoint is available.
  Future<Either<Failure, Unit>> reportPost(int postId);
}

