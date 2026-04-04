import 'package:flutter/material.dart';

/// Model for a comment (supports nested replies)
class Comment {
  final String id;
  final String userName;
  final String text;
  final DateTime createdAt;
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.userName,
    required this.text,
    required this.createdAt,
    List<Comment>? replies,
  }) : replies = replies ?? [];
}

/// Shows the comments bottom sheet and returns the updated comment count
Future<int?> showCommentsBottomSheet(
  BuildContext context, {
  required List<Comment> comments,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => CommentsBottomSheet(comments: comments),
  );
}

class CommentsBottomSheet extends StatefulWidget {
  final List<Comment> comments;

  const CommentsBottomSheet({super.key, required this.comments});

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final _commentController = TextEditingController();
  final _focusNode = FocusNode();
  late List<Comment> _comments;

  /// If not null, the user is replying to this comment
  Comment? _replyingTo;

  @override
  void initState() {
    super.initState();
    _comments = List.from(widget.comments);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  int get _totalCommentCount {
    int count = 0;
    for (final c in _comments) {
      count += 1 + c.replies.length;
    }
    return count;
  }

  void _addComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      final newComment = Comment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userName: 'أنا',
        text: text,
        createdAt: DateTime.now(),
      );

      if (_replyingTo != null) {
        _replyingTo!.replies.add(newComment);
        _replyingTo = null;
      } else {
        _comments.add(newComment);
      }

      _commentController.clear();
      _focusNode.unfocus();
    });
  }

  void _startReply(Comment comment) {
    setState(() {
      _replyingTo = comment;
    });
    _focusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyingTo = null;
    });
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} د';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} س';
    return 'منذ ${diff.inDays} ي';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
    
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'التعليقات ($_totalCommentCount)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
                    onPressed: () => Navigator.pop(context, _totalCommentCount),
                  ),
                ],
              ),
            ),
    
            Divider(height: 1, color: theme.dividerColor.withOpacity(0.1)),
    
            // Comments list
            Expanded(
              child: _comments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chat_bubble_outline,
                              size: 60, color: colorScheme.primary.withOpacity(0.15)),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد تعليقات بعد',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'كن أول من يشارك في هذا النقاش',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        return _CommentTile(
                          comment: _comments[index],
                          onReply: _startReply,
                          timeAgo: _timeAgo,
                        );
                      },
                    ),
            ),
    
            // Reply indicator
            if (_replyingTo != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.05),
                  border: Border(top: BorderSide(color: colorScheme.primary.withOpacity(0.1))),
                ),
                child: Row(
                  children: [
                    Icon(Icons.reply, size: 16, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                          children: [
                            const TextSpan(text: 'الرد على '),
                            TextSpan(
                              text: _replyingTo!.userName,
                              style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _cancelReply,
                      child: Icon(Icons.close, size: 18, color: colorScheme.primary),
                    ),
                  ],
                ),
              ),
    
            // Input field
            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: bottomInset + 16,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(top: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      'أ',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _commentController,
                        focusNode: _focusNode,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: _replyingTo != null ? 'اكتب ردك...' : 'اكتب تعليقك...',
                          hintStyle: TextStyle(
                            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        onSubmitted: (_) => _addComment(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _addComment,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: colorScheme.primary,
                      child: Icon(Icons.send, color: colorScheme.onPrimary, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single comment tile with its replies
class _CommentTile extends StatefulWidget {
  final Comment comment;
  final void Function(Comment) onReply;
  final String Function(DateTime) timeAgo;

  const _CommentTile({
    required this.comment,
    required this.onReply,
    required this.timeAgo,
  });

  @override
  State<_CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<_CommentTile> {
  bool _showReplies = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final comment = widget.comment;
    final hasReplies = comment.replies.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main comment
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: colorScheme.primary.withOpacity(0.1),
                child: Text(
                  comment.userName.isNotEmpty ? comment.userName[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + time
                    Row(
                      children: [
                        Text(
                          comment.userName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.timeAgo(comment.createdAt),
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Comment text
                    Text(
                      comment.text,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface.withOpacity(0.9),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Reply button
                    GestureDetector(
                      onTap: () => widget.onReply(comment),
                      child: Text(
                        'رد',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Toggle replies
          if (hasReplies)
            GestureDetector(
              onTap: () {
                setState(() {
                  _showReplies = !_showReplies;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 48, top: 12),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 1,
                      color: colorScheme.primary.withOpacity(0.2),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _showReplies
                          ? 'إخفاء الردود'
                          : 'عرض ${comment.replies.length} ${comment.replies.length == 1 ? "رد" : "ردود"}',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Replies list
          if (hasReplies && _showReplies)
            Padding(
              padding: const EdgeInsets.only(right: 48, top: 16),
              child: Column(
                children: comment.replies.map((reply) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: colorScheme.secondary.withOpacity(0.1),
                          child: Text(
                            reply.userName.isNotEmpty ? reply.userName[0].toUpperCase() : '?',
                            style: TextStyle(
                              color: colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    reply.userName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.timeAgo(reply.createdAt),
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                reply.text,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colorScheme.onSurface.withOpacity(0.8),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
