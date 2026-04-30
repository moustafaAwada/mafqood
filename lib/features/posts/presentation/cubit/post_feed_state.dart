import 'package:equatable/equatable.dart';
import 'package:mafqood/features/posts/domain/entities/post_entities.dart';

class PostFeedState extends Equatable {
  // ─── Feed ─────────────────────────────────────────────────────────────
  final List<PostItem> posts;
  final bool isLoadingPosts;
  final bool isRefreshing;
  final bool hasMorePosts;
  final int currentPage;
  final String searchQuery;
  final PostType? typeFilter;

  // ─── Post Details ─────────────────────────────────────────────────────
  final PostItem? selectedPost;
  final bool isLoadingDetails;

  // ─── Comments ─────────────────────────────────────────────────────────
  final List<CommentEntity> comments;
  final bool isLoadingComments;
  final bool hasMoreComments;
  final int commentsPage;

  // ─── Real-time / Interaction Context ──────────────────────────────────
  /// The post currently open in PostDetailsPage (for SignalR join/leave).
  final int? currentOpenPostId;

  /// Whether the user is currently inside the PostDetailsPage view.
  final bool isInPostDetailsView;

  /// Tracks action keys for HTTP→SignalR deduplication.
  /// When the Cubit performs a REST action (e.g. addComment), it generates a
  /// key like "comment_added:postId:commentId" and adds it here. When the
  /// corresponding SignalR event fires, the handler checks this set — if
  /// found, it removes the key and skips the duplicate UI update.
  final Set<String> pendingActions;

  /// Tracks unread comment counts per postId for badge display on post cards
  /// when the user is NOT inside that post's details view.
  final Map<int, int> unreadCommentCounts;

  // ─── Feedback ─────────────────────────────────────────────────────────
  final String? error;
  final String? successMessage;

  const PostFeedState({
    this.posts = const [],
    this.isLoadingPosts = false,
    this.isRefreshing = false,
    this.hasMorePosts = true,
    this.currentPage = 1,
    this.searchQuery = '',
    this.typeFilter,
    this.selectedPost,
    this.isLoadingDetails = false,
    this.comments = const [],
    this.isLoadingComments = false,
    this.hasMoreComments = true,
    this.commentsPage = 1,
    this.currentOpenPostId,
    this.isInPostDetailsView = false,
    this.pendingActions = const {},
    this.unreadCommentCounts = const {},
    this.error,
    this.successMessage,
  });

  PostFeedState copyWith({
    // Feed
    List<PostItem>? posts,
    bool? isLoadingPosts,
    bool? isRefreshing,
    bool? hasMorePosts,
    int? currentPage,
    String? searchQuery,
    PostType? typeFilter,
    bool clearTypeFilter = false,
    // Details
    PostItem? selectedPost,
    bool clearSelectedPost = false,
    bool? isLoadingDetails,
    // Comments
    List<CommentEntity>? comments,
    bool? isLoadingComments,
    bool? hasMoreComments,
    int? commentsPage,
    // Real-time context
    int? currentOpenPostId,
    bool clearCurrentOpenPostId = false,
    bool? isInPostDetailsView,
    Set<String>? pendingActions,
    Map<int, int>? unreadCommentCounts,
    // Feedback
    String? error,
    bool clearError = false,
    String? successMessage,
    bool clearSuccessMessage = false,
  }) {
    return PostFeedState(
      posts: posts ?? this.posts,
      isLoadingPosts: isLoadingPosts ?? this.isLoadingPosts,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasMorePosts: hasMorePosts ?? this.hasMorePosts,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
      typeFilter: clearTypeFilter ? null : (typeFilter ?? this.typeFilter),
      selectedPost:
          clearSelectedPost ? null : (selectedPost ?? this.selectedPost),
      isLoadingDetails: isLoadingDetails ?? this.isLoadingDetails,
      comments: comments ?? this.comments,
      isLoadingComments: isLoadingComments ?? this.isLoadingComments,
      hasMoreComments: hasMoreComments ?? this.hasMoreComments,
      commentsPage: commentsPage ?? this.commentsPage,
      currentOpenPostId: clearCurrentOpenPostId
          ? null
          : (currentOpenPostId ?? this.currentOpenPostId),
      isInPostDetailsView: isInPostDetailsView ?? this.isInPostDetailsView,
      pendingActions: pendingActions ?? this.pendingActions,
      unreadCommentCounts: unreadCommentCounts ?? this.unreadCommentCounts,
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccessMessage
          ? null
          : (successMessage ?? this.successMessage),
    );
  }

  /// Client-side filtered posts for local search display.
  List<PostItem> get filteredPosts {
    if (searchQuery.trim().isEmpty) return posts;
    final q = searchQuery.toLowerCase();
    return posts.where((p) {
      final name = (p.userName ?? '').toLowerCase();
      final description = (p.description ?? '').toLowerCase();
      return name.contains(q) || description.contains(q);
    }).toList();
  }

  @override
  List<Object?> get props => [
        posts,
        isLoadingPosts,
        isRefreshing,
        hasMorePosts,
        currentPage,
        searchQuery,
        typeFilter,
        selectedPost,
        isLoadingDetails,
        comments,
        isLoadingComments,
        hasMoreComments,
        commentsPage,
        currentOpenPostId,
        isInPostDetailsView,
        pendingActions,
        unreadCommentCounts,
        error,
        successMessage,
      ];
}
