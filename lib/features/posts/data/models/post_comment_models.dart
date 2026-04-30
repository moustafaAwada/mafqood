import 'package:equatable/equatable.dart';
import 'package:mafqood/features/posts/domain/entities/post_entities.dart';

// ─── Comment Model ──────────────────────────────────────────────────────────

class CommentModel extends Equatable {
  final int id;
  final int postId;
  final String userId;
  final String? name;
  final String text;
  final int? parentCommentId;
  final List<CommentModel> replies;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isOwner;

  const CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.name,
    required this.text,
    this.parentCommentId,
    this.replies = const [],
    required this.createdAt,
    this.updatedAt,
    required this.isOwner,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final rawReplies = json['replies'] as List<dynamic>? ?? const [];
    return CommentModel(
      id: json['id'] as int,
      postId: (json['postId'] as int?) ?? 0,
      userId: (json['userId'] ?? '') as String,
      name: json['name'] as String?,
      text: (json['text'] ?? '') as String,
      parentCommentId: json['parentCommentId'] as int?,
      replies: rawReplies
          .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      isOwner: (json['isOwner'] as bool?) ?? false,
    );
  }

  CommentModel copyWith({
    String? text,
    DateTime? updatedAt,
    List<CommentModel>? replies,
  }) {
    return CommentModel(
      id: id,
      postId: postId,
      userId: userId,
      name: name,
      text: text ?? this.text,
      parentCommentId: parentCommentId,
      replies: replies ?? this.replies,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isOwner: isOwner,
    );
  }

  @override
  List<Object?> get props => [
        id,
        postId,
        userId,
        name,
        text,
        parentCommentId,
        replies,
        createdAt,
        updatedAt,
        isOwner,
      ];
}

// ─── Reply Model ────────────────────────────────────────────────────────────
// Replies share the same shape as comments but always have a parentCommentId
// and never have nested replies. We use a distinct class for type-safety.

class ReplyModel extends Equatable {
  final int id;
  final int postId;
  final int parentCommentId;
  final String userId;
  final String? name;
  final String text;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isOwner;

  const ReplyModel({
    required this.id,
    required this.postId,
    required this.parentCommentId,
    required this.userId,
    required this.name,
    required this.text,
    required this.createdAt,
    this.updatedAt,
    required this.isOwner,
  });

  factory ReplyModel.fromJson(Map<String, dynamic> json) {
    return ReplyModel(
      id: json['id'] as int,
      postId: (json['postId'] as int?) ?? 0,
      parentCommentId: (json['parentCommentId'] as int?) ?? 0,
      userId: (json['userId'] ?? '') as String,
      name: json['name'] as String?,
      text: (json['text'] ?? '') as String,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      isOwner: (json['isOwner'] as bool?) ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        postId,
        parentCommentId,
        userId,
        name,
        text,
        createdAt,
        updatedAt,
        isOwner,
      ];
}

// ─── Saved Post Model ───────────────────────────────────────────────────────
// Uses postId (not id) as its primary key because the backend returns it under
// the key "postId" in GET /saved-posts responses.

PostType _mapPostType(int value) => value == 1 ? PostType.found : PostType.lost;

class SavedPostModel extends Equatable {
  final int postId;
  final String userId;
  final String? userName;
  final String? userProfilePictureUrl;
  final String? imageUrl;
  final String? description;
  final double latitude;
  final double longitude;
  final PostType type;
  final int commentsCount;
  final DateTime createdAt;
  final DateTime savedAt;
  final bool isOwner;
  final bool isFollowedByCurrentUser;

  const SavedPostModel({
    required this.postId,
    required this.userId,
    required this.userName,
    required this.userProfilePictureUrl,
    required this.imageUrl,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.commentsCount,
    required this.createdAt,
    required this.savedAt,
    required this.isOwner,
    required this.isFollowedByCurrentUser,
  });

  factory SavedPostModel.fromJson(Map<String, dynamic> json) {
    return SavedPostModel(
      postId: json['postId'] as int,
      userId: (json['userId'] ?? '') as String,
      userName: json['userName'] as String?,
      userProfilePictureUrl: json['userProfilePictureUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      type: _mapPostType((json['type'] as int?) ?? 0),
      commentsCount: (json['commentsCount'] as int?) ?? 0,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      savedAt: DateTime.tryParse((json['savedAt'] ?? '').toString()) ??
          DateTime.now(),
      isOwner: (json['isOwner'] as bool?) ?? false,
      isFollowedByCurrentUser:
          (json['isFollowedByCurrentUser'] as bool?) ?? false,
    );
  }

  @override
  List<Object?> get props => [
        postId,
        userId,
        userName,
        userProfilePictureUrl,
        imageUrl,
        description,
        latitude,
        longitude,
        type,
        commentsCount,
        createdAt,
        savedAt,
        isOwner,
        isFollowedByCurrentUser,
      ];
}

// ─── Create Post Response ───────────────────────────────────────────────────

class CreatePostResponseModel extends Equatable {
  final int id;
  final String? imageUrl;
  final double latitude;
  final double longitude;
  final String? description;
  final PostType type;
  final DateTime createdAt;

  const CreatePostResponseModel({
    required this.id,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.type,
    required this.createdAt,
  });

  factory CreatePostResponseModel.fromJson(Map<String, dynamic> json) {
    return CreatePostResponseModel(
      id: json['id'] as int,
      imageUrl: json['imageUrl'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String?,
      type: _mapPostType((json['type'] as int?) ?? 0),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  @override
  List<Object?> get props =>
      [id, imageUrl, latitude, longitude, description, type, createdAt];
}
