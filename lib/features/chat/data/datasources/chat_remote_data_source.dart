import 'dart:io';

import 'package:mafqood/features/chat/data/models/chat_enums.dart';
import 'package:mafqood/features/chat/data/models/chat_models.dart';

/// Abstract interface for chat-related remote API operations.
///
/// Methods return Data Models directly — error handling is delegated
/// to the repository layer via [ServerException] propagation.
abstract class ChatRemoteDataSource {
  // ─── Chat Room Operations ───────────────────────────────────────────────

  /// Fetch paginated chat rooms.
  Future<PaginatedChatRooms> getChatRooms({
    int pageNumber = 1,
    int pageSize = 10,
    String? searchKey,
    ChatRoomFilter filter = ChatRoomFilter.all,
  });

  /// Fetch single chat room details.
  Future<ChatRoomDetailModel> getChatRoomById(int chatRoomId);

  /// Delete a chat room.
  Future<void> deleteChatRoom(int chatRoomId);

  // ─── Message Operations ─────────────────────────────────────────────────

  /// Fetch paginated messages for a chat room.
  Future<PaginatedMessages> getMessages(
    int chatRoomId, {
    int pageNumber = 1,
    int pageSize = 20,
    MessageType? typeFilter,
    DateTime? afterTimestamp,
  });

  /// Send a message (idempotent, multipart/form-data).
  Future<InitiateMessageResponse> initiateMessage({
    required String clientMessageId,
    required String recipientUserId,
    String? content,
    required MessageType type,
    File? attachment,
  });

  /// Bulk mark all unread messages as read.
  Future<void> markMessagesAsRead(int chatRoomId);

  /// Delete a single message.
  Future<void> deleteMessage(int chatRoomId, int messageId);
}
