import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:mafqood/features/chat/data/models/chat_enums.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MessageReceived DTO (from SignalR `MessageReceived` event)
// ─────────────────────────────────────────────────────────────────────────────

class MessageReceivedDto extends Equatable {
  final int id;
  final int chatRoomId;
  final String clientMessageId;
  final String senderId;
  final String senderName;
  final String? senderProfilePictureUrl;
  final String? content;
  final MessageType type;
  final DateTime sentAt;
  final MessageDeliveryStatus deliveryStatus;

  const MessageReceivedDto({
    required this.id,
    required this.chatRoomId,
    required this.clientMessageId,
    required this.senderId,
    required this.senderName,
    this.senderProfilePictureUrl,
    this.content,
    required this.type,
    required this.sentAt,
    required this.deliveryStatus,
  });

  factory MessageReceivedDto.fromJson(Map<String, dynamic> json) {
    try {
      return MessageReceivedDto(
        id: _toInt(json['id']) ?? 0,
        chatRoomId: _toInt(json['chatRoomId']) ?? 0,
        clientMessageId: json['clientMessageId']?.toString() ?? '',
        senderId: json['senderId']?.toString() ?? '',
        senderName: json['senderName']?.toString() ?? '',
        senderProfilePictureUrl: json['senderProfilePictureUrl']?.toString(),
        content: json['content']?.toString(),
        type: _parseMessageType(json['type']),
        sentAt: _parseDateTime(json['sentAt']) ?? DateTime.now(),
        deliveryStatus: _parseDeliveryStatus(json['deliveryStatus']),
      );
    } catch (e, stackTrace) {
      debugPrint('MessageReceivedDto.fromJson ERROR: $e');
      debugPrint('JSON: $json');
      debugPrint('StackTrace: $stackTrace');
      // Return a minimal valid DTO to prevent crashes
      return MessageReceivedDto(
        id: 0,
        chatRoomId: 0,
        clientMessageId: '',
        senderId: '',
        senderName: 'Unknown',
        content: 'Error parsing message',
        type: MessageType.text,
        sentAt: DateTime.now(),
        deliveryStatus: MessageDeliveryStatus.sent,
      );
    }
  }

