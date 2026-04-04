import 'package:flutter/material.dart';
import 'package:mafqood/constants.dart';

class SavedPostsPage extends StatelessWidget {
  const SavedPostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample saved posts data
    final savedPosts = [
      const _SavedPostData(
        userName: 'Mostafa Alfy',
        status: 'مفقود',
        statusColor: Color(0xFFFF5252),
        name: 'علي عمر صالح',
        address: 'قنا -الشق..',
      ),
      const _SavedPostData(
        userName: 'Mostafa Alfy',
        status: 'موجود',
        statusColor: Color(0xFF4CAF50),
        name: 'علي عمر صالح',
        address: 'قنا -الشق..',
      ),
      const _SavedPostData(
        userName: 'Mostafa Alfy',
        status: 'مفقود',
        statusColor: Color(0xFFFF5252),
        name: 'علي عمر صالح',
        address: 'قنا -الشق..',
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'المنشورات المحفوظه',
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
        body: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: savedPosts.length,
          itemBuilder: (context, index) {
            return _SavedPostCard(data: savedPosts[index]);
          },
        ),
      ),
    );
  }
}

class _SavedPostData {
  final String userName;
  final String status;
  final Color statusColor;
  final String name;
  final String address;

  const _SavedPostData({
    required this.userName,
    required this.status,
    required this.statusColor,
    required this.name,
    required this.address,
  });
}

class _SavedPostCard extends StatelessWidget {
  final _SavedPostData data;

  const _SavedPostCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Post thumbnail image placeholder
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.image_outlined,
              color: Colors.grey.shade400,
              size: 28,
            ),
          ),

          const SizedBox(width: 12),

          // Post info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User name + status badge
                Row(
                  children: [
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
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
                    const SizedBox(width: 8),
                    Text(
                      data.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Name & address
                Text(
                  'الاسم: ${data.name} , العنوان: ${data.address}',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // User avatar
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFE0F7FA),
            child: Text(
              'M',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
