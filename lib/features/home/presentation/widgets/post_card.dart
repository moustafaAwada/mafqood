import 'package:flutter/material.dart';
import 'package:mafqood/features/home/presentation/widgets/comments_bottom_sheet.dart';
import 'package:mafqood/features/home/presentation/widgets/post_action.dart';
import 'package:mafqood/features/posts/domain/entities/post_entities.dart';

class PostCard extends StatefulWidget {
  final int postId;
  final String statusLabel;
  final Color statusColor;
  final String name;
  final String subtitle;
  final int initialLikes;
  final int initialDislikes;
  final int initialComments;
  final bool initialIsSaved;
  final ReactType? initialReactType;
  final ValueChanged<ReactType>? onReact;
  final ValueChanged<bool>? onToggleSave;

  const PostCard({
    super.key,
    required this.postId,
    required this.statusLabel,
    required this.statusColor,
    required this.name,
    required this.subtitle,
    this.initialLikes = 0,
    this.initialDislikes = 0,
    this.initialComments = 0,
    this.initialIsSaved = false,
    this.initialReactType,
    this.onReact,
    this.onToggleSave,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with TickerProviderStateMixin {
  late int _likes;
  late int _dislikes;
  late int _comments;
  bool _isLiked = false;
  bool _isDisliked = false;
  bool _isSaved = false;
  final List<Comment> _commentsList = [];

  late AnimationController _elevationController;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _likes = widget.initialLikes;
    _dislikes = widget.initialDislikes;
    _comments = widget.initialComments;
    _isLiked = widget.initialReactType == ReactType.like;
    _isDisliked = widget.initialReactType == ReactType.dislike;
    _isSaved = widget.initialIsSaved;

    _elevationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _elevationAnimation = Tween<double>(begin: 4, end: 8).animate(
      CurvedAnimation(parent: _elevationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _elevationController.dispose();
    super.dispose();
  }

  void _openComments() async {
    final result = await showCommentsBottomSheet(
      context,
      comments: _commentsList,
    );
    if (result != null) {
      setState(() {
        _comments = result;
      });
    }
  }

  void _toggleLike() {
    widget.onReact?.call(ReactType.like);
  }

  void _toggleDislike() {
    widget.onReact?.call(ReactType.dislike);
  }

  void _toggleSave() {
    widget.onToggleSave?.call(_isSaved);
  }

  @override
  void didUpdateWidget(covariant PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialLikes != widget.initialLikes ||
        oldWidget.initialDislikes != widget.initialDislikes ||
        oldWidget.initialComments != widget.initialComments ||
        oldWidget.initialIsSaved != widget.initialIsSaved ||
        oldWidget.initialReactType != widget.initialReactType) {
      _likes = widget.initialLikes;
      _dislikes = widget.initialDislikes;
      _comments = widget.initialComments;
      _isSaved = widget.initialIsSaved;
      _isLiked = widget.initialReactType == ReactType.like;
      _isDisliked = widget.initialReactType == ReactType.dislike;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTapDown: (_) => _elevationController.forward(),
      onTapUp: (_) => _elevationController.reverse(),
      onTapCancel: () => _elevationController.reverse(),
      child: AnimatedBuilder(
        animation: _elevationAnimation,
        builder: (context, child) => Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: _elevationAnimation.value,
                offset: Offset(0, _elevationAnimation.value / 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Text(
                        widget.name[0],
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            widget.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: widget.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: widget.statusColor.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        widget.statusLabel,
                        style: TextStyle(
                          color: widget.statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Image placeholder with shimmer effect
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.surfaceContainerHighest.withOpacity(
                                0.3,
                              ),
                              colorScheme.surfaceContainerHighest.withOpacity(
                                0.6,
                              ),
                              colorScheme.surfaceContainerHighest.withOpacity(
                                0.3,
                              ),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 50,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        PostAction(
                          icon: _isLiked
                              ? Icons.thumb_up
                              : Icons.thumb_up_alt_outlined,
                          count: _likes,
                          isActive: _isLiked,
                          activeColor: colorScheme.primary,
                          onTap: _toggleLike,
                        ),
                        const SizedBox(width: 20),
                        PostAction(
                          icon: _isDisliked
                              ? Icons.thumb_down
                              : Icons.thumb_down_alt_outlined,
                          count: _dislikes,
                          isActive: _isDisliked,
                          activeColor: const Color(0xFFFF5252),
                          onTap: _toggleDislike,
                        ),
                        const SizedBox(width: 20),
                        PostAction(
                          icon: Icons.chat_bubble_outline,
                          count: _comments,
                          isActive: false,
                          activeColor: colorScheme.onSurface.withOpacity(0.7),
                          onTap: _openComments,
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: _toggleSave,
                          child: Row(
                            children: [
                              Icon(
                                _isSaved
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                size: 18,
                                color: _isSaved
                                    ? colorScheme.primary
                                    : colorScheme.onSurface.withOpacity(0.5),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'حفظ',
                                style: TextStyle(
                                  color: _isSaved
                                      ? colorScheme.primary
                                      : colorScheme.onSurface.withOpacity(0.7),
                                  fontWeight: _isSaved
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.share_outlined,
                        color: colorScheme.onSurface.withOpacity(0.5),
                        size: 20,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
