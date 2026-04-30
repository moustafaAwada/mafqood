import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mafqood/features/home/presentation/widgets/post_menu_widget.dart';
import 'package:mafqood/features/posts/domain/entities/post_entities.dart';
import 'package:mafqood/features/posts/presentation/cubit/post_feed_cubit.dart';
import 'package:mafqood/features/posts/presentation/cubit/post_feed_state.dart';

class PostDetailsPage extends StatefulWidget {
  final int postId;
  const PostDetailsPage({super.key, required this.postId});

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();
  int? _replyingToCommentId;
  String? _replyingToName;

  @override
  void initState() {
    super.initState();
    context.read<PostFeedCubit>().openPostDetails(widget.postId);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    context.read<PostFeedCubit>().closePostDetails();
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<PostFeedCubit>().loadMoreComments(widget.postId);
    }
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    final cubit = context.read<PostFeedCubit>();

    if (_replyingToCommentId != null) {
      cubit.addReply(widget.postId, _replyingToCommentId!, text);
    } else {
      cubit.addComment(widget.postId, text);
    }
    _commentController.clear();
    setState(() {
      _replyingToCommentId = null;
      _replyingToName = null;
    });
  }

  void _startReply(int commentId, String name) {
    setState(() {
      _replyingToCommentId = commentId;
      _replyingToName = name;
    });
    FocusScope.of(context).requestFocus(FocusNode());
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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocBuilder<PostFeedCubit, PostFeedState>(
        builder: (context, state) {
          final post = state.selectedPost;

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: colorScheme.primary,
              title: Text('تفاصيل المنشور',
                  style: TextStyle(color: colorScheme.onPrimary)),
              iconTheme: IconThemeData(color: colorScheme.onPrimary),
              actions: [
                if (post != null) PostMenuWidget(post: post),
              ],
            ),
            body: state.isLoadingDetails && post == null
                ? const Center(child: CircularProgressIndicator())
                : post == null
                    ? Center(
                        child: Text('لم يتم العثور على المنشور',
                            style: TextStyle(color: colorScheme.onSurface)))
                    : Column(
                        children: [
                          // ── Scrollable content ──
                          Expanded(
                            child: ListView(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              children: [
                                _buildPostHeader(post, colorScheme),
                                if (post.imageUrl != null) ...[
                                  const SizedBox(height: 12),
                                  _buildImage(post, colorScheme),
                                ],
                                if (post.description != null) ...[
                                  const SizedBox(height: 12),
                                  Text(post.description!,
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: colorScheme.onSurface,
                                          height: 1.6)),
                                ],
                                const SizedBox(height: 16),
                                _buildReactionBar(post, colorScheme),
                                Divider(
                                    height: 32,
                                    color:
                                        theme.dividerColor.withOpacity(0.1)),
                                // Comments header
                                Text(
                                  'التعليقات (${state.comments.length})',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Comments list
                                if (state.isLoadingComments &&
                                    state.comments.isEmpty)
                                  const Center(
                                      child: Padding(
                                    padding: EdgeInsets.all(24),
                                    child: CircularProgressIndicator(),
                                  ))
                                else if (state.comments.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Center(
                                      child: Text('لا توجد تعليقات بعد',
                                          style: TextStyle(
                                              color: colorScheme
                                                  .onSurfaceVariant)),
                                    ),
                                  )
                                else
                                  ...state.comments.map((c) =>
                                      _buildCommentTile(c, colorScheme)),
                                if (state.isLoadingComments &&
                                    state.comments.isNotEmpty)
                                  const Center(
                                      child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )),
                              ],
                            ),
                          ),
                          // ── Reply indicator ──
                          if (_replyingToCommentId != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              color: colorScheme.primary.withOpacity(0.05),
                              child: Row(
                                children: [
                                  Icon(Icons.reply,
                                      size: 16, color: colorScheme.primary),
                                  const SizedBox(width: 8),
                                  Text('الرد على $_replyingToName',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: colorScheme.primary)),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () => setState(() {
                                      _replyingToCommentId = null;
                                      _replyingToName = null;
                                    }),
                                    child: Icon(Icons.close,
                                        size: 18,
                                        color: colorScheme.primary),
                                  ),
                                ],
                              ),
                            ),
                          // ── Input field ──
                          _buildInputField(colorScheme, theme),
                        ],
                      ),
          );
        },
      ),
    );
  }

  Widget _buildPostHeader(PostItem post, ColorScheme cs) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/user-profile',
              arguments: post.userId),
          child: post.userProfilePictureUrl != null
              ? CachedNetworkImage(
                  imageUrl: post.userProfilePictureUrl!,
                  imageBuilder: (_, imageProvider) => CircleAvatar(
                    radius: 22,
                    backgroundImage: imageProvider,
                  ),
                  placeholder: (_, __) => CircleAvatar(
                    radius: 22,
                    backgroundColor: cs.primaryContainer,
                    child: const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (_, __, ___) => CircleAvatar(
                    radius: 22,
                    backgroundColor: cs.primaryContainer,
                    child: Text((post.userName ?? '?')[0],
                        style: TextStyle(
                            color: cs.onPrimaryContainer,
                            fontWeight: FontWeight.bold)),
                  ),
                )
              : CircleAvatar(
                  radius: 22,
                  backgroundColor: cs.primaryContainer,
                  child: Text((post.userName ?? '?')[0],
                      style: TextStyle(
                          color: cs.onPrimaryContainer,
                          fontWeight: FontWeight.bold)),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/user-profile',
                arguments: post.userId),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.userName ?? 'مستخدم',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                        fontSize: 16)),
                Text(_timeAgo(post.createdAt),
                    style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant.withOpacity(0.6))),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: (post.type == PostType.lost
                    ? const Color(0xFFFF5252)
                    : const Color(0xFF4CAF50))
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            post.type == PostType.lost ? 'مفقود' : 'موجود',
            style: TextStyle(
              color: post.type == PostType.lost
                  ? const Color(0xFFFF5252)
                  : const Color(0xFF4CAF50),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImage(PostItem post, ColorScheme cs) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: post.imageUrl!,
        height: 250,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          height: 250,
          color: cs.surfaceContainerHighest.withOpacity(0.3),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2, color: cs.primary),
          ),
        ),
        errorWidget: (_, __, ___) => Container(
          height: 250,
          color: cs.surfaceContainerHighest.withOpacity(0.3),
          child: const Center(
              child: Icon(Icons.broken_image_outlined,
                  size: 50, color: Colors.white54)),
        ),
      ),
    );
  }

  Widget _buildReactionBar(PostItem post, ColorScheme cs) {
    final cubit = context.read<PostFeedCubit>();
    final isLiked = post.userReactType == ReactType.like;
    final isDisliked = post.userReactType == ReactType.dislike;

    return Row(
      children: [
        _reactionChip(
          icon: isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
          label: '${post.likesCount}',
          active: isLiked,
          color: cs.primary,
          onTap: () =>
              cubit.toggleReact(postId: post.id, reactType: ReactType.like),
        ),
        const SizedBox(width: 12),
        _reactionChip(
          icon:
              isDisliked ? Icons.thumb_down : Icons.thumb_down_alt_outlined,
          label: '${post.dislikesCount}',
          active: isDisliked,
          color: const Color(0xFFFF5252),
          onTap: () => cubit.toggleReact(
              postId: post.id, reactType: ReactType.dislike),
        ),
        const SizedBox(width: 12),
        _reactionChip(
          icon: Icons.chat_bubble_outline,
          label: '${post.commentsCount}',
          active: false,
          color: cs.onSurfaceVariant,
          onTap: null,
        ),
        const Spacer(),
        GestureDetector(
          onTap: () =>
              cubit.toggleSave(postId: post.id, isSaved: post.isSaved),
          child: Icon(
            post.isSaved ? Icons.bookmark : Icons.bookmark_border,
            color: post.isSaved ? cs.primary : cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _reactionChip({
    required IconData icon,
    required String label,
    required bool active,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: active ? color : color.withOpacity(0.5)),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: active ? color : color.withOpacity(0.7),
                  fontWeight: active ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildCommentTile(CommentEntity comment, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/user-profile', arguments: comment.userId),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: cs.primary.withOpacity(0.1),
                  child: Text(
                    (comment.name ?? '?')[0].toUpperCase(),
                    style: TextStyle(
                        color: cs.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
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
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/user-profile', arguments: comment.userId),
                          child: Text(comment.name ?? 'مستخدم',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: cs.onSurface)),
                        ),
                        const SizedBox(width: 8),
                        Text(_timeAgo(comment.createdAt),
                            style: TextStyle(
                                fontSize: 11,
                                color:
                                    cs.onSurfaceVariant.withOpacity(0.5))),
                        if (comment.isOwner) ...[
                          const SizedBox(width: 8),
                          _ownerCommentActions(comment, cs),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(comment.text,
                        style: TextStyle(
                            fontSize: 14,
                            color: cs.onSurface.withOpacity(0.9),
                            height: 1.4)),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () =>
                          _startReply(comment.id, comment.name ?? 'مستخدم'),
                      child: Text('رد',
                          style: TextStyle(
                              color: cs.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Nested replies
          if (comment.replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 42, top: 8),
              child: Column(
                children: comment.replies
                    .map((r) => _buildReplyTile(r, cs))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _ownerCommentActions(CommentEntity comment, ColorScheme cs) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: Icon(Icons.more_horiz, size: 16, color: cs.onSurfaceVariant),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (value) {
        if (value == 'delete') {
          context
              .read<PostFeedCubit>()
              .deleteComment(widget.postId, comment.id);
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              const Icon(Icons.delete_outline, size: 18, color: Color(0xFFFF5252)),
              const SizedBox(width: 8),
              Text('حذف', style: TextStyle(color: cs.onSurface, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReplyTile(CommentEntity reply, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/user-profile', arguments: reply.userId),
            child: CircleAvatar(
              radius: 12,
              backgroundColor: cs.secondary.withOpacity(0.1),
              child: Text(
                (reply.name ?? '?')[0].toUpperCase(),
                style: TextStyle(
                    color: cs.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/user-profile', arguments: reply.userId),
                      child: Text(reply.name ?? 'مستخدم',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: cs.onSurface)),
                    ),
                    const SizedBox(width: 6),
                    Text(_timeAgo(reply.createdAt),
                        style: TextStyle(
                            fontSize: 10,
                            color: cs.onSurfaceVariant.withOpacity(0.5))),
                  ],
                ),
                const SizedBox(height: 2),
                Text(reply.text,
                    style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurface.withOpacity(0.8),
                        height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(ColorScheme cs, ThemeData theme) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.only(
          left: 16, right: 16, top: 12, bottom: bottomInset + 16),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
            top: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _commentController,
                textDirection: TextDirection.rtl,
                style: TextStyle(color: cs.onSurface, fontSize: 14),
                decoration: InputDecoration(
                  hintText: _replyingToCommentId != null
                      ? 'اكتب ردك...'
                      : 'اكتب تعليقك...',
                  hintStyle: TextStyle(
                      color: cs.onSurfaceVariant.withOpacity(0.5),
                      fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _submitComment(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _submitComment,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: cs.primary,
              child: Icon(Icons.send, color: cs.onPrimary, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
