import 'package:flutter/material.dart';
import 'package:mafqood/constants.dart';

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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F7FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'التعليقات ($_totalCommentCount)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      Navigator.pop(context, _totalCommentCount),
                  child: const Icon(Icons.close, color: Colors.black54),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Comments list
          Expanded(
            child: _comments.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 48, color: Colors.black26),
                        SizedBox(height: 8),
                        Text(
                          'لا توجد تعليقات بعد',
                          style: TextStyle(color: Colors.black45),
                        ),
                        Text(
                          'كن أول من يعلق!',
                          style:
                              TextStyle(color: Colors.black38, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: kPrimaryColor.withOpacity(0.08),
              child: Row(
                children: [
                  const Icon(Icons.reply, size: 16, color: kPrimaryColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'الرد على ${_replyingTo!.userName}',
                      style: const TextStyle(
                        color: kPrimaryColor,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _cancelReply,
                    child: const Icon(Icons.close,
                        size: 16, color: kPrimaryColor),
                  ),
                ],
              ),
            ),

          // Input field
          Container(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 8,
              bottom: bottomInset + 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: kPrimaryColor,
                  child:
                      Text('أ', style: TextStyle(color: Colors.white, fontSize: 14)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    focusNode: _focusNode,
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      hintText: _replyingTo != null
                          ? 'اكتب ردك...'
                          : 'اكتب تعليقك...',
                      hintStyle: const TextStyle(
                          color: Colors.black38, fontSize: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (_) => _addComment(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _addComment,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: kPrimaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send,
                        color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
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
    final comment = widget.comment;
    final hasReplies = comment.replies.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main comment
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: kPrimaryColor.withOpacity(0.15),
                child: Text(
                  comment.userName.isNotEmpty ? comment.userName[0] : '?',
                  style: const TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + time
                    Row(
                      children: [
                        Text(
                          comment.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.timeAgo(comment.createdAt),
                          style: const TextStyle(
                            color: Colors.black38,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Comment text
                    Text(
                      comment.text,
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    // Reply button
                    GestureDetector(
                      onTap: () => widget.onReply(comment),
                      child: const Text(
                        'رد',
                        style: TextStyle(
                          color: kPrimaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
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
                padding: const EdgeInsets.only(right: 40, top: 6),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 1,
                      color: Colors.black26,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _showReplies
                          ? 'إخفاء الردود'
                          : 'عرض ${comment.replies.length} ${comment.replies.length == 1 ? "رد" : "ردود"}',
                      style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Replies list
          if (hasReplies && _showReplies)
            Padding(
              padding: const EdgeInsets.only(right: 40, top: 8),
              child: Column(
                children: comment.replies.map((reply) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor:
                              kPrimaryColor.withOpacity(0.1),
                          child: Text(
                            reply.userName.isNotEmpty
                                ? reply.userName[0]
                                : '?',
                            style: const TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    reply.userName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.timeAgo(reply.createdAt),
                                    style: const TextStyle(
                                      color: Colors.black38,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                reply.text,
                                style: const TextStyle(fontSize: 12),
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
