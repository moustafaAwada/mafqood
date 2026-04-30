import 'package:equatable/equatable.dart';

enum PostType { lost, found }

enum ReactType { like, dislike }

// ─── PostItem ───────────────────────────────────────────────────────────────

class PostItem extends Equatable {
  final int id;
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
  final bool isOwner;
  final bool isFollowedByCurrentUser;
  final int likesCount;
  final int dislikesCount;
  final ReactType? userReactType;
  final bool isSaved;

  const PostItem({
    required this.id,
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
    required this.isOwner,
    required this.isFollowedByCurrentUser,
    this.likesCount = 0,
    this.dislikesCount = 0,
    this.userReactType,
    this.isSaved = false,
  });

  PostItem copyWith({
    int? commentsCount,
    int? likesCount,
    int? dislikesCount,
    ReactType? userReactType,
    bool clearUserReactType = false,
    bool? isSaved,
    bool? isFollowedByCurrentUser,
  }) {
    return PostItem(
      id: id,
      userId: userId,
      userName: userName,
      userProfilePictureUrl: userProfilePictureUrl,
      imageUrl: imageUrl,
      description: description,
      latitude: latitude,
      longitude: longitude,
      type: type,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt,
      isOwner: isOwner,
      isFollowedByCurrentUser:
          isFollowedByCurrentUser ?? this.isFollowedByCurrentUser,
      likesCount: likesCount ?? this.likesCount,
      dislikesCount: dislikesCount ?? this.dislikesCount,
      userReactType:
          clearUserReactType ? null : (userReactType ?? this.userReactType),
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  List<Object?> get props => [
        id,
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
        isOwner,
        isFollowedByCurrentUser,
        likesCount,
        dislikesCount,
        userReactType,
        isSaved,
      ];
}

// ─── CommentEntity ──────────────────────────────────────────────────────────

class CommentEntity extends Equatable {
  final int id;
  final int postId;
  final String userId;
  final String? name;
  final String text;
  final int? parentCommentId;
  final List<CommentEntity> replies;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isOwner;

  const CommentEntity({
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

  CommentEntity copyWith({
    String? text,
    DateTime? updatedAt,
    List<CommentEntity>? replies,
  }) {
    return CommentEntity(
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

// ─── ReplyEntity ────────────────────────────────────────────────────────────

class ReplyEntity extends Equatable {
  final int id;
  final int postId;
  final int parentCommentId;
  final String userId;
  final String? name;
  final String text;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isOwner;

  const ReplyEntity({
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

// ─── SavedPostItem ──────────────────────────────────────────────────────────

class SavedPostItem extends Equatable {
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

  const SavedPostItem({
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

// ─── PaginatedResult ────────────────────────────────────────────────────────

class PaginatedResult<T> extends Equatable {
  final List<T> items;
  final int pageNumber;
  final int totalPages;
  final bool hasPreviousPage;
  final bool hasNextPage;

  const PaginatedResult({
    required this.items,
    required this.pageNumber,
    required this.totalPages,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  @override
  List<Object?> get props =>
      [items, pageNumber, totalPages, hasPreviousPage, hasNextPage];
}

// ─── ReactCounts ────────────────────────────────────────────────────────────

class ReactCounts extends Equatable {
  final int postId;
  final int likesCount;
  final int dislikesCount;
  final ReactType? userReactType;

  const ReactCounts({
    required this.postId,
    required this.likesCount,
    required this.dislikesCount,
    required this.userReactType,
  });

  @override
  List<Object?> get props => [postId, likesCount, dislikesCount, userReactType];
}

// ─── UserProfileEntity ──────────────────────────────────────────────────────

class UserProfileEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final String? profilePictureUrl;
  final bool isFollowedByCurrentUser;

  const UserProfileEntity({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    this.profilePictureUrl,
    required this.isFollowedByCurrentUser,
  });

  UserProfileEntity copyWith({
    bool? isFollowedByCurrentUser,
  }) {
    return UserProfileEntity(
      id: id,
      email: email,
      name: name,
      phoneNumber: phoneNumber,
      profilePictureUrl: profilePictureUrl,
      isFollowedByCurrentUser:
          isFollowedByCurrentUser ?? this.isFollowedByCurrentUser,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        phoneNumber,
        profilePictureUrl,
        isFollowedByCurrentUser,
      ];
}

