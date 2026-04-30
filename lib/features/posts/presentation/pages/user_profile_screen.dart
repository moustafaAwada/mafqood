import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mafqood/features/posts/domain/entities/post_entities.dart';
import 'package:mafqood/features/posts/domain/repositories/post_repository.dart';
import 'package:mafqood/features/posts/presentation/cubit/post_feed_cubit.dart';
import 'package:mafqood/features/chat/presentation/cubit/chat_cubit.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  UserProfileEntity? _profile;
  bool _isLoading = true;
  bool _isStartingChat = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    final repo = context.read<PostRepository>();
    final result = await repo.getUserProfile(widget.userId);
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _error = failure.message;
        _isLoading = false;
      }),
      (profile) => setState(() {
        _profile = profile;
        _isLoading = false;
      }),
    );
  }

  Future<void> _startChat() async {
    setState(() => _isStartingChat = true);
    final chatCubit = context.read<ChatCubit>();
    final roomId = await chatCubit.initiateChatWithUser(widget.userId);
    if (!mounted) return;
    setState(() => _isStartingChat = false);

    if (roomId != null) {
      Navigator.pushNamed(
        context,
        '/chat-conversation',
        arguments: {
          'chatRoomId': roomId,
          'recipientId': widget.userId,
          'contactName': _profile?.name ?? 'مستخدم',
        },
      );
    } else {
      final errorMsg = chatCubit.state.error ?? 'حدث خطأ أثناء بدء المحادثة';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
      chatCubit.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cubit = context.read<PostFeedCubit>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          title: Text('الملف الشخصي',
              style: TextStyle(color: colorScheme.onPrimary)),
          iconTheme: IconThemeData(color: colorScheme.onPrimary),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: colorScheme.error),
                      const SizedBox(height: 12),
                      Text(_error!,
                          style: TextStyle(color: colorScheme.onSurface)),
                      const SizedBox(height: 12),
                      FilledButton(
                          onPressed: _fetchProfile,
                          child: const Text('إعادة المحاولة')),
                    ],
                  ))
                : _buildProfile(colorScheme, cubit),
      ),
    );
  }

  Widget _buildProfile(ColorScheme cs, PostFeedCubit cubit) {
    final profile = _profile!;

    // Sync follow state from Cubit (may have been optimistically updated)
    final isFollowed = context.select<PostFeedCubit, bool>((c) {
      // Check if any post from this user has the updated follow status
      final match = c.state.posts.where((p) => p.userId == profile.id);
      if (match.isNotEmpty) return match.first.isFollowedByCurrentUser;
      return profile.isFollowedByCurrentUser;
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // ── Avatar ──
          profile.profilePictureUrl != null
              ? CachedNetworkImage(
                  imageUrl: profile.profilePictureUrl!,
                  imageBuilder: (_, imageProvider) => CircleAvatar(
                    radius: 48,
                    backgroundImage: imageProvider,
                  ),
                  placeholder: (_, __) => CircleAvatar(
                    radius: 48,
                    backgroundColor: cs.primaryContainer,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                  errorWidget: (_, __, ___) => CircleAvatar(
                    radius: 48,
                    backgroundColor: cs.primaryContainer,
                    child: Text(
                      profile.name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                  ),
                )
              : CircleAvatar(
                  radius: 48,
                  backgroundColor: cs.primaryContainer,
                  child: Text(
                    profile.name[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ),
          const SizedBox(height: 16),
          // ── Name ──
          Text(
            profile.name,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.email,
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
          if (profile.phoneNumber != null) ...[
            const SizedBox(height: 4),
            Text(
              profile.phoneNumber!,
              style: TextStyle(
                fontSize: 14,
                color: cs.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
          const SizedBox(height: 24),
          // ── Action buttons ──
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    if (isFollowed) {
                      cubit.unfollowUser(profile.id);
                    } else {
                      cubit.followUser(profile.id);
                    }
                  },
                  icon: Icon(isFollowed
                      ? Icons.person_remove_outlined
                      : Icons.person_add_outlined),
                  label: Text(isFollowed ? 'إلغاء المتابعة' : 'متابعة'),
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        isFollowed ? cs.surfaceContainerHighest : cs.primary,
                    foregroundColor:
                        isFollowed ? cs.onSurface : cs.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isStartingChat ? null : _startChat,
                  icon: _isStartingChat
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: cs.primary),
                        )
                      : const Icon(Icons.chat_outlined),
                  label: const Text('مراسلة'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: cs.primary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
