import 'package:flutter/material.dart';

class MyPostsPage extends StatelessWidget {
  const MyPostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final posts = [
      _PostData(
        userName: 'مصطفى الألفي',
        status: 'مفقود',
        isMissing: true,
        description:
            'الاسم: علي عمر صالح، المفقود في قنا الخمسين، يرتدي قميصاً أزرق، يرجى التواصل في حال العثور عليه.',
        likes: 25,
        comments: 16,
        time: 'منذ ساعتين',
      ),
      _PostData(
        userName: 'مصطفى الألفي',
        status: 'تم العثور',
        isMissing: false,
        description:
            'شكراً للجميع، تم العثور على المفقود وهو الآن بصحة جيدة مع عائلته.',
        likes: 142,
        comments: 48,
        time: 'منذ يومين',
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'منشوراتي',
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_forward_ios,
              color: colorScheme.onPrimary,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            // ── User Summary Header ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.01),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    child: Text(
                      'M',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مصطفى الألفي',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _StatItem(label: 'المنشورات', value: '3'),
                            _verticalDivider(theme),
                            _StatItem(label: 'مفقود', value: '1'),
                            _verticalDivider(theme),
                            _StatItem(label: 'موجود', value: '2'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'تاريخ النشر',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Posts list ──
            ...posts.map((post) => _MyPostCard(data: post)),
          ],
        ),
      ),
    );
  }

  Widget _verticalDivider(ThemeData theme) => Container(
    height: 15,
    width: 1,
    margin: const EdgeInsets.symmetric(horizontal: 16),
    color: theme.dividerColor.withOpacity(0.2),
  );
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 15,
            color: colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.4),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _PostData {
  final String userName;
  final String status;
  final bool isMissing;
  final String description;
  final int likes;
  final int comments;
  final String time;

  _PostData({
    required this.userName,
    required this.status,
    required this.isMissing,
    required this.description,
    required this.likes,
    required this.comments,
    required this.time,
  });
}

class _MyPostCard extends StatelessWidget {
  final _PostData data;
  const _MyPostCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = data.isMissing
        ? colorScheme.error
        : const Color(0xFF4CAF50);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  data.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                data.time,
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.3),
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.more_horiz,
                color: colorScheme.onSurface.withOpacity(0.3),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            data.description,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withOpacity(0.8),
              height: 1.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          // Actions
          Row(
            children: [
              _ActionItem(
                icon: Icons.favorite_border_rounded,
                count: data.likes,
              ),
              const SizedBox(width: 20),
              _ActionItem(
                icon: Icons.chat_bubble_outline_rounded,
                count: data.comments,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('تعديل', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final int count;
  const _ActionItem({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.onSurface.withOpacity(0.4)),
        const SizedBox(width: 6),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.onSurface.withOpacity(0.4),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
