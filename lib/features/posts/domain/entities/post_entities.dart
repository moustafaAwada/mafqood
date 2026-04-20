import 'package:equatable/equatable.dart';

enum PostType { lost, found }

enum ReactType { like, dislike }

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
    int? likesCount,
    int? dislikesCount,
    ReactType? userReactType,
    bool clearUserReactType = false,
    bool? isSaved,
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
      commentsCount: commentsCount,
      createdAt: createdAt,
      isOwner: isOwner,
      isFollowedByCurrentUser: isFollowedByCurrentUser,
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

