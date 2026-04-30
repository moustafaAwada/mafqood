import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mafqood/features/posts/data/models/post_signalr_dtos.dart';
import 'package:mafqood/features/posts/data/services/post_interaction_hub_service.dart';
import 'package:mafqood/features/posts/domain/entities/post_entities.dart';
import 'package:mafqood/features/posts/domain/repositories/post_repository.dart';
import 'package:mafqood/features/posts/presentation/cubit/post_feed_state.dart';

class PostFeedCubit extends Cubit<PostFeedState> {
  final PostRepository _repository;
  final PostInteractionHubService _hubService;

  PostFeedCubit({
    required PostRepository repository,
    required PostInteractionHubService hubService,
  })  : _repository = repository,
        _hubService = hubService,
        super(const PostFeedState()) {
    _setupHubCallbacks();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INITIALIZATION — SignalR Hub Callback Wiring
  // ═══════════════════════════════════════════════════════════════════════════

  void _setupHubCallbacks() {
    _hubService.onCommentAdded = _onCommentAdded;
    _hubService.onReplyAdded = _onReplyAdded;
    _hubService.onCommentUpdated = _onCommentUpdated;
    _hubService.onCommentDeleted = _onCommentDeleted;
    _hubService.onReactionUpdated = _onReactionUpdated;
    _hubService.onReconnected = _onReconnected;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ACTION KEY DEDUPLICATION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Generate a unique action key for HTTP→SignalR deduplication.
  ///
  /// Format: `<event_type>:<postId>:<entityId>`
  ///
  /// Examples:
  /// - `comment_added:42:101`
  /// - `reply_added:42:205`
  /// - `comment_updated:42:101`
  /// - `comment_deleted:42:101`
  /// - `reaction_updated:42:user123`
  static String generateActionKey(String eventType, int postId, dynamic id) {
    return '$eventType:$postId:$id';
  }

  /// Check if a SignalR event should be skipped because the Cubit already
  /// applied the corresponding REST response optimistically.
  bool _shouldSkipSignalREvent(String actionKey) {
    if (state.pendingActions.contains(actionKey)) {
      final updated = Set<String>.from(state.pendingActions)..remove(actionKey);
      emit(state.copyWith(pendingActions: updated));
      return true;
    }
    return false;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FEED — FETCH & PAGINATION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Fetch posts from the API. If [refresh] is true, resets to page 1.
  Future<void> fetchPosts({
    bool refresh = false,
    PostType? typeFilter,
  }) async {
    if (state.isLoadingPosts && !refresh) return;

    final page = refresh ? 1 : state.currentPage;
    final filter = typeFilter ?? state.typeFilter;

    emit(state.copyWith(
      isLoadingPosts: !refresh,
      isRefreshing: refresh,
      clearError: true,
      typeFilter: filter,
      clearTypeFilter: typeFilter == null && refresh,
    ));

    final result = await _repository.getPosts(
      pageNumber: page,
      pageSize: 10,
      searchKey:
          state.searchQuery.trim().isEmpty ? null : state.searchQuery.trim(),
      type: filter,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isLoadingPosts: false,
        isRefreshing: false,
        error: failure.message,
      )),
      (paginated) {
        final updatedPosts =
            refresh ? paginated.items : [...state.posts, ...paginated.items];
        emit(state.copyWith(
          posts: updatedPosts,
          isLoadingPosts: false,
          isRefreshing: false,
          hasMorePosts: paginated.hasNextPage,
          currentPage: page + 1,
        ));
      },
    );
  }

  /// Load the next page of posts (called by scroll listener).
  Future<void> loadMorePosts() async {
    if (!state.hasMorePosts || state.isLoadingPosts) return;
    await fetchPosts();
  }

  /// Update the local search query. Triggers a fresh fetch.
  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
    fetchPosts(refresh: true);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POST DETAILS — NAVIGATION CONTEXT
  // ═══════════════════════════════════════════════════════════════════════════

  /// Open the post details view:
  /// 1. Sets `currentOpenPostId` and `isInPostDetailsView`.
  /// 2. Clears unread counts for this post.
  /// 3. Joins the post's SignalR group.
  /// 4. Fetches post details + initial comments page.
  Future<void> openPostDetails(int postId) async {
    // Leave previous post if we were viewing one
    if (state.currentOpenPostId != null &&
        state.currentOpenPostId != postId) {
      _hubService.leavePost(state.currentOpenPostId!);
    }

    // Clear unread for this post
    final updatedUnreads = Map<int, int>.from(state.unreadCommentCounts);
    updatedUnreads.remove(postId);

    emit(state.copyWith(
      currentOpenPostId: postId,
      isInPostDetailsView: true,
      isLoadingDetails: true,
      comments: const [],
      commentsPage: 1,
      hasMoreComments: true,
      isLoadingComments: false,
      unreadCommentCounts: updatedUnreads,
      clearError: true,
    ));

    // Join SignalR group for this post
    _hubService.joinPost(postId);

    // Fetch post details
    final postResult = await _repository.getPostById(postId);
    postResult.fold(
      (failure) => emit(state.copyWith(
        isLoadingDetails: false,
        error: failure.message,
      )),
      (post) => emit(state.copyWith(
        selectedPost: post,
        isLoadingDetails: false,
      )),
    );

    // Fetch initial comments
    await fetchComments(postId, refresh: true);
  }

  /// Close the post details view:
  /// 1. Leaves the post's SignalR group.
  /// 2. Resets detail and comment state.
  void closePostDetails() {
    final postId = state.currentOpenPostId;
    if (postId != null) {
      _hubService.leavePost(postId);
    }

    emit(state.copyWith(
      clearCurrentOpenPostId: true,
      isInPostDetailsView: false,
      clearSelectedPost: true,
      isLoadingDetails: false,
      comments: const [],
      commentsPage: 1,
      hasMoreComments: true,
    ));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // COMMENTS — FETCH & PAGINATION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Fetch comments for a specific post.
  Future<void> fetchComments(int postId, {bool refresh = false}) async {
    if (state.isLoadingComments && !refresh) return;

    final page = refresh ? 1 : state.commentsPage;

    emit(state.copyWith(
      isLoadingComments: true,
      clearError: true,
    ));

    final result = await _repository.getComments(
      postId: postId,
      pageNumber: page,
      pageSize: 10,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isLoadingComments: false,
        error: failure.message,
      )),
      (paginated) {
        final updatedComments = refresh
            ? paginated.items
            : [...state.comments, ...paginated.items];
        emit(state.copyWith(
          comments: updatedComments,
          isLoadingComments: false,
          hasMoreComments: paginated.hasNextPage,
          commentsPage: page + 1,
        ));
      },
    );
  }

