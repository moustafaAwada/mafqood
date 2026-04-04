import 'package:flutter/material.dart';
import 'package:mafqood/features/home/presentation/widgets/comments_bottom_sheet.dart';
import 'package:mafqood/features/home/presentation/widgets/post_action.dart';

class PostCard extends StatefulWidget {
  final String statusLabel;
  final Color statusColor;
  final String name;
  final String subtitle;

  const PostCard({
    super.key,
    required this.statusLabel,
    required this.statusColor,
    required this.name,
    required this.subtitle,
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
    _likes = 0;
    _dislikes = 0;
    _comments = 0;

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
    setState(() {
      if (_isLiked) {
        _isLiked = false;
        _likes--;
      } else {
        _isLiked = true;
        _likes++;
        if (_isDisliked) {
          _isDisliked = false;
          _dislikes--;
        }
      }
    });
  }

  void _toggleDislike() {
    setState(() {
      if (_isDisliked) {
        _isDisliked = false;
        _dislikes--;
      } else {
        _isDisliked = true;
        _dislikes++;
        if (_isLiked) {
          _isLiked = false;
          _likes--;
        }
      }
    });
  }

  void _toggleSave() {
    setState(() => _isSaved = !_isSaved);
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
