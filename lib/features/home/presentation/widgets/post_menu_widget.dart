import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mafqood/features/posts/domain/entities/post_entities.dart';
import 'package:mafqood/features/posts/presentation/cubit/post_feed_cubit.dart';

/// The 3-dots menu for a post card.
///
/// - **Owner:** Edit, Delete
/// - **Non-owner:** Save/Unsave, Follow/Unfollow, Report
class PostMenuWidget extends StatelessWidget {
  final PostItem post;

  const PostMenuWidget({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cubit = context.read<PostFeedCubit>();

    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colorScheme.surface,
      elevation: 8,
      onSelected: (value) => _handleAction(context, value, cubit),
      itemBuilder: (_) => post.isOwner
          ? _ownerItems(colorScheme)
          : _nonOwnerItems(colorScheme),
    );
  }

  List<PopupMenuEntry<String>> _ownerItems(ColorScheme cs) => [
        _menuItem('edit', Icons.edit_outlined, 'تعديل', cs.primary),
        _menuItem('delete', Icons.delete_outline, 'حذف', const Color(0xFFFF5252)),
      ];

  List<PopupMenuEntry<String>> _nonOwnerItems(ColorScheme cs) => [
        _menuItem(
          'save',
          post.isSaved ? Icons.bookmark : Icons.bookmark_border,
          post.isSaved ? 'إلغاء الحفظ' : 'حفظ',
          cs.primary,
        ),
        _menuItem(
          'follow',
          post.isFollowedByCurrentUser
              ? Icons.person_remove_outlined
              : Icons.person_add_outlined,
          post.isFollowedByCurrentUser ? 'إلغاء المتابعة' : 'متابعة',
          cs.primary,
        ),
        const PopupMenuDivider(),
        _menuItem('report', Icons.flag_outlined, 'إبلاغ', const Color(0xFFFF5252)),
      ];

  PopupMenuItem<String> _menuItem(
    String value,
    IconData icon,
    String label,
    Color color,
  ) {
    return PopupMenuItem(
      value: value,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: color, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  void _handleAction(BuildContext context, String action, PostFeedCubit cubit) {
    switch (action) {
      case 'edit':
        // TODO: Navigate to edit post page
        break;
      case 'delete':
        _showDeleteConfirmation(context, cubit);
        break;
      case 'save':
        cubit.toggleSave(postId: post.id, isSaved: post.isSaved);
        break;
      case 'follow':
        if (post.isFollowedByCurrentUser) {
          cubit.unfollowUser(post.userId);
        } else {
          cubit.followUser(post.userId);
        }
        break;
      case 'report':
        cubit.reportPost(post.id);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context, PostFeedCubit cubit) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('حذف المنشور', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('هل أنت متأكد من حذف هذا المنشور؟ لا يمكن التراجع عن هذا الإجراء.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('إلغاء', style: TextStyle(color: colorScheme.onSurfaceVariant)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF5252)),
              onPressed: () {
                Navigator.pop(ctx);
                cubit.deletePost(post.id);
              },
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    );
  }
}
