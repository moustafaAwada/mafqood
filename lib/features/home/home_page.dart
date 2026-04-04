import 'package:flutter/material.dart';
import 'package:mafqood/constants.dart';
import 'package:mafqood/features/home/presentation/pages/create_post_page.dart';
import 'package:mafqood/features/home/presentation/widgets/comments_bottom_sheet.dart';

void _showPostTypeSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'اختر نوع المنشور',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _PostTypeOption(
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
                child: _PostTypeOption(
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
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}

class _PostTypeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _PostTypeOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        title: const Text(
          'مفقود',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPostTypeSheet(context),
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () => _showPostTypeSheet(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'منشور جديد',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(Icons.add_circle_outline, color: kPrimaryColor),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: const TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'بحث عن مفقود....',
                  icon: Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _StatusChip(
                  label: 'مفقود',
                  count: '22,234',
                  color: Color(0xFFFF5252),
                  icon: Icons.help_outline,
                ),
                _StatusChip(
                  label: 'موجود',
                  count: '9,234',
                  color: kPrimaryColor,
                  icon: Icons.location_on_outlined,
                ),
                _StatusChip(
                  label: 'تم العثور عليه',
                  count: '8,908',
                  color: Color(0xFF4CAF50),
                  icon: Icons.check_circle_outline,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _PostCard(
              statusLabel: 'مفقود',
              statusColor: Color(0xFFFF5252),
              name: 'علي عمر صالح',
              subtitle: 'العنوان هنا، التفاصيل ورقم التليفون',
            ),
            const SizedBox(height: 12),
            const _PostCard(
              statusLabel: 'مفقود',
              statusColor: Color(0xFFFF5252),
              name: 'طفل مفقود',
              subtitle: 'العنوان هنا، التفاصيل ورقم التليفون',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final String count;
  final Color color;
  final IconData icon;

  const _StatusChip({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(
              count,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
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
  final int initialLikes;
  final int initialDislikes;
  final int initialComments;

  const _PostCard({
    required this.statusLabel,
    required this.statusColor,
    required this.name,
    required this.subtitle,
    this.initialLikes = 0,
    this.initialDislikes = 0,
    this.initialComments = 0,
  });

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  late int _likes;
  late int _dislikes;
  late int _comments;
  bool _isLiked = false;
  bool _isDisliked = false;
  final List<Comment> _commentsList = [];

  @override
  void initState() {
    super.initState();
    _likes = widget.initialLikes;
    _dislikes = widget.initialDislikes;
    _comments = widget.initialComments;
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

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: widget.statusColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.statusLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const CircleAvatar(radius: 14, child: Text('M')),
              ],
            ),
          ),
          Container(height: 160, color: Colors.grey.shade300),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ).copyWith(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _PostAction(
                  icon: _isLiked
                      ? Icons.thumb_up_alt
                      : Icons.thumb_up_alt_outlined,
                  count: _likes,
                  isActive: _isLiked,
                  activeColor: kPrimaryColor,
                  onTap: _toggleLike,
                ),
                _PostAction(
                  icon: _isDisliked
                      ? Icons.thumb_down_alt
                      : Icons.thumb_down_alt_outlined,
                  count: _dislikes,
                  isActive: _isDisliked,
                  activeColor: const Color(0xFFFF5252),
                  onTap: _toggleDislike,
                ),
                _PostAction(
                  icon: Icons.comment_outlined,
                  count: _comments,
                  isActive: false,
                  activeColor: Colors.black54,
                  onTap: _openComments,
                ),
                const Icon(Icons.play_circle_outline),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostAction extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: isActive ? activeColor : Colors.black54),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: TextStyle(
              color: isActive ? activeColor : Colors.black87,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
