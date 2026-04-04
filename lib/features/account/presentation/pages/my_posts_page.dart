import 'package:flutter/material.dart';
import 'package:mafqood/constants.dart';

class MyPostsPage extends StatelessWidget {
  const MyPostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final posts = [
      _PostData(
        userName: 'Mostafa Alfy',
        status: 'مفقود',
        statusColor: const Color(0xFFFF5252),
        description: 'الاسم: علي عمر صالح , العنوان: قنا -الشؤون, رقم التل..',
        likes: 25,
        dislikes: 2,
        comments: 16,
      ),
      _PostData(
        userName: 'Mostafa Nasser',
        status: 'موجود',
        statusColor: const Color(0xFF4CAF50),
        description: 'الاسم: علي عمر صالح , العنوان: قنا -الشؤون, رقم التل..',
        likes: 25,
        dislikes: 2,
        comments: 16,
      ),
      _PostData(
        userName: 'Mostafa Alfy',
        status: 'موجود',
        statusColor: const Color(0xFF4CAF50),
        description: 'الاسم: علي عمر صالح , العنوان: قنا -الشؤون, رقم التل..',
        likes: 25,
        dislikes: 2,
        comments: 16,
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'منشوراتي',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── User profile + stats header ──
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFFE0F7FA),
                  child: Text(
                    'M',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mostafa Alfy',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: const [
                          _StatItem(label: 'منشوراتي', value: '3'),
                          SizedBox(width: 20),
                          _StatItem(label: 'مفقود', value: '2'),
                          SizedBox(width: 20),
                          _StatItem(label: 'موجود', value: '1'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Posts list ──
            ...posts.map((post) => _MyPostCard(data: post)),
          ],
        ),
      ),
    );
  }
}

// ── Stat item (e.g. منشوراتي 3) ──
class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.black54, fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}

// ── Post data model ──
class _PostData {
  final String userName;
  final String status;
  final Color statusColor;
  final String description;
  final int likes;
  final int dislikes;
  final int comments;

  _PostData({
    required this.userName,
    required this.status,
    required this.statusColor,
    required this.description,
    required this.likes,
    required this.dislikes,
    required this.comments,
  });
}

// ── Post card widget ──
class _MyPostCard extends StatefulWidget {
  final _PostData data;

  const _MyPostCard({required this.data});

  @override
  State<_MyPostCard> createState() => _MyPostCardState();
}

class _MyPostCardState extends State<_MyPostCard> {
  late int _likes;
  late int _dislikes;
  bool _isLiked = false;
  bool _isDisliked = false;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _likes = widget.data.likes;
    _dislikes = widget.data.dislikes;
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
    final data = widget.data;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header: avatar + name + status ──
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFE0F7FA),
                  child: Text(
                    data.userName.isNotEmpty ? data.userName[0] : '?',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data.userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Icon(Icons.access_time, size: 16, color: Colors.black38),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: data.statusColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    data.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Description with see more ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: RichText(
                maxLines: _expanded ? 10 : 1,
                overflow: TextOverflow.ellipsis,
                textDirection: TextDirection.rtl,
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                  ),
                  children: [
                    TextSpan(text: data.description),
                    if (!_expanded)
                      const TextSpan(
                        text: ' see more',
                        style: TextStyle(
                          color: Colors.black45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ── Post image placeholder ──
          Container(
            height: 180,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.image_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),

          // ── Action bar ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Like
                _ActionButton(
                  icon: _isLiked
                      ? Icons.thumb_up_alt
                      : Icons.thumb_up_alt_outlined,
                  count: _likes,
                  isActive: _isLiked,
                  activeColor: kPrimaryColor,
                  onTap: _toggleLike,
                ),
                const SizedBox(width: 16),
                // Dislike
                _ActionButton(
                  icon: _isDisliked
                      ? Icons.thumb_down_alt
                      : Icons.thumb_down_alt_outlined,
                  count: _dislikes,
                  isActive: _isDisliked,
                  activeColor: const Color(0xFFFF5252),
                  onTap: _toggleDislike,
                ),
                const SizedBox(width: 16),
                // Comments
                _ActionButton(
                  icon: Icons.chat_bubble_outline,
                  count: widget.data.comments,
                  isActive: false,
                  activeColor: Colors.black54,
                  onTap: () {
                    // TODO: open comments
                  },
                ),
                const Spacer(),
                // Share
                GestureDetector(
                  onTap: () {
                    // TODO: share post
                  },
                  child: const Icon(
                    Icons.send_outlined,
                    size: 20,
                    color: kPrimaryColor,
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

// ── Small action button (like, dislike, comment) ──
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _ActionButton({
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
          Icon(
            icon,
            size: 18,
            color: isActive ? activeColor : Colors.black45,
          ),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 13,
              color: isActive ? activeColor : Colors.black54,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
