import 'package:flutter/material.dart';
import 'package:mafqood/constants.dart';
import 'package:mafqood/features/chat/presentation/chat_conversation_page.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        title: const Text('الدردشة', style: TextStyle(color: Colors.white)),
        actions: const [
          Icon(Icons.search, color: Colors.white),
          SizedBox(width: 16),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _ChatItem(
            name: 'Mostafa Alfy',
            message: 'سلام عليكم',
            time: '9:25 AM',
            unreadCount: 1,
          ),
          _ChatItem(
            name: 'Mostafa nasser',
            message: 'انا عندي معلومه عنه',
            time: '7:44 AM',
            unreadCount: 3,
          ),
          _ChatItem(
            name: 'Ahmed Mostafa',
            message: 'سأدعمني في العثور عليه',
            time: '8/6/2025',
            unreadCount: 0,
          ),
        ],
      ),
    );
  }
}

class _ChatItem extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final int unreadCount;

  const _ChatItem({
    required this.name,
    required this.message,
    required this.time,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatConversationPage(contactName: name),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kPrimaryColor),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: CircleAvatar(
            backgroundColor: const Color(0xFFE0F7FA),
            child: Text(name.characters.first.toUpperCase()),
          ),
          title: Text(name),
          subtitle: Text(message),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(time, style: const TextStyle(fontSize: 11)),
              const SizedBox(height: 4),
              if (unreadCount > 0)
                CircleAvatar(
                  radius: 10,
                  backgroundColor: kPrimaryColor,
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
