import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mafqood/core/api/api_consumer.dart';
import 'package:mafqood/core/api/end_points.dart';
import 'package:mafqood/features/posts/data/datasources/post_remote_data_source.dart';
import 'package:mafqood/features/posts/data/models/post_comment_models.dart';
import 'package:mafqood/features/posts/data/models/post_models.dart';
import 'package:mafqood/features/posts/data/models/user_profile_model.dart';
import 'package:mafqood/features/posts/domain/entities/post_entities.dart';

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final ApiConsumer _api;

  PostRemoteDataSourceImpl({required ApiConsumer api}) : _api = api;

  // ─── Helpers ──────────────────────────────────────────────────────────

  int? _typeToInt(PostType? type) {
    if (type == null) return null;
    return type == PostType.lost ? 0 : 1;
  }

  int _reactTypeToInt(ReactType type) => type == ReactType.like ? 0 : 1;

  Map<String, dynamic> _extractData(dynamic response) {
    return (response as Map<String, dynamic>)['data'] as Map<String, dynamic>;
  }

  // ─── Post Management ──────────────────────────────────────────────────

  @override
  Future<PaginatedResult<PostItem>> getPosts({
    int pageNumber = 1,
    int pageSize = 10,
    String? searchKey,
    PostType? type,
  }) async {
    final response = await _api.get(
      EndPoints.posts,
      queryParameters: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        if (searchKey != null && searchKey.trim().isNotEmpty)
          'searchKey': searchKey.trim(),
        if (_typeToInt(type) != null) 'type': _typeToInt(type),
      },
    );

    final data = _extractData(response);
    return PaginatedResultModel<PostItem>.fromJson(
      data,
      (item) => PostItemModel.fromJson(item),
    );
  }

  @override
  Future<PostItemModel> getPostById(int postId) async {
    final response = await _api.get(EndPoints.postById(postId));
    final data = _extractData(response);
    return PostItemModel.fromJson(data);
  }

  @override
  Future<void> createPost({
    required String description,
    required int type,
    required double latitude,
    required double longitude,
    String? imagePath,
  }) async {
    final request = <String, dynamic>{
      'Description': description,
      'Type': type,
      'Latitude': latitude,
      'Longitude': longitude,
    };

    final bool hasImage = imagePath != null && imagePath.trim().isNotEmpty;
    if (hasImage) {
      request['Image'] = MultipartFile.fromFileSync(
        imagePath,
        filename: imagePath.split(Platform.pathSeparator).last,
      );
    }

    await _api.post(
      EndPoints.posts,
      data: FormData.fromMap(request),
      isFormData: true,
    );
  }

  @override
  Future<void> updatePost({
    required int postId,
    int? type,
    String? description,
    double? latitude,
    double? longitude,
    String? imagePath,
  }) async {
    final request = <String, dynamic>{
      if (type != null) 'Type': type,
      if (description != null) 'Description': description,
      if (latitude != null) 'Latitude': latitude,
      if (longitude != null) 'Longitude': longitude,
    };

    final bool hasImage = imagePath != null && imagePath.trim().isNotEmpty;
    if (hasImage) {
      request['Image'] = MultipartFile.fromFileSync(
        imagePath,
        filename: imagePath.split(Platform.pathSeparator).last,
      );
    }

    await _api.put(
      EndPoints.postById(postId),
      data: FormData.fromMap(request),
      isFormData: true,
    );
  }

  @override
  Future<void> deletePost(int postId) async {
    await _api.delete(EndPoints.postById(postId));
  }

  // ─── Comments ─────────────────────────────────────────────────────────

  @override
  Future<PaginatedResult<CommentModel>> getComments({
    required int postId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final response = await _api.get(
      EndPoints.postComments(postId),
      queryParameters: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
    );

    final data = _extractData(response);
    return PaginatedResultModel<CommentModel>.fromJson(
      data,
      (item) => CommentModel.fromJson(item),
    );
  }

  @override
  Future<CommentModel> addComment({
    required int postId,
    required String text,
  }) async {
    final response = await _api.post(
      EndPoints.postComments(postId),
      data: {'postId': postId, 'text': text},
    );
    final data = _extractData(response);
    return CommentModel.fromJson(data);
  }

  @override
  Future<CommentModel> updateComment({
    required int postId,
    required int commentId,
    required String text,
  }) async {
    final response = await _api.put(
      EndPoints.commentById(postId, commentId),
      data: {'commentId': commentId, 'text': text},
    );
    final data = _extractData(response);
    return CommentModel.fromJson(data);
  }

  @override
  Future<void> deleteComment({
    required int postId,
    required int commentId,
  }) async {
    await _api.delete(EndPoints.commentById(postId, commentId));
  }

  // ─── Replies ──────────────────────────────────────────────────────────

  @override
  Future<PaginatedResult<ReplyModel>> getReplies({
    required int postId,
    required int commentId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final response = await _api.get(
      EndPoints.commentReplies(postId, commentId),
      queryParameters: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
    );

    final data = _extractData(response);
    return PaginatedResultModel<ReplyModel>.fromJson(
      data,
      (item) => ReplyModel.fromJson(item),
    );
  }

  @override
  Future<ReplyModel> addReply({
    required int postId,
    required int parentCommentId,
    required String text,
  }) async {
    final response = await _api.post(
      EndPoints.commentReplies(postId, parentCommentId),
      data: {
        'postId': postId,
        'parentCommentId': parentCommentId,
        'text': text,
      },
    );
    final data = _extractData(response);
    return ReplyModel.fromJson(data);
  }

  // ─── Reactions ────────────────────────────────────────────────────────

  @override
  Future<ReactCounts> getReactCounts(int postId) async {
    final response = await _api.get(EndPoints.postReactCounts(postId));
    final data = _extractData(response);
    return ReactCountsModel.fromJson(data);
  }

  @override
  Future<ReactCounts> toggleReact({
    required int postId,
    required ReactType reactType,
  }) async {
    final response = await _api.post(
      EndPoints.postReacts(postId),
      data: {'postId': postId, 'reactType': _reactTypeToInt(reactType)},
    );
    final data = _extractData(response);
    return ReactCountsModel.fromJson(data);
  }

  @override
  Future<void> removeReact(int postId) async {
    await _api.delete(EndPoints.postReacts(postId));
  }

  // ─── Saved Posts ──────────────────────────────────────────────────────

  @override
  Future<PaginatedResult<SavedPostModel>> getSavedPosts({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final response = await _api.get(
      EndPoints.savedPosts,
      queryParameters: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
    );

    final data = _extractData(response);
    return PaginatedResultModel<SavedPostModel>.fromJson(
      data,
      (item) => SavedPostModel.fromJson(item),
    );
  }

  @override
  Future<void> savePost(int postId) async {
    await _api.post(EndPoints.savePost(postId));
  }

  @override
  Future<void> unSavePost(int postId) async {
    await _api.delete(EndPoints.unSavePost(postId));
  }

  // ─── Followers ────────────────────────────────────────────────────────

  @override
  Future<void> followUser(String userId) async {
    await _api.post(EndPoints.followUser(userId));
  }

  @override
  Future<void> unfollowUser(String userId) async {
    await _api.delete(EndPoints.unfollowUser(userId));
  }

  // ─── User Profile ────────────────────────────────────────────────────

  @override
  Future<UserProfileModel> getUserProfile(String userId) async {
    final response = await _api.get(EndPoints.userProfile(userId));
    final data = _extractData(response);
    return UserProfileModel.fromJson(data);
  }
}
