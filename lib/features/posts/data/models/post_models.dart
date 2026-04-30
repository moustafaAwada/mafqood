import 'package:mafqood/core/api/end_points.dart';
import 'package:mafqood/features/posts/domain/entities/post_entities.dart';

String? _getFullUrl(String? url) {
  if (url == null || url.isEmpty) return null;
  if (url.startsWith('http')) return url;
  final baseUrl = EndPoints.baseUrl.endsWith('/') 
      ? EndPoints.baseUrl.substring(0, EndPoints.baseUrl.length - 1) 
      : EndPoints.baseUrl;
  final path = url.startsWith('/') ? url : '/$url';
  return '$baseUrl$path';
}

PostType _mapPostType(int value) => value == 1 ? PostType.found : PostType.lost;

ReactType? _mapReactTypeNullable(dynamic value) {
  if (value == null) return null;
  if (value == 1) return ReactType.dislike;
  return ReactType.like;
}

class PostItemModel extends PostItem {
  const PostItemModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.userProfilePictureUrl,
    required super.imageUrl,
    required super.description,
    required super.latitude,
    required super.longitude,
    required super.type,
    required super.commentsCount,
    required super.createdAt,
    required super.isOwner,
    required super.isFollowedByCurrentUser,
    super.likesCount,
    super.dislikesCount,
    super.userReactType,
    super.isSaved,
  });

  factory PostItemModel.fromJson(Map<String, dynamic> json) {
    return PostItemModel(
      id: json['id'] as int,
      userId: (json['userId'] ?? '') as String,
      userName: json['userName'] as String?,
      userProfilePictureUrl: _getFullUrl(json['userProfilePictureUrl'] as String?),
      imageUrl: _getFullUrl(json['imageUrl'] as String?),
      description: json['description'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      type: _mapPostType((json['type'] as int?) ?? 0),
      commentsCount: (json['commentsCount'] as int?) ?? 0,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      isOwner: (json['isOwner'] as bool?) ?? false,
      isFollowedByCurrentUser:
          (json['isFollowedByCurrentUser'] as bool?) ?? false,
      likesCount: (json['likesCount'] as int?) ?? 0,
      dislikesCount: (json['dislikesCount'] as int?) ?? 0,
      userReactType: _mapReactTypeNullable(json['userReactType']),
      isSaved: (json['isSaved'] as bool?) ?? false,
    );
  }
}

class ReactCountsModel extends ReactCounts {
  const ReactCountsModel({
    required super.postId,
    required super.likesCount,
    required super.dislikesCount,
    required super.userReactType,
  });

  factory ReactCountsModel.fromJson(Map<String, dynamic> json) {
    return ReactCountsModel(
      postId: (json['postId'] as int?) ?? 0,
      likesCount: (json['likesCount'] as int?) ?? 0,
      dislikesCount: (json['dislikesCount'] as int?) ?? 0,
      userReactType: _mapReactTypeNullable(json['userReactType']),
    );
  }
}

class PaginatedResultModel<T> extends PaginatedResult<T> {
  const PaginatedResultModel({
    required super.items,
    required super.pageNumber,
    required super.totalPages,
    required super.hasPreviousPage,
    required super.hasNextPage,
  });

  factory PaginatedResultModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> item) mapper,
  ) {
    final rawItems = (json['items'] as List<dynamic>? ?? const []);
    return PaginatedResultModel<T>(
      items: rawItems.map((e) => mapper(e as Map<String, dynamic>)).toList(),
      pageNumber: (json['pageNumber'] as int?) ?? 1,
      totalPages: (json['totalPages'] as int?) ?? 1,
      hasPreviousPage: (json['hasPreviousPage'] as bool?) ?? false,
      hasNextPage: (json['hasNextPage'] as bool?) ?? false,
    );
  }
}

