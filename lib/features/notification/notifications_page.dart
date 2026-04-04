import 'package:flutter/material.dart';
import 'package:mafqood/constants.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        title: const Text('الإشعارات', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          NotificationItem(
            title: 'تمت إضافة منشور جديد بالقرب منك',
            time: 'قبل 5 دقائق',
          ),
          NotificationItem(
            title: 'هناك تحديث في حالة مفقود تتابعه',
            time: 'قبل ساعة',
          ),
          NotificationItem(title: 'شخص أرسل لك رسالة جديدة', time: 'أمس'),
        ],
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final String title;
  final String time;

  const NotificationItem({super.key, required this.title, required this.time});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(
          Icons.notifications_active_outlined,
          color: kPrimaryColor,
        ),
        title: Text(title),
        subtitle: Text(
          time,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ),
    );
  }
}
