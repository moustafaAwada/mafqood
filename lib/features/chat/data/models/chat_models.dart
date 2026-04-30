import 'package:equatable/equatable.dart';
import 'package:mafqood/features/chat/data/models/chat_enums.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Participant (nested user info inside chat room responses)
// ─────────────────────────────────────────────────────────────────────────────

class ParticipantModel extends Equatable {
  final String id;
  final String name;
  final String? profilePictureUrl;

  const ParticipantModel({
    required this.id,
    required this.name,
    this.profilePictureUrl,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      profilePictureUrl: json['profilePictureUrl'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name, profilePictureUrl];
}

// ─────────────────────────────────────────────────────────────────────────────
// Last Message Preview (nested inside chat room list response)
// ─────────────────────────────────────────────────────────────────────────────

class LastMessageModel extends Equatable {
  final String? content;
  final MessageType type;
  final DateTime sentAt;

  const LastMessageModel({
    this.content,
    required this.type,
    required this.sentAt,
  });

  factory LastMessageModel.fromJson(Map<String, dynamic> json) {
    return LastMessageModel(
      content: json['content'] as String?,
      type: MessageType.values[json['type'] as int? ?? 0],
      sentAt: DateTime.parse(json['sentAt'] as String),
    );
  }

  @override
  List<Object?> get props => [content, type, sentAt];
}

// ─────────────────────────────────────────────────────────────────────────────
// Chat Room Model (from GET /chat-rooms list)
// ─────────────────────────────────────────────────────────────────────────────

class ChatRoomModel extends Equatable {
  final int id;
  final DateTime createdAt;
  final ParticipantModel otherParticipant;
  final LastMessageModel? lastMessage;
  final int unreadCount;

  const ChatRoomModel({
    required this.id,
    required this.createdAt,
    required this.otherParticipant,
    this.lastMessage,
    required this.unreadCount,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      otherParticipant: ParticipantModel.fromJson(
        json['otherParticipant'] as Map<String, dynamic>,
      ),
      lastMessage: json['lastMessage'] != null
          ? LastMessageModel.fromJson(
              json['lastMessage'] as Map<String, dynamic>,
            )
          : null,
      unreadCount: json['unreadCount'] as int? ?? 0,
    );
  }

  ChatRoomModel copyWith({
    LastMessageModel? lastMessage,
    int? unreadCount,
  }) {
    return ChatRoomModel(
      id: id,
      createdAt: createdAt,
      otherParticipant: otherParticipant,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props =>
      [id, createdAt, otherParticipant, lastMessage, unreadCount];
}

// ─────────────────────────────────────────────────────────────────────────────
// Chat Room Detail (from GET /chat-rooms/{id})
// ─────────────────────────────────────────────────────────────────────────────

class ChatRoomDetailModel extends Equatable {
  final int id;
  final DateTime createdAt;
  final ParticipantModel currentUser;
  final ParticipantModel otherUser;
  final int totalMessages;
  final int unreadMessages;

  const ChatRoomDetailModel({
    required this.id,
    required this.createdAt,
    required this.currentUser,
    required this.otherUser,
    required this.totalMessages,
    required this.unreadMessages,
  });

  factory ChatRoomDetailModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomDetailModel(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      currentUser: ParticipantModel.fromJson(
        json['currentUser'] as Map<String, dynamic>,
      ),
      otherUser: ParticipantModel.fromJson(
        json['otherUser'] as Map<String, dynamic>,
      ),
      totalMessages: json['totalMessages'] as int? ?? 0,
      unreadMessages: json['unreadMessages'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props =>
      [id, createdAt, currentUser, otherUser, totalMessages, unreadMessages];
}

// ─────────────────────────────────────────────────────────────────────────────
// Message Model (from GET /chat-rooms/{id}/messages)
// ─────────────────────────────────────────────────────────────────────────────

class MessageModel extends Equatable {
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

  const MessageModel({
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

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as int,
      clientMessageId: json['clientMessageId'] as String? ?? '',
      senderId: json['senderId']?.toString() ?? '',
      senderName: json['senderName'] as String? ?? '',
      content: json['content'] as String?,
      type: MessageType.values[json['type'] as int? ?? 0],
      sentAt: DateTime.parse(json['sentAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
      isOwner: json['isOwner'] as bool? ?? false,
      attachmentUrl: json['attachmentUrl'] as String?,
      deliveryStatus: json['deliveryStatus'] != null
          ? MessageDeliveryStatus.values[json['deliveryStatus'] as int]
          : (json['isRead'] == true
              ? MessageDeliveryStatus.read
              : MessageDeliveryStatus.sent),
    );
  }

  MessageModel copyWith({
    bool? isRead,
    DateTime? readAt,
    bool? isOwner,
    MessageDeliveryStatus? deliveryStatus,
  }) {
    return MessageModel(
      id: id,
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
// Initiate Message Response (from POST /chat/initiate-message)
// ─────────────────────────────────────────────────────────────────────────────

class InitiateMessageResponse extends Equatable {
  final int chatRoomId;
  final int messageId;
  final bool isNewRoom;

  const InitiateMessageResponse({
    required this.chatRoomId,
    required this.messageId,
    required this.isNewRoom,
  });

  factory InitiateMessageResponse.fromJson(Map<String, dynamic> json) {
    return InitiateMessageResponse(
      chatRoomId: json['chatRoomId'] as int,
      messageId: json['messageId'] as int,
      isNewRoom: json['isNewRoom'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [chatRoomId, messageId, isNewRoom];
}

// ─────────────────────────────────────────────────────────────────────────────
// Paginated Chat List Response (wraps paginated result for chat models)
// ─────────────────────────────────────────────────────────────────────────────

class PaginatedChatRooms extends Equatable {
  final List<ChatRoomModel> items;
  final int pageNumber;
  final int totalPages;
  final bool hasPreviousPage;
  final bool hasNextPage;

  const PaginatedChatRooms({
    required this.items,
    required this.pageNumber,
    required this.totalPages,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory PaginatedChatRooms.fromJson(Map<String, dynamic> json) {
    return PaginatedChatRooms(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) =>
                  ChatRoomModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pageNumber: json['pageNumber'] as int? ?? 1,
      totalPages: json['totalPages'] as int? ?? 1,
      hasPreviousPage: json['hasPreviousPage'] as bool? ?? false,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props =>
      [items, pageNumber, totalPages, hasPreviousPage, hasNextPage];
}

// ─────────────────────────────────────────────────────────────────────────────
// Paginated Messages Response
// ─────────────────────────────────────────────────────────────────────────────

class PaginatedMessages extends Equatable {
  final List<MessageModel> items;
  final int pageNumber;
  final int totalPages;
  final bool hasPreviousPage;
  final bool hasNextPage;

  const PaginatedMessages({
    required this.items,
    required this.pageNumber,
    required this.totalPages,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory PaginatedMessages.fromJson(Map<String, dynamic> json) {
    return PaginatedMessages(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) =>
                  MessageModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pageNumber: json['pageNumber'] as int? ?? 1,
      totalPages: json['totalPages'] as int? ?? 1,
      hasPreviousPage: json['hasPreviousPage'] as bool? ?? false,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props =>
      [items, pageNumber, totalPages, hasPreviousPage, hasNextPage];
}
