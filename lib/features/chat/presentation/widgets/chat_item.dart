import 'package:flutter/material.dart';
import 'package:mafqood/features/chat/data/models/chat_enums.dart';
import 'package:mafqood/features/chat/data/models/chat_models.dart';
import 'package:mafqood/features/chat/presentation/pages/chat_conversation_page.dart';

class ChatItem extends StatelessWidget {
  final ChatRoomModel room;
  final int unreadCount;
  final bool isOnline;
  final bool isTyping;

  const ChatItem({
    super.key,
    required this.room,
    required this.unreadCount,
    required this.isOnline,
    this.isTyping = false,
  });

  String get _displayName => room.otherParticipant.name;

  String get _initial =>
      _displayName.isNotEmpty ? _displayName[0].toUpperCase() : '?';

  String get _lastMessagePreview {
    final last = room.lastMessage;
    if (last == null) return '';
    if (last.type == MessageType.image) return '📷 صورة';
    return last.content ?? '';
  }

  String get _timeDisplay {
    final last = room.lastMessage;
    if (last == null) return '';
    final now = DateTime.now();
    final diff = now.difference(last.sentAt);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return 'منذ ${diff.inMinutes} د';
    if (diff.inDays < 1) {
      final h = last.sentAt.hour.toString().padLeft(2, '0');
      final m = last.sentAt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
    if (diff.inDays == 1) return 'أمس';
    return '${last.sentAt.day}/${last.sentAt.month}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatConversationPage(
              chatRoomId: room.id,
              recipientId: room.otherParticipant.id,
              contactName: _displayName,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.01),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor:
                      colorScheme.primary.withValues(alpha: 0.08),
                  backgroundImage:
                      room.otherParticipant.profilePictureUrl != null
                          ? NetworkImage(
                              room.otherParticipant.profilePictureUrl!)
                          : null,
                  child: room.otherParticipant.profilePictureUrl == null
                      ? Text(
                          _initial,
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        )
                      : null,
                ),
                if (isOnline)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.surface,
                          width: 2.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _displayName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        _timeDisplay,
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurface
                              .withValues(alpha: 0.3),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: isTyping
                            ? Text(
                                'يكتب...',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.italic,
                                ),
                              )
                            : Text(
                                _lastMessagePreview,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: unreadCount > 0
                                      ? colorScheme.onSurface
                                          .withValues(alpha: 0.8)
                                      : colorScheme.onSurface
                                          .withValues(alpha: 0.4),
                                  fontWeight: unreadCount > 0
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                      ),
                      if (unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$unreadCount',
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
