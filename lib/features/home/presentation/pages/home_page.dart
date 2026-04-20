import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mafqood/features/home/presentation/pages/create_post_page.dart'
    as create;
import 'package:mafqood/features/home/presentation/widgets/post_card.dart';
import 'package:mafqood/features/home/presentation/widgets/post_type_option.dart';
import 'package:mafqood/features/home/presentation/widgets/status_chip.dart';
import 'package:mafqood/features/posts/domain/entities/post_entities.dart';
import 'package:mafqood/features/posts/presentation/cubit/post_feed_cubit.dart';
import 'package:mafqood/features/posts/presentation/cubit/post_feed_state.dart';

void _showPostTypeSheet(BuildContext context) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.dividerColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'اختر نوع المنشور',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: PostTypeOption(
                  label: 'مفقود',
                  icon: Icons.help_outline,
                  color: const Color(0xFFFF5252),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const create.CreatePostPage(
                              postType: create.PostType.mafqood,
                            ),
                      ),
                    ).then((created) {
                      if (created == true) {
                        context.read<PostFeedCubit>().fetchPosts(refresh: true);
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PostTypeOption(
                  label: 'موجود',
                  icon: Icons.location_on_outlined,
                  color: const Color(0xFF4CAF50),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const create.CreatePostPage(
                              postType: create.PostType.mawjood,
                            ),
                      ),
                    ).then((created) {
                      if (created == true) {
                        context.read<PostFeedCubit>().fetchPosts(refresh: true);
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  Future<void> _refreshPosts() async {
    await context.read<PostFeedCubit>().fetchPosts(refresh: true);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostFeedCubit>().fetchPosts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocBuilder<PostFeedCubit, PostFeedState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: colorScheme.primary,
              elevation: 0,
              centerTitle: true,
              title: Text(
                'مفقود',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.notifications_none,
                    color: colorScheme.onPrimary,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showPostTypeSheet(context),
              backgroundColor: colorScheme.primary,
              elevation: 4,
              child: Icon(Icons.add, color: colorScheme.onPrimary, size: 30),
            ),
            body: RefreshIndicator(
              onRefresh: _refreshPosts,
              color: colorScheme.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'اكتشف المنشورات حولك',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showPostTypeSheet(context),
                      icon: Icon(
                        Icons.add_circle,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      label: Text(
                        'أضف منشور',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.dividerColor.withOpacity(0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          textDirection: TextDirection.rtl,
                          onChanged: (value) =>
                              context.read<PostFeedCubit>().setSearchQuery(value),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'بحث عن مفقود، مدينة، أو اسم....',
                            hintStyle: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.4),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          state.searchQuery.isEmpty ? Icons.search : Icons.clear,
                          color: colorScheme.primary,
                        ),
                        onPressed: () {
                          if (state.searchQuery.isNotEmpty) {
                            _searchController.clear();
                            context.read<PostFeedCubit>().setSearchQuery('');
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusChip(
                      label: 'مفقود',
                      count: '22,234',
                      color: const Color(0xFFFF5252),
                      icon: Icons.help_outline,
                    ),
                    const SizedBox(width: 8),
                    StatusChip(
                      label: 'موجود',
                      count: '9,234',
                      color: colorScheme.primary,
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(width: 8),
                    StatusChip(
                      label: 'تم العثور',
                      count: '8,908',
                      color: const Color(0xFF4CAF50),
                      icon: Icons.check_circle_outline,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (state.isLoading || state.isRefreshing)
                  const Center(child: CircularProgressIndicator())
                else if (state.filteredPosts.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد نتائج',
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...state.filteredPosts.map(
                    (post) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: PostCard(
                        postId: post.id,
                        statusLabel:
                            post.type == PostType.lost ? 'مفقود' : 'موجود',
                        statusColor: post.type == PostType.lost
                            ? const Color(0xFFFF5252)
                            : const Color(0xFF4CAF50),
                        name: post.userName ?? 'مستخدم',
                        subtitle: post.description ?? '',
                        initialLikes: post.likesCount,
                        initialDislikes: post.dislikesCount,
                        initialComments: post.commentsCount,
                        initialIsSaved: post.isSaved,
                        initialReactType: post.userReactType,
                        onReact: (reactType) =>
                            context.read<PostFeedCubit>().toggleReact(
                                  postId: post.id,
                                  reactType: reactType,
                                ),
                        onToggleSave: (isSaved) =>
                            context.read<PostFeedCubit>().toggleSave(
                                  postId: post.id,
                                  isSaved: isSaved,
                                ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