  /// Load the next page of comments (called by scroll listener).
  Future<void> loadMoreComments(int postId) async {
    if (!state.hasMoreComments || state.isLoadingComments) return;
    await fetchComments(postId);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REACTIONS — Toggle & Remove (existing + enhanced)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> toggleReact({
    required int postId,
    required ReactType reactType,
  }) async {
    final result = await _repository.toggleReact(
      postId: postId,
      reactType: reactType,
    );

    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (counts) {
        // Update in feed list
        final updatedPosts = _updatePostInList(
          postId,
          (post) => post.copyWith(
            likesCount: counts.likesCount,
            dislikesCount: counts.dislikesCount,
            userReactType: counts.userReactType,
            clearUserReactType: counts.userReactType == null,
          ),
        );

        // Also update selectedPost if viewing this post
        final updatedSelected = state.selectedPost?.id == postId
            ? state.selectedPost!.copyWith(
                likesCount: counts.likesCount,
                dislikesCount: counts.dislikesCount,
                userReactType: counts.userReactType,
                clearUserReactType: counts.userReactType == null,
              )
            : state.selectedPost;

        // Track pending action for dedup
        final actionKey = generateActionKey(
          'reaction_updated',
          postId,
          'self',
        );
        final updatedPending = Set<String>.from(state.pendingActions)
          ..add(actionKey);

        emit(state.copyWith(
          posts: updatedPosts,
          selectedPost: updatedSelected,
          pendingActions: updatedPending,
        ));
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SAVE / UNSAVE (existing + enhanced)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> toggleSave({
    required int postId,
    required bool isSaved,
  }) async {
    final result = isSaved
        ? await _repository.unSavePost(postId)
        : await _repository.savePost(postId);

    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (_) {
        final updatedPosts = _updatePostInList(
          postId,
          (post) => post.copyWith(isSaved: !isSaved),
        );

        final updatedSelected = state.selectedPost?.id == postId
            ? state.selectedPost!.copyWith(isSaved: !isSaved)
            : state.selectedPost;

        emit(state.copyWith(
          posts: updatedPosts,
          selectedPost: updatedSelected,
        ));
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POST CRUD
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> createPost({
    required int type,
    required double latitude,
    required double longitude,
    required String description,
    File? image,
  }) async {
    emit(state.copyWith(clearError: true, clearSuccessMessage: true));

    final result = await _repository.createPost(
      description: description,
      type: type,
      latitude: latitude,
      longitude: longitude,
      imagePath: image?.path,
    );

    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (_) {
        // Refresh the feed to show the new post
        fetchPosts(refresh: true);
      },
    );
  }

  Future<void> updatePost({
    required int postId,
    int? type,
    String? description,
    double? latitude,
    double? longitude,
    File? newImage,
  }) async {
    emit(state.copyWith(clearError: true));

    final result = await _repository.updatePost(
      postId: postId,
      type: type,
      description: description,
      latitude: latitude,
      longitude: longitude,
      imagePath: newImage?.path,
    );

    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (_) {
        // Re-fetch post details & feed to reflect updated data
        if (state.currentOpenPostId == postId) {
          openPostDetails(postId);
        }
        fetchPosts(refresh: true);
      },
    );
  }

  Future<void> deletePost(int postId) async {
    // Snapshot for rollback
    final previousPosts = List<PostItem>.from(state.posts);
    final wasSelected = state.selectedPost?.id == postId;

    // Optimistic: remove from list
    final updatedPosts =
        state.posts.where((p) => p.id != postId).toList();
    emit(state.copyWith(
      posts: updatedPosts,
      clearSelectedPost: wasSelected,
      clearError: true,
    ));

    final result = await _repository.deletePost(postId);

    result.fold(
      (failure) {
        // Revert on failure
        emit(state.copyWith(posts: previousPosts, error: failure.message));
      },
      (_) {
        // Close details view if we deleted the currently open post
        if (state.currentOpenPostId == postId) {
          closePostDetails();
        }
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // COMMENTS — Write (with action key dedup + optimistic UI)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> addComment(int postId, String text) async {
    emit(state.copyWith(clearError: true));

    final result = await _repository.addComment(postId: postId, text: text);

    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (comment) {
        // Register action key so the SignalR handler skips the duplicate
        final actionKey =
            generateActionKey('comment_added', postId, comment.id);
        final updatedPending = Set<String>.from(state.pendingActions)
          ..add(actionKey);

        // Optimistic: append comment to list & bump count
        final updatedPosts = _updatePostInList(
          postId,
          (p) => p.copyWith(commentsCount: p.commentsCount + 1),
        );
        final updatedSelected = state.selectedPost?.id == postId
            ? state.selectedPost!.copyWith(
                commentsCount: state.selectedPost!.commentsCount + 1)
            : state.selectedPost;

        emit(state.copyWith(
          comments: [...state.comments, comment],
          posts: updatedPosts,
          selectedPost: updatedSelected,
          pendingActions: updatedPending,
        ));
      },
    );
  }

  Future<void> addReply(int postId, int parentCommentId, String text) async {
    emit(state.copyWith(clearError: true));

    final result = await _repository.addReply(
      postId: postId,
      parentCommentId: parentCommentId,
      text: text,
    );

    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (reply) {
        final actionKey =
            generateActionKey('reply_added', postId, reply.id);
        final updatedPending = Set<String>.from(state.pendingActions)
          ..add(actionKey);

        // Convert ReplyEntity to CommentEntity for the nested replies list
        final replyAsComment = CommentEntity(
          id: reply.id,
          postId: reply.postId,
          userId: reply.userId,
          name: reply.name,
          text: reply.text,
          parentCommentId: reply.parentCommentId,
          createdAt: reply.createdAt,
          isOwner: reply.isOwner,
        );

        // Append to parent comment's replies
        final updatedComments = state.comments.map((c) {
          if (c.id != parentCommentId) return c;
          return c.copyWith(replies: [...c.replies, replyAsComment]);
        }).toList();

        emit(state.copyWith(
          comments: updatedComments,
          pendingActions: updatedPending,
        ));
      },
    );
  }

  Future<void> updateComment(int postId, int commentId, String text) async {
    // Snapshot for rollback
    final previousComments = List<CommentEntity>.from(state.comments);

    // Optimistic: update text immediately
    final updatedComments = state.comments.map((c) {
      if (c.id == commentId) return c.copyWith(text: text);
      // Also check nested replies
      final updatedReplies = c.replies.map((r) {
        if (r.id == commentId) return r.copyWith(text: text);
        return r;
      }).toList();
      return c.copyWith(replies: updatedReplies);
    }).toList();

    final actionKey = generateActionKey('comment_updated', postId, commentId);
    final updatedPending = Set<String>.from(state.pendingActions)
      ..add(actionKey);

    emit(state.copyWith(
      comments: updatedComments,
      pendingActions: updatedPending,
      clearError: true,
    ));

    final result = await _repository.updateComment(
      postId: postId,
      commentId: commentId,
      text: text,
    );

    result.fold(
      (failure) {
        // Revert & remove pending key
        final revertedPending = Set<String>.from(state.pendingActions)
          ..remove(actionKey);
        emit(state.copyWith(
          comments: previousComments,
          pendingActions: revertedPending,
          error: failure.message,
        ));
      },
      (_) {/* UI already updated optimistically */},
    );
  }

  Future<void> deleteComment(int postId, int commentId) async {
    // Snapshot for rollback
    final previousComments = List<CommentEntity>.from(state.comments);

    // Optimistic: remove comment or reply
    final updatedComments = state.comments
        .where((c) => c.id != commentId)
        .map((c) {
      final filtered =
          c.replies.where((r) => r.id != commentId).toList();
      return c.copyWith(replies: filtered);
    }).toList();

    final actionKey = generateActionKey('comment_deleted', postId, commentId);
    final updatedPending = Set<String>.from(state.pendingActions)
      ..add(actionKey);

    final updatedPosts = _updatePostInList(
      postId,
      (p) => p.copyWith(
          commentsCount: (p.commentsCount - 1).clamp(0, 999999)),
    );
    final updatedSelected = state.selectedPost?.id == postId
        ? state.selectedPost!.copyWith(
            commentsCount:
                (state.selectedPost!.commentsCount - 1).clamp(0, 999999))
        : state.selectedPost;

    emit(state.copyWith(
      comments: updatedComments,
      posts: updatedPosts,
      selectedPost: updatedSelected,
      pendingActions: updatedPending,
      clearError: true,
    ));

    final result = await _repository.deleteComment(
      postId: postId,
      commentId: commentId,
    );

    result.fold(
      (failure) {
        // Revert everything
        final revertedPending = Set<String>.from(state.pendingActions)
          ..remove(actionKey);
        emit(state.copyWith(
          comments: previousComments,
          posts: state.posts, // will be stale but safe
          pendingActions: revertedPending,
          error: failure.message,
        ));
        // Re-fetch to get correct counts
        fetchPosts(refresh: true);
      },
      (_) {/* UI already updated optimistically */},
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FOLLOW / UNFOLLOW — Optimistic batch-update across all posts by userId
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> followUser(String userId) async {
    // Optimistic: set isFollowedByCurrentUser = true on ALL posts by this user
    final previousPosts = List<PostItem>.from(state.posts);
    final updatedPosts = state.posts
        .map((p) =>
            p.userId == userId ? p.copyWith(isFollowedByCurrentUser: true) : p)
        .toList();
    final updatedSelected =
        state.selectedPost?.userId == userId
            ? state.selectedPost!.copyWith(isFollowedByCurrentUser: true)
            : state.selectedPost;

    emit(state.copyWith(
      posts: updatedPosts,
      selectedPost: updatedSelected,
      clearError: true,
    ));

    final result = await _repository.followUser(userId);

    result.fold(
      (failure) {
        // Revert
        emit(state.copyWith(
          posts: previousPosts,
          selectedPost: state.selectedPost?.userId == userId
              ? state.selectedPost!.copyWith(isFollowedByCurrentUser: false)
              : state.selectedPost,
          error: failure.message,
        ));
      },
      (_) {/* UI already updated optimistically */},
    );
  }

  Future<void> unfollowUser(String userId) async {
    final previousPosts = List<PostItem>.from(state.posts);
    final updatedPosts = state.posts
        .map((p) =>
            p.userId == userId ? p.copyWith(isFollowedByCurrentUser: false) : p)
        .toList();
    final updatedSelected =
        state.selectedPost?.userId == userId
            ? state.selectedPost!.copyWith(isFollowedByCurrentUser: false)
            : state.selectedPost;

    emit(state.copyWith(
      posts: updatedPosts,
      selectedPost: updatedSelected,
      clearError: true,
    ));

    final result = await _repository.unfollowUser(userId);

    result.fold(
      (failure) {
        emit(state.copyWith(
          posts: previousPosts,
          selectedPost: state.selectedPost?.userId == userId
              ? state.selectedPost!.copyWith(isFollowedByCurrentUser: true)
              : state.selectedPost,
          error: failure.message,
        ));
      },
      (_) {/* UI already updated optimistically */},
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REPORT POST — Stub (no backend endpoint yet)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> reportPost(int postId) async {
    emit(state.copyWith(clearError: true, clearSuccessMessage: true));

    final result = await _repository.reportPost(postId);

    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (_) => emit(state.copyWith(
        successMessage: 'تم إرسال البلاغ بنجاح، شكراً لمساعدتك',
      )),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SIGNALR EVENT HANDLERS
  // ═══════════════════════════════════════════════════════════════════════════

  void _onCommentAdded(CommentAddedDto dto) {
    final actionKey = generateActionKey('comment_added', dto.postId, dto.id);
    if (_shouldSkipSignalREvent(actionKey)) return;

    // Build entity from DTO
    final newComment = CommentEntity(
      id: dto.id,
      postId: dto.postId,
      userId: dto.userId,
      name: dto.name,
      text: dto.text,
      createdAt: dto.createdAt,
      isOwner: false, // SignalR events are from OTHER users
    );

    if (state.isInPostDetailsView &&
        state.currentOpenPostId == dto.postId) {
      // User is viewing this post — append the comment
      emit(state.copyWith(
        comments: [...state.comments, newComment],
      ));

      // Update commentsCount on selectedPost
      if (state.selectedPost?.id == dto.postId) {
        emit(state.copyWith(
          selectedPost: state.selectedPost!.copyWith(
            commentsCount: state.selectedPost!.commentsCount + 1,
          ),
        ));
      }
    } else {
      // User is NOT viewing this post — increment unread badge
      final updatedUnreads = Map<int, int>.from(state.unreadCommentCounts);
      updatedUnreads[dto.postId] =
          (updatedUnreads[dto.postId] ?? 0) + 1;
      emit(state.copyWith(unreadCommentCounts: updatedUnreads));
    }

    // Update commentsCount in the feed list
    final updatedPosts = _updatePostInList(
      dto.postId,
      (post) => post.copyWith(commentsCount: post.commentsCount + 1),
    );
    emit(state.copyWith(posts: updatedPosts));
  }

  void _onReplyAdded(ReplyAddedDto dto) {
    final actionKey = generateActionKey('reply_added', dto.postId, dto.id);
    if (_shouldSkipSignalREvent(actionKey)) return;

    if (state.isInPostDetailsView &&
        state.currentOpenPostId == dto.postId) {
      // Find the parent comment and append the reply
      final updatedComments = state.comments.map((comment) {
        if (comment.id != dto.parentCommentId) return comment;
        final newReply = CommentEntity(
          id: dto.id,
          postId: dto.postId,
          userId: dto.userId,
          name: dto.name,
          text: dto.text,
          parentCommentId: dto.parentCommentId,
          createdAt: dto.createdAt,
          isOwner: false,
        );
        return comment.copyWith(
          replies: [...comment.replies, newReply],
        );
      }).toList();

      emit(state.copyWith(comments: updatedComments));
    }
  }

  void _onCommentUpdated(CommentUpdatedDto dto) {
    final actionKey = generateActionKey('comment_updated', dto.postId, dto.id);
    if (_shouldSkipSignalREvent(actionKey)) return;

    if (state.isInPostDetailsView &&
        state.currentOpenPostId == dto.postId) {
      final updatedComments = state.comments.map((comment) {
        if (comment.id == dto.id) {
          return comment.copyWith(text: dto.text, updatedAt: dto.updatedAt);
        }
        // Also check nested replies
        final updatedReplies = comment.replies.map((reply) {
          if (reply.id == dto.id) {
            return reply.copyWith(text: dto.text, updatedAt: dto.updatedAt);
          }
          return reply;
        }).toList();
        return comment.copyWith(replies: updatedReplies);
      }).toList();

      emit(state.copyWith(comments: updatedComments));
    }
  }

  void _onCommentDeleted(CommentDeletedDto dto) {
    final actionKey = generateActionKey('comment_deleted', dto.postId, dto.id);
    if (_shouldSkipSignalREvent(actionKey)) return;

    if (state.isInPostDetailsView &&
        state.currentOpenPostId == dto.postId) {
      // Remove the comment or reply with this ID
      final updatedComments = state.comments
          .where((comment) => comment.id != dto.id)
          .map((comment) {
        final filteredReplies =
            comment.replies.where((reply) => reply.id != dto.id).toList();
        return comment.copyWith(replies: filteredReplies);
      }).toList();

      emit(state.copyWith(comments: updatedComments));

      // Decrement commentsCount on selectedPost
      if (state.selectedPost?.id == dto.postId) {
        emit(state.copyWith(
          selectedPost: state.selectedPost!.copyWith(
            commentsCount:
                (state.selectedPost!.commentsCount - 1).clamp(0, 999999),
          ),
        ));
      }
    }

    // Decrement in feed list
    final updatedPosts = _updatePostInList(
      dto.postId,
      (post) => post.copyWith(
        commentsCount: (post.commentsCount - 1).clamp(0, 999999),
      ),
    );
    emit(state.copyWith(posts: updatedPosts));
  }

  void _onReactionUpdated(ReactionUpdatedDto dto) {
    final actionKey =
        generateActionKey('reaction_updated', dto.postId, dto.userId);
    if (_shouldSkipSignalREvent(actionKey)) return;

    // Update in feed list
    final updatedPosts = _updatePostInList(
      dto.postId,
      (post) => post.copyWith(
        likesCount: dto.likesCount,
        dislikesCount: dto.dislikesCount,
      ),
    );

    // Update selectedPost if viewing
    PostItem? updatedSelected = state.selectedPost;
    if (state.selectedPost?.id == dto.postId) {
      updatedSelected = state.selectedPost!.copyWith(
        likesCount: dto.likesCount,
        dislikesCount: dto.dislikesCount,
      );
    }

    emit(state.copyWith(
      posts: updatedPosts,
      selectedPost: updatedSelected,
    ));
  }

  void _onReconnected() {
    debugPrint('PostFeedCubit: reconnected — re-joining post if needed');
    // Re-join the currently open post if the user was viewing one
    if (state.isInPostDetailsView && state.currentOpenPostId != null) {
      _hubService.joinPost(state.currentOpenPostId!);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Update a single PostItem in the feed list by its [postId].
  List<PostItem> _updatePostInList(
    int postId,
    PostItem Function(PostItem) updater,
  ) {
    return state.posts.map((post) {
      if (post.id != postId) return post;
      return updater(post);
    }).toList();
  }

  void clearError() => emit(state.copyWith(clearError: true));

  void clearSuccessMessage() =>
      emit(state.copyWith(clearSuccessMessage: true));
}
