import 'package:mafqood/features/posts/data/models/post_comment_models.dart';
import 'package:mafqood/features/posts/data/models/post_models.dart';
import 'package:mafqood/features/posts/data/models/user_profile_model.dart';
import 'package:mafqood/features/posts/domain/entities/post_entities.dart';

abstract class PostRemoteDataSource {
  // ─── Post Management ──────────────────────────────────────────────────

  Future<PaginatedResult<PostItem>> getPosts({
    int pageNumber = 1,
    int pageSize = 10,
    String? searchKey,
    PostType? type,
  });

  Future<PostItemModel> getPostById(int postId);

  Future<void> createPost({
    required String description,
    required int type,
    required double latitude,
    required double longitude,
    String? imagePath,
  });

  Future<void> updatePost({
    required int postId,
    int? type,
    String? description,
    double? latitude,
    double? longitude,
    String? imagePath,
  });

  Future<void> deletePost(int postId);

  // ─── Comments ─────────────────────────────────────────────────────────

  Future<PaginatedResult<CommentModel>> getComments({
    required int postId,
    int pageNumber = 1,
    int pageSize = 10,
  });

  Future<CommentModel> addComment({
    required int postId,
    required String text,
  });

  Future<CommentModel> updateComment({
    required int postId,
    required int commentId,
    required String text,
  });

  Future<void> deleteComment({
    required int postId,
    required int commentId,
  });

  // ─── Replies ──────────────────────────────────────────────────────────

  Future<PaginatedResult<ReplyModel>> getReplies({
    required int postId,
    required int commentId,
    int pageNumber = 1,
    int pageSize = 10,
  });

  Future<ReplyModel> addReply({
    required int postId,
    required int parentCommentId,
    required String text,
  });

  // ─── Reactions ────────────────────────────────────────────────────────

  Future<ReactCounts> getReactCounts(int postId);

  Future<ReactCounts> toggleReact({
    required int postId,
    required ReactType reactType,
  });

  Future<void> removeReact(int postId);

  // ─── Saved Posts ──────────────────────────────────────────────────────

  Future<PaginatedResult<SavedPostModel>> getSavedPosts({
    int pageNumber = 1,
    int pageSize = 10,
  });

  Future<void> savePost(int postId);

  Future<void> unSavePost(int postId);

  // ─── Followers ────────────────────────────────────────────────────────

  Future<void> followUser(String userId);

  Future<void> unfollowUser(String userId);

  // ─── User Profile ────────────────────────────────────────────────────

  Future<UserProfileModel> getUserProfile(String userId);
}
