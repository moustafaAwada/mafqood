import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mafqood/features/home/presentation/widgets/post_action.dart';
import 'package:mafqood/features/home/presentation/widgets/post_menu_widget.dart';
import 'package:mafqood/features/posts/domain/entities/post_entities.dart';
import 'package:mafqood/features/posts/presentation/cubit/post_feed_cubit.dart';

class PostCard extends StatefulWidget {
  final PostItem post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with TickerProviderStateMixin {
  late AnimationController _elevationController;
  late Animation<double> _elevationAnimation;

  PostItem get post => widget.post;

  @override
  void initState() {
    super.initState();
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

  void _openPostDetails() {
    Navigator.pushNamed(context, '/post-details', arguments: post.id);
  }

  void _navigateToProfile() {
    Navigator.pushNamed(context, '/user-profile', arguments: post.userId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cubit = context.read<PostFeedCubit>();

    final isLiked = post.userReactType == ReactType.like;
    final isDisliked = post.userReactType == ReactType.dislike;
    final statusLabel = post.type == PostType.lost ? 'مفقود' : 'موجود';
    final statusColor = post.type == PostType.lost
        ? const Color(0xFFFF5252)
        : const Color(0xFF4CAF50);

    return GestureDetector(
      onTap: _openPostDetails,
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
              // ── Header: Avatar + Name + Status + Menu ──
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 12, 12, 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _navigateToProfile,
                      child: post.userProfilePictureUrl != null
                          ? CachedNetworkImage(
                              imageUrl: post.userProfilePictureUrl!,
                              imageBuilder: (_, imageProvider) => CircleAvatar(
                                radius: 20,
                                backgroundImage: imageProvider,
                              ),
                              placeholder: (_, __) => CircleAvatar(
                                radius: 20,
                                backgroundColor: colorScheme.primaryContainer,
                                child: const SizedBox(
                                  width: 16, height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                              errorWidget: (_, __, ___) => CircleAvatar(
                                radius: 20,
                                backgroundColor: colorScheme.primaryContainer,
                                child: Text(
                                  (post.userName ?? '?')[0],
                                  style: TextStyle(
                                    color: colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          : CircleAvatar(
                              radius: 20,
                              backgroundColor: colorScheme.primaryContainer,
                              child: Text(
                                (post.userName ?? '?')[0],
                                style: TextStyle(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: _navigateToProfile,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.userName ?? 'مستخدم',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                                fontSize: 15,
                              ),
                            ),
                            if (post.description != null &&
                                post.description!.isNotEmpty)
                              Text(
                                post.description!,
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
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: statusColor.withOpacity(0.2)),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    PostMenuWidget(post: post),
                  ],
                ),
              ),

              if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: post.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                      placeholder: (_, __) => Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      ),
                      errorWidget: (_, __, ___) => Center(
                        child: Icon(Icons.broken_image_outlined,
                            size: 50, color: colorScheme.onSurface.withOpacity(0.3)),
                      ),
                    ),
                  ),
                ),

              // ── Action bar ──
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        PostAction(
                          icon: isLiked
                              ? Icons.thumb_up
                              : Icons.thumb_up_alt_outlined,
                          count: post.likesCount,
                          isActive: isLiked,
                          activeColor: colorScheme.primary,
                          onTap: () => cubit.toggleReact(
                            postId: post.id,
                            reactType: ReactType.like,
                          ),
                        ),
                        const SizedBox(width: 20),
                        PostAction(
                          icon: isDisliked
                              ? Icons.thumb_down
                              : Icons.thumb_down_alt_outlined,
                          count: post.dislikesCount,
                          isActive: isDisliked,
                          activeColor: const Color(0xFFFF5252),
                          onTap: () => cubit.toggleReact(
                            postId: post.id,
                            reactType: ReactType.dislike,
                          ),
                        ),
                        const SizedBox(width: 20),
                        PostAction(
                          icon: Icons.chat_bubble_outline,
                          count: post.commentsCount,
                          isActive: false,
                          activeColor:
                              colorScheme.onSurface.withOpacity(0.7),
                          onTap: _openPostDetails,
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () => cubit.toggleSave(
                            postId: post.id,
                            isSaved: post.isSaved,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                post.isSaved
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                size: 18,
                                color: post.isSaved
                                    ? colorScheme.primary
                                    : colorScheme.onSurface.withOpacity(0.5),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'حفظ',
                                style: TextStyle(
                                  color: post.isSaved
                                      ? colorScheme.primary
                                      : colorScheme.onSurface
                                          .withOpacity(0.7),
                                  fontWeight: post.isSaved
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
