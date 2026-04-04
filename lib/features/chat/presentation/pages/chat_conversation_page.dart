import 'package:flutter/material.dart';
import 'package:mafqood/features/chat/presentation/widgets/date_chip.dart';
import 'package:mafqood/features/chat/presentation/widgets/message_bubble.dart';
import 'package:mafqood/features/chat/presentation/widgets/message_input.dart';

class ChatConversationPage extends StatefulWidget {
  final String contactName;

  const ChatConversationPage({
    super.key,
    required this.contactName,
  });

  @override
  State<ChatConversationPage> createState() => _ChatConversationPageState();
}

class _ChatConversationPageState extends State<ChatConversationPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'السلام عليكم، هل وجدت المفقود؟',
      isMe: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    ChatMessage(
      text: 'وعليكم السلام، نعم لدي بعض المعلومات الهامة.',
      isMe: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 28)),
    ),
    ChatMessage(
      text: 'هل يمكنك مشاركتي التفاصيل من فضلك؟',
      isMe: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
    ChatMessage(
      text: 'نعم، سأرسل لك الموقع والوقت الدقيق الذي شوهد فيه.',
      isMe: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(text: text, isMe: true, timestamp: DateTime.now()),
      );
      _messageController.clear();
    });

    // Scroll to bottom after sending
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
          leading: IconButton(
            icon: Icon(Icons.arrow_forward_ios, color: colorScheme.onPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          titleSpacing: 0,
          title: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: colorScheme.onPrimary.withOpacity(0.1),
                child: Text(
                  widget.contactName.isNotEmpty
                      ? widget.contactName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.contactName,
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'متصل الآن',
                      style: TextStyle(
                        color: colorScheme.onPrimary.withOpacity(0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.call_outlined, color: colorScheme.onPrimary, size: 22),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.more_vert_rounded, color: colorScheme.onPrimary),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            // Messages list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final showDate =
                      index == 0 ||
                      _messages[index].timestamp.day !=
                          _messages[index - 1].timestamp.day;

                  return Column(
                    children: [
                      if (showDate) DateChip(date: message.timestamp),
                      MessageBubble(
                        message: message,
                        formatTime: _formatTime,
                      ),
                    ],
                  );
                },
              ),
            ),

            // Input area
            MessageInput(
              controller: _messageController,
              onSendMessage: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}