import 'package:dartz/dartz.dart';
import 'package:mafqood/core/error/exceptions.dart';
import 'package:mafqood/core/error/failures.dart';
import 'package:mafqood/features/posts/data/datasources/post_remote_data_source.dart';
import 'package:mafqood/features/posts/domain/entities/post_entities.dart';
import 'package:mafqood/features/posts/domain/repositories/post_repository.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource _remote;

  PostRepositoryImpl({required PostRemoteDataSource remote}) : _remote = remote;

  // ─── Post Management ──────────────────────────────────────────────────

  @override
  Future<Either<Failure, PaginatedResult<PostItem>>> getPosts({
    int pageNumber = 1,
    int pageSize = 10,
    String? searchKey,
    PostType? type,
  }) async {
    try {
      final result = await _remote.getPosts(
        pageNumber: pageNumber,
        pageSize: pageSize,
        searchKey: searchKey,
        type: type,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostItem>> getPostById(int postId) async {
    try {
      final result = await _remote.getPostById(postId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> createPost({
    required String description,
    required int type,
    required double latitude,
    required double longitude,
    String? imagePath,
  }) async {
    try {
      await _remote.createPost(
        description: description,
        type: type,
        latitude: latitude,
        longitude: longitude,
        imagePath: imagePath,
      );
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updatePost({
    required int postId,
    int? type,
    String? description,
    double? latitude,
    double? longitude,
    String? imagePath,
  }) async {
    try {
      await _remote.updatePost(
        postId: postId,
        type: type,
        description: description,
        latitude: latitude,
        longitude: longitude,
        imagePath: imagePath,
      );
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deletePost(int postId) async {
    try {
      await _remote.deletePost(postId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ─── Comments ─────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, PaginatedResult<CommentEntity>>> getComments({
    required int postId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final result = await _remote.getComments(
        postId: postId,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
      // CommentModel fields are a superset of CommentEntity — the
      // PaginatedResult<CommentModel> is assignable to
      // PaginatedResult<CommentEntity> because CommentModel contains
      // identical public fields. We map to produce clean entities.
      return Right(PaginatedResult<CommentEntity>(
        items: result.items.map(_mapCommentModelToEntity).toList(),
        pageNumber: result.pageNumber,
        totalPages: result.totalPages,
        hasPreviousPage: result.hasPreviousPage,
        hasNextPage: result.hasNextPage,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CommentEntity>> addComment({
    required int postId,
    required String text,
  }) async {
    try {
      final result = await _remote.addComment(postId: postId, text: text);
      return Right(_mapCommentModelToEntity(result));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CommentEntity>> updateComment({
    required int postId,
    required int commentId,
    required String text,
  }) async {
    try {
      final result = await _remote.updateComment(
        postId: postId,
        commentId: commentId,
        text: text,
      );
      return Right(_mapCommentModelToEntity(result));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteComment({
    required int postId,
    required int commentId,
  }) async {
    try {
      await _remote.deleteComment(postId: postId, commentId: commentId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ─── Replies ──────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, PaginatedResult<ReplyEntity>>> getReplies({
    required int postId,
    required int commentId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final result = await _remote.getReplies(
        postId: postId,
        commentId: commentId,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
      return Right(PaginatedResult<ReplyEntity>(
        items: result.items.map(_mapReplyModelToEntity).toList(),
        pageNumber: result.pageNumber,
        totalPages: result.totalPages,
        hasPreviousPage: result.hasPreviousPage,
        hasNextPage: result.hasNextPage,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReplyEntity>> addReply({
    required int postId,
    required int parentCommentId,
    required String text,
  }) async {
    try {
      final result = await _remote.addReply(
        postId: postId,
        parentCommentId: parentCommentId,
        text: text,
      );
      return Right(_mapReplyModelToEntity(result));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ─── Reactions ────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, ReactCounts>> toggleReact({
    required int postId,
    required ReactType reactType,
  }) async {
    try {
      final result = await _remote.toggleReact(
        postId: postId,
        reactType: reactType,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeReact(int postId) async {
    try {
      await _remote.removeReact(postId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReactCounts>> getReactCounts(int postId) async {
    try {
      final result = await _remote.getReactCounts(postId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ─── Saved Posts ──────────────────────────────────────────────────────

  @override
  Future<Either<Failure, PaginatedResult<SavedPostItem>>> getSavedPosts({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final result = await _remote.getSavedPosts(
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
      return Right(PaginatedResult<SavedPostItem>(
        items: result.items.map(_mapSavedPostModelToEntity).toList(),
        pageNumber: result.pageNumber,
        totalPages: result.totalPages,
        hasPreviousPage: result.hasPreviousPage,
        hasNextPage: result.hasNextPage,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> savePost(int postId) async {
    try {
      await _remote.savePost(postId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> unSavePost(int postId) async {
    try {
      await _remote.unSavePost(postId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ─── Followers ────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Unit>> followUser(String userId) async {
    try {
      await _remote.followUser(userId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> unfollowUser(String userId) async {
    try {
      await _remote.unfollowUser(userId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ─── User Profile ────────────────────────────────────────────────────

  @override
  Future<Either<Failure, UserProfileEntity>> getUserProfile(
    String userId,
  ) async {
    try {
      final model = await _remote.getUserProfile(userId);
      return Right(UserProfileEntity(
        id: model.id,
        email: model.email,
        name: model.name,
        phoneNumber: model.phoneNumber,
        profilePictureUrl: model.profilePictureUrl,
        isFollowedByCurrentUser: model.isFollowedByCurrentUser,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.errorModel.errorMessage));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ─── Report (stub) ───────────────────────────────────────────────────

  @override
  Future<Either<Failure, Unit>> reportPost(int postId) async {
    // TODO: Wire to backend when the report endpoint is available.
    return const Right(unit);
  }

  // ─── Model → Entity Mappers ──────────────────────────────────────────

  CommentEntity _mapCommentModelToEntity(dynamic model) {
    final m = model as dynamic;
    return CommentEntity(
      id: m.id as int,
      postId: m.postId as int,
      userId: m.userId as String,
      name: m.name as String?,
      text: m.text as String,
      parentCommentId: m.parentCommentId as int?,
      replies: (m.replies as List<dynamic>)
          .map(_mapCommentModelToEntity)
          .toList(),
      createdAt: m.createdAt as DateTime,
      updatedAt: m.updatedAt as DateTime?,
      isOwner: m.isOwner as bool,
    );
  }

  ReplyEntity _mapReplyModelToEntity(dynamic model) {
    final m = model as dynamic;
    return ReplyEntity(
      id: m.id as int,
      postId: m.postId as int,
      parentCommentId: m.parentCommentId as int,
      userId: m.userId as String,
      name: m.name as String?,
      text: m.text as String,
      createdAt: m.createdAt as DateTime,
      updatedAt: m.updatedAt as DateTime?,
      isOwner: m.isOwner as bool,
    );
  }

  SavedPostItem _mapSavedPostModelToEntity(dynamic model) {
    final m = model as dynamic;
    return SavedPostItem(
      postId: m.postId as int,
      userId: m.userId as String,
      userName: m.userName as String?,
      userProfilePictureUrl: m.userProfilePictureUrl as String?,
      imageUrl: m.imageUrl as String?,
      description: m.description as String?,
      latitude: m.latitude as double,
      longitude: m.longitude as double,
      type: m.type as PostType,
      commentsCount: m.commentsCount as int,
      createdAt: m.createdAt as DateTime,
      savedAt: m.savedAt as DateTime,
      isOwner: m.isOwner as bool,
      isFollowedByCurrentUser: m.isFollowedByCurrentUser as bool,
    );
  }
}