  @override
  List<Object?> get props => [
        id,
        chatRoomId,
        clientMessageId,
        senderId,
        senderName,
        senderProfilePictureUrl,
        content,
        type,
        sentAt,
        deliveryStatus,
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
// MessageUpdated DTO (from SignalR `MessageUpdated` event)
// ─────────────────────────────────────────────────────────────────────────────

class MessageUpdatedDto extends Equatable {
  final int chatRoomId;
  final MessageUpdateType updateType;
  final int? messageId;
  final String? readByUserId;
  final DateTime? readAt;
  final DateTime? timestamp;

  const MessageUpdatedDto({
    required this.chatRoomId,
    required this.updateType,
    this.messageId,
    this.readByUserId,
    this.readAt,
    this.timestamp,
  });

  factory MessageUpdatedDto.fromJson(Map<String, dynamic> json) {
    try {
      return MessageUpdatedDto(
        chatRoomId: _toInt(json['chatRoomId']) ?? 0,
        updateType: _parseMessageUpdateType(json['updateType']),
        messageId: _toInt(json['messageId']),
        readByUserId: json['readByUserId']?.toString(),
        readAt: _parseDateTime(json['readAt']),
        timestamp: _parseDateTime(json['timestamp']),
      );
    } catch (e, stackTrace) {
      debugPrint('MessageUpdatedDto.fromJson ERROR: $e');
      debugPrint('JSON: $json');
      debugPrint('StackTrace: $stackTrace');
      return MessageUpdatedDto(
        chatRoomId: 0,
        updateType: MessageUpdateType.delivered,
      );
    }
  }

  @override
  List<Object?> get props =>
      [chatRoomId, updateType, messageId, readByUserId, readAt, timestamp];
}

// ─────────────────────────────────────────────────────────────────────────────
// ChatRoomCreated DTO (from SignalR `ChatRoomCreated` event)
// ─────────────────────────────────────────────────────────────────────────────

class ChatRoomCreatedDto extends Equatable {
  final int chatRoomId;
  final DateTime createdAt;
  final String createdByUserId;
  final String createdByUserName;
  final String? createdByUserProfilePictureUrl;

  const ChatRoomCreatedDto({
    required this.chatRoomId,
    required this.createdAt,
    required this.createdByUserId,
    required this.createdByUserName,
    this.createdByUserProfilePictureUrl,
  });

  factory ChatRoomCreatedDto.fromJson(Map<String, dynamic> json) {
    try {
      return ChatRoomCreatedDto(
        chatRoomId: _toInt(json['chatRoomId']) ?? 0,
        createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
        createdByUserId: json['createdByUserId']?.toString() ?? '',
        createdByUserName: json['createdByUserName']?.toString() ?? '',
        createdByUserProfilePictureUrl:
            json['createdByUserProfilePictureUrl']?.toString(),
      );
    } catch (e, stackTrace) {
      debugPrint('ChatRoomCreatedDto.fromJson ERROR: $e');
      debugPrint('JSON: $json');
      debugPrint('StackTrace: $stackTrace');
      return ChatRoomCreatedDto(
        chatRoomId: 0,
        createdAt: DateTime.now(),
        createdByUserId: '',
        createdByUserName: 'Unknown',
      );
    }
  }

  @override
  List<Object?> get props => [
        chatRoomId,
        createdAt,
        createdByUserId,
        createdByUserName,
        createdByUserProfilePictureUrl,
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Typing DTO (from SignalR `UserTyping` / `UserStoppedTyping` events)
// ─────────────────────────────────────────────────────────────────────────────

class TypingDto extends Equatable {
  final int chatRoomId;
  final String userId;
  final String userName;

  const TypingDto({
    required this.chatRoomId,
    required this.userId,
    required this.userName,
  });

  factory TypingDto.fromJson(Map<String, dynamic> json) {
    try {
      return TypingDto(
        chatRoomId: _toInt(json['chatRoomId']) ?? 0,
        userId: json['userId']?.toString() ?? '',
        userName: json['userName']?.toString() ?? '',
      );
    } catch (e, stackTrace) {
      debugPrint('TypingDto.fromJson ERROR: $e');
      debugPrint('JSON: $json');
      debugPrint('StackTrace: $stackTrace');
      return TypingDto(
        chatRoomId: 0,
        userId: '',
        userName: 'Unknown',
      );
    }
  }

  @override
  List<Object?> get props => [chatRoomId, userId, userName];
}

// ─────────────────────────────────────────────────────────────────────────────
// UserPresence DTO (from SignalR `UserPresenceChanged` event)
// ─────────────────────────────────────────────────────────────────────────────

class UserPresenceDto extends Equatable {
  final String userId;
  final bool isOnline;
  final DateTime? timestamp;

  const UserPresenceDto({
    required this.userId,
    required this.isOnline,
    this.timestamp,
  });

  factory UserPresenceDto.fromJson(Map<String, dynamic> json) {
    try {
      return UserPresenceDto(
        userId: json['userId']?.toString() ?? '',
        isOnline: json['isOnline'] as bool? ?? false,
        timestamp: _parseDateTime(json['timestamp']),
      );
    } catch (e, stackTrace) {
      debugPrint('UserPresenceDto.fromJson ERROR: $e');
      debugPrint('JSON: $json');
      debugPrint('StackTrace: $stackTrace');
      return UserPresenceDto(
        userId: '',
        isOnline: false,
      );
    }
  }

  @override
  List<Object?> get props => [userId, isOnline, timestamp];
}

// ═════════════════════════════════════════════════════════════════════════════
// Helper Functions for Safe JSON Parsing
// ═════════════════════════════════════════════════════════════════════════════

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) {
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }
  return null;
}

MessageType _parseMessageType(dynamic value) {
  if (value == null) return MessageType.text;
  if (value is int && value >= 0 && value < MessageType.values.length) {
    return MessageType.values[value];
  }
  return MessageType.text;
}

MessageDeliveryStatus _parseDeliveryStatus(dynamic value) {
  if (value == null) return MessageDeliveryStatus.sent;
  if (value is int && value >= 0 && value < MessageDeliveryStatus.values.length) {
    return MessageDeliveryStatus.values[value];
  }
  return MessageDeliveryStatus.sent;
}

MessageUpdateType _parseMessageUpdateType(dynamic value) {
  if (value == null) return MessageUpdateType.delivered;
  if (value is int && value >= 0 && value < MessageUpdateType.values.length) {
    return MessageUpdateType.values[value];
  }
  return MessageUpdateType.delivered;
}
