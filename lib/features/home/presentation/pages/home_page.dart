import 'package:flutter/material.dart';
import 'package:mafqood/features/home/presentation/pages/create_post_page.dart';
import 'package:mafqood/features/home/presentation/widgets/comments_bottom_sheet.dart';
import 'package:mafqood/features/home/presentation/widgets/post_card.dart';
import 'package:mafqood/features/home/presentation/widgets/post_type_option.dart';
import 'package:mafqood/features/home/presentation/widgets/status_chip.dart';

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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const CreatePostPage(postType: PostType.mafqood),
                      ),
                    );
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const CreatePostPage(postType: PostType.mawjood),
                      ),
                    );
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
  String _searchQuery = '';
  bool _isRefreshing = false;

  final List<Map<String, dynamic>> _posts = [
    {
      'statusLabel': 'مفقود',
      'statusColor': const Color(0xFFFF5252),
      'name': 'علي عمر صالح',
      'subtitle': 'القاهرة، مدينة نصر - منذ يومين',
    },
    {
      'statusLabel': 'موجود',
      'statusColor': const Color(0xFF4CAF50),
      'name': 'طفل مفقود',
      'subtitle': 'الجيزة، الهرم - منذ ٣ ساعات',
    },
  ];

  List<Map<String, dynamic>> get _filteredPosts {
    if (_searchQuery.isEmpty) return _posts;
    return _posts.where((post) {
      final name = post['name'] as String;
      final subtitle = post['subtitle'] as String;
      final query = _searchQuery.toLowerCase();
      return name.toLowerCase().contains(query) ||
          subtitle.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _refreshPosts() async {
    setState(() => _isRefreshing = true);
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isRefreshing = false);
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
      child: Scaffold(
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
                          onChanged: (value) {
                            setState(() => _searchQuery = value);
                          },
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
                          _searchQuery.isEmpty ? Icons.search : Icons.clear,
                          color: colorScheme.primary,
                        ),
                        onPressed: () {
                          if (_searchQuery.isNotEmpty) {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
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
                if (_isRefreshing)
                  const Center(child: CircularProgressIndicator())
                else if (_filteredPosts.isEmpty)
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
                  ..._filteredPosts.map(
                    (post) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: PostCard(
                        statusLabel: post['statusLabel'] as String,
                        statusColor: post['statusColor'] as Color,
                        name: post['name'] as String,
                        subtitle: post['subtitle'] as String,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PostCard extends StatefulWidget {
  final String statusLabel;
  final Color statusColor;
  final String name;
  final String subtitle;

  const _PostCard({
    required this.statusLabel,
    required this.statusColor,
    required this.name,
    required this.subtitle,
  });

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> with TickerProviderStateMixin {
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
                        _PostAction(
                          icon: _isLiked
                              ? Icons.thumb_up
                              : Icons.thumb_up_alt_outlined,
                          count: _likes,
                          isActive: _isLiked,
                          activeColor: colorScheme.primary,
                          onTap: _toggleLike,
                        ),
                        const SizedBox(width: 20),
                        _PostAction(
                          icon: _isDisliked
                              ? Icons.thumb_down
                              : Icons.thumb_down_alt_outlined,
                          count: _dislikes,
                          isActive: _isDisliked,
                          activeColor: const Color(0xFFFF5252),
                          onTap: _toggleDislike,
                        ),
                        const SizedBox(width: 20),
                        _PostAction(
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

class _PostAction extends StatefulWidget {
  final IconData icon;
  final int count;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _PostAction({
    required this.icon,
    required this.count,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  State<_PostAction> createState() => _PostActionState();
}

class _PostActionState extends State<_PostAction>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _animationController.forward().then((_) => _animationController.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 20,
                color: widget.isActive
                    ? widget.activeColor
                    : colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(width: 6),
              Text(
                '${widget.count}',
                style: TextStyle(
                  color: widget.isActive
                      ? widget.activeColor
                      : colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: widget.isActive
                      ? FontWeight.bold
                      : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
