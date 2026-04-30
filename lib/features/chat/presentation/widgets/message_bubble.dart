import 'package:flutter/material.dart';
import 'package:mafqood/features/chat/data/models/chat_enums.dart';
import 'package:mafqood/features/chat/domain/entities/chat_entities.dart';

class MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isPending;
  final bool isFailed;

  const MessageBubble({
    super.key,
    required this.message,
    this.isPending = false,
    this.isFailed = false,
  });

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isMe = message.isOwner;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Opacity(
        opacity: isPending ? 0.6 : 1.0,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isFailed
                ? colorScheme.error.withValues(alpha: 0.15)
                : isMe
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 16),
            ),
            boxShadow: [
              if (!isMe)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // Message content
              if (message.type == MessageType.image &&
                  message.attachmentUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    message.attachmentUrl!,
                    width: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _2, _3) => Container(
                      width: 200,
                      height: 100,
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(Icons.broken_image,
                          color: colorScheme.onSurface.withValues(alpha: 0.4)),
                    ),
                  ),
                ),
              if (message.content != null && message.content!.isNotEmpty)
                Padding(
                  padding: message.type == MessageType.image
                      ? const EdgeInsets.only(top: 6)
                      : EdgeInsets.zero,
                  child: Text(
                    message.content!,
                    style: TextStyle(
                      color: isFailed
                          ? colorScheme.error
                          : isMe
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              // Time + delivery status
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message.sentAt),
                    style: TextStyle(
                      color: (isMe
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface)
                          .withValues(alpha: 0.5),
                      fontSize: 10,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    _buildStatusIcon(colorScheme),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(ColorScheme colorScheme) {
    if (isFailed) {
      return Icon(
        Icons.error_outline,
        size: 14,
        color: colorScheme.error,
      );
    }
    if (isPending) {
      return Icon(
        Icons.access_time,
        size: 14,
        color: colorScheme.onPrimary.withValues(alpha: 0.5),
      );
    }

    switch (message.deliveryStatus) {
      case MessageDeliveryStatus.sent:
        return Icon(
          Icons.done,
          size: 14,
          color: colorScheme.onPrimary.withValues(alpha: 0.7),
        );
      case MessageDeliveryStatus.delivered:
        return Icon(
          Icons.done_all,
          size: 14,
          color: colorScheme.onPrimary.withValues(alpha: 0.7),
        );
      case MessageDeliveryStatus.read:
        return const Icon(
          Icons.done_all,
          size: 14,
          color: Colors.lightBlueAccent,
        );
    }
  }
}

/// Animated version of MessageBubble with fade-in and slide animation
class AnimatedMessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isPending;
  final bool isFailed;
  final int index;

  const AnimatedMessageBubble({
    super.key,
    required this.message,
    this.isPending = false,
    this.isFailed = false,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    // Staggered animation delay based on index (for initial load)
    // But cap it so later messages still animate quickly
    final delay = Duration(milliseconds: (index * 30).clamp(0, 300));
    
    final isMe = message.isOwner;
    final slideOffset = isMe ? const Offset(20, 0) : const Offset(-20, 0);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(
              slideOffset.dx * (1 - value),
              slideOffset.dy * (1 - value),
            ),
            child: child,
          ),
        );
      },
      child: MessageBubble(
        message: message,
        isPending: isPending,
        isFailed: isFailed,
      ),
    );
  }
}
