import 'package:equatable/equatable.dart';
import 'package:mafqood/features/chat/data/models/chat_enums.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ChatRoom — Domain entity for the chat room list
// ─────────────────────────────────────────────────────────────────────────────

class ChatRoom extends Equatable {
  final int id;
  final DateTime createdAt;

  // Other participant info
  final String otherUserId;
  final String otherUserName;
  final String? otherUserProfilePictureUrl;

  // Last message preview (client-computed on MessageReceived)
  final String? lastMessageContent;
  final MessageType? lastMessageType;
  final DateTime? lastMessageSentAt;

  // Unread count (client-computed: increment on MessageReceived, reset on read)
  final int unreadCount;

  const ChatRoom({
    required this.id,
    required this.createdAt,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserProfilePictureUrl,
    this.lastMessageContent,
    this.lastMessageType,
    this.lastMessageSentAt,
    this.unreadCount = 0,
  });

  ChatRoom copyWith({
    String? lastMessageContent,
    MessageType? lastMessageType,
    DateTime? lastMessageSentAt,
    int? unreadCount,
  }) {
    return ChatRoom(
      id: id,
      createdAt: createdAt,
      otherUserId: otherUserId,
      otherUserName: otherUserName,
      otherUserProfilePictureUrl: otherUserProfilePictureUrl,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      lastMessageType: lastMessageType ?? this.lastMessageType,
      lastMessageSentAt: lastMessageSentAt ?? this.lastMessageSentAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        otherUserId,
        otherUserName,
        otherUserProfilePictureUrl,
        lastMessageContent,
        lastMessageType,
        lastMessageSentAt,
        unreadCount,
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
// ChatRoomDetail — Extended room info (from GET /chat-rooms/{id})
// ─────────────────────────────────────────────────────────────────────────────

class ChatRoomDetail extends Equatable {
  final int id;
  final DateTime createdAt;

  // Current authenticated user
  final String currentUserId;
  final String currentUserName;
  final String? currentUserProfilePictureUrl;

  // Other participant
  final String otherUserId;
  final String otherUserName;
  final String? otherUserProfilePictureUrl;

  final int totalMessages;
  final int unreadMessages;

  const ChatRoomDetail({
    required this.id,
    required this.createdAt,
    required this.currentUserId,
    required this.currentUserName,
    this.currentUserProfilePictureUrl,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserProfilePictureUrl,
    required this.totalMessages,
    required this.unreadMessages,
  });

  @override
  List<Object?> get props => [
        id,
        createdAt,
        currentUserId,
        currentUserName,
        currentUserProfilePictureUrl,
        otherUserId,
        otherUserName,
        otherUserProfilePictureUrl,
        totalMessages,
        unreadMessages,
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
// MessageEntity — Domain entity for a single chat message
//
// Replaces the old `ChatMessage` class from `message_bubble.dart`.
// Contains all fields needed for display + status tracking.
// ─────────────────────────────────────────────────────────────────────────────

class MessageEntity extends Equatable {
  final int id;
  final String clientMessageId;
  final String senderId;
  final String senderName;
  final String? content;
  final MessageType type;
  final DateTime sentAt;
  final bool isRead;
  final DateTime? readAt;
  final bool isOwner;
  final String? attachmentUrl;
  final MessageDeliveryStatus deliveryStatus;

  const MessageEntity({
    required this.id,
    required this.clientMessageId,
    required this.senderId,
    required this.senderName,
    this.content,
    required this.type,
    required this.sentAt,
    required this.isRead,
    this.readAt,
    required this.isOwner,
    this.attachmentUrl,
    this.deliveryStatus = MessageDeliveryStatus.sent,
  });

  MessageEntity copyWith({
    int? id,
    bool? isRead,
    DateTime? readAt,
    bool? isOwner,
    MessageDeliveryStatus? deliveryStatus,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      clientMessageId: clientMessageId,
      senderId: senderId,
      senderName: senderName,
      content: content,
      type: type,
      sentAt: sentAt,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      isOwner: isOwner ?? this.isOwner,
      attachmentUrl: attachmentUrl,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
    );
  }

  @override
  List<Object?> get props => [
        id,
        clientMessageId,
        senderId,
        senderName,
        content,
        type,
        sentAt,
        isRead,
        readAt,
        isOwner,
        attachmentUrl,
        deliveryStatus,
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
// OutboxMessage — Locally queued message for offline sending
//
// The `clientMessageId` is generated BEFORE sending and persists across
// retries — this is the core of the idempotency contract. Even if the
// same message is sent multiple times, the backend deduplicates via this ID.
// ─────────────────────────────────────────────────────────────────────────────

class OutboxMessage extends Equatable {
  /// The chat room this message belongs to, if known.
  ///
  /// - Present when the message was created from within an existing room.\n+  /// - May be null when the send failed before a room was resolved.\n+  ///   In that case the UI should fall back to filtering by recipient.\n+  ///\n+  /// Keeping this nullable also allows smooth cache migration from older\n+  /// versions where this field didn’t exist.
  final int? chatRoomId;
  final String clientMessageId;
  final String recipientUserId;
  final String content;
  final MessageType type;
  final String? attachmentPath;
  final DateTime createdAt;
  final OutboxMessageStatus status;

  const OutboxMessage({
    this.chatRoomId,
    required this.clientMessageId,
    required this.recipientUserId,
    required this.content,
    required this.type,
    this.attachmentPath,
    required this.createdAt,
    this.status = OutboxMessageStatus.pending,
  });

  OutboxMessage copyWith({
    int? chatRoomId,
    OutboxMessageStatus? status,
  }) {
    return OutboxMessage(
      chatRoomId: chatRoomId ?? this.chatRoomId,
      clientMessageId: clientMessageId,
      recipientUserId: recipientUserId,
      content: content,
      type: type,
      attachmentPath: attachmentPath,
      createdAt: createdAt,
      status: status ?? this.status,
    );
  }

  /// Serialize for SharedPreferences (CacheHelper) persistence.
  Map<String, dynamic> toJson() => {
        'chatRoomId': chatRoomId,
        'clientMessageId': clientMessageId,
        'recipientUserId': recipientUserId,
        'content': content,
        'type': type.index,
        'attachmentPath': attachmentPath,
        'createdAt': createdAt.toIso8601String(),
        'status': status.index,
      };

  /// Deserialize from SharedPreferences (CacheHelper) persistence.
  factory OutboxMessage.fromJson(Map<String, dynamic> json) {
    return OutboxMessage(
      chatRoomId: json['chatRoomId'] as int?,
      clientMessageId: json['clientMessageId'] as String,
      recipientUserId: json['recipientUserId'] as String,
      content: json['content'] as String,
      type: MessageType.values[json['type'] as int],
      attachmentPath: json['attachmentPath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: OutboxMessageStatus.values[json['status'] as int],
    );
  }

  @override
  List<Object?> get props => [
        chatRoomId,
        clientMessageId,
        recipientUserId,
        content,
        type,
        attachmentPath,
        createdAt,
        status,
      ];
}
