import 'package:equatable/equatable.dart';

/// DTOs for the 5 `PostInteractionHub` server→client events.
/// Each DTO is parsed from the raw `Map<String, dynamic>` delivered by SignalR
/// inside `PostInteractionHubService._asMap()`.

// ─── CommentAdded ───────────────────────────────────────────────────────────

class CommentAddedDto extends Equatable {
  final int id;
  final int postId;
  final String userId;
  final String? name;
  final String text;
  final DateTime createdAt;

  const CommentAddedDto({
    required this.id,
    required this.postId,
    required this.userId,
    required this.name,
    required this.text,
    required this.createdAt,
  });

  factory CommentAddedDto.fromJson(Map<String, dynamic> json) {
    return CommentAddedDto(
      id: json['id'] as int,
      postId: json['postId'] as int,
      userId: (json['userId'] ?? '') as String,
      name: json['name'] as String?,
      text: (json['text'] ?? '') as String,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, postId, userId, name, text, createdAt];
}

// ─── ReplyAdded ─────────────────────────────────────────────────────────────

class ReplyAddedDto extends Equatable {
  final int id;
  final int postId;
  final int parentCommentId;
  final String userId;
  final String? name;
  final String text;
  final DateTime createdAt;

  const ReplyAddedDto({
    required this.id,
    required this.postId,
    required this.parentCommentId,
    required this.userId,
    required this.name,
    required this.text,
    required this.createdAt,
  });

  factory ReplyAddedDto.fromJson(Map<String, dynamic> json) {
    return ReplyAddedDto(
      id: json['id'] as int,
      postId: json['postId'] as int,
      parentCommentId: (json['parentCommentId'] as int?) ?? 0,
      userId: (json['userId'] ?? '') as String,
      name: json['name'] as String?,
      text: (json['text'] ?? '') as String,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  @override
  List<Object?> get props =>
      [id, postId, parentCommentId, userId, name, text, createdAt];
}

// ─── CommentUpdated ─────────────────────────────────────────────────────────

class CommentUpdatedDto extends Equatable {
  final int id;
  final int postId;
  final String text;
  final DateTime updatedAt;

  const CommentUpdatedDto({
    required this.id,
    required this.postId,
    required this.text,
    required this.updatedAt,
  });

  factory CommentUpdatedDto.fromJson(Map<String, dynamic> json) {
    return CommentUpdatedDto(
      id: json['id'] as int,
      postId: json['postId'] as int,
      text: (json['text'] ?? '') as String,
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, postId, text, updatedAt];
}

// ─── CommentDeleted ─────────────────────────────────────────────────────────

class CommentDeletedDto extends Equatable {
  final int id;
  final int postId;

  const CommentDeletedDto({
    required this.id,
    required this.postId,
  });

  factory CommentDeletedDto.fromJson(Map<String, dynamic> json) {
    return CommentDeletedDto(
      id: json['id'] as int,
      postId: json['postId'] as int,
    );
  }

  @override
  List<Object?> get props => [id, postId];
}

// ─── ReactionUpdated ────────────────────────────────────────────────────────

class ReactionUpdatedDto extends Equatable {
  final int postId;
  final String userId;
  final int? currentReactType; // 0 = Like, 1 = Dislike, null = removed
  final int likesCount;
  final int dislikesCount;

  const ReactionUpdatedDto({
    required this.postId,
    required this.userId,
    required this.currentReactType,
    required this.likesCount,
    required this.dislikesCount,
  });

  factory ReactionUpdatedDto.fromJson(Map<String, dynamic> json) {
    return ReactionUpdatedDto(
      postId: json['postId'] as int,
      userId: (json['userId'] ?? '') as String,
      currentReactType: json['currentReactType'] as int?,
      likesCount: (json['likesCount'] as int?) ?? 0,
      dislikesCount: (json['dislikesCount'] as int?) ?? 0,
    );
  }

  @override
  List<Object?> get props =>
      [postId, userId, currentReactType, likesCount, dislikesCount];
}
