class PostInteractionStateModel {
  int? currentOpenPostId;
  bool isInPostDetailsView;
  final Set<String> pendingActions;
  final Map<int, int> unreadCommentCounts;

  PostInteractionStateModel({
    this.currentOpenPostId,
    this.isInPostDetailsView = false,
    Set<String>? pendingActions,
    Map<int, int>? unreadCommentCounts,
  })  : pendingActions = pendingActions ?? <String>{},
        unreadCommentCounts = unreadCommentCounts ?? <int, int>{};

  bool shouldApplyRealtimeUpdate(int postId) =>
      isInPostDetailsView && currentOpenPostId == postId;
}

