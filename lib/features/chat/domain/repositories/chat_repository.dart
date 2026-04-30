import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:mafqood/core/error/failures.dart';
import 'package:mafqood/features/chat/data/models/chat_enums.dart';
import 'package:mafqood/features/chat/data/models/chat_models.dart';

/// Abstract contract for all chat-related data operations.
///
/// All methods return `Either<Failure, T>` consistent with the project's
/// Clean Architecture error handling pattern (see [PostRepository],
/// [AuthRepository], [AccountRepository]).
abstract class ChatRepository {
  // ─── Chat Room Operations ───────────────────────────────────────────────

  /// Fetch paginated list of chat rooms for the current user.
  ///
  /// - [pageNumber] / [pageSize]: pagination controls.
  /// - [searchKey]: optional filter by other participant's name or phone.
  /// - [filter]: `ChatRoomFilter.all` or `ChatRoomFilter.unread`.
  Future<Either<Failure, PaginatedChatRooms>> getChatRooms({
    int pageNumber = 1,
    int pageSize = 10,
    String? searchKey,
    ChatRoomFilter filter = ChatRoomFilter.all,
  });

  /// Fetch detailed info for a single chat room.
  Future<Either<Failure, ChatRoomDetailModel>> getChatRoomById(int chatRoomId);

  /// Delete a chat room and all its messages.
  ///
  /// Only participants can delete. Returns [Unit] on success.
  Future<Either<Failure, Unit>> deleteChatRoom(int chatRoomId);

  // ─── Message Operations ─────────────────────────────────────────────────

  /// Fetch paginated messages for a specific chat room.
  ///
  /// - [afterTimestamp]: for offline sync — fetches only messages sent AFTER
  ///   this time. Pass the `sentAt` of the last known message on reconnect.
  /// - [typeFilter]: optional filter by [MessageType].
  Future<Either<Failure, PaginatedMessages>> getMessages(
    int chatRoomId, {
    int pageNumber = 1,
    int pageSize = 20,
    MessageType? typeFilter,
    DateTime? afterTimestamp,
  });

  /// Send a message via the idempotent `initiate-message` endpoint.
  ///
  /// This is the ONLY way to send messages — never use SignalR for sending.
  ///
  /// - [clientMessageId]: UUID v4 generated BEFORE calling this method.
  ///   Reuse the same UUID on retry to guarantee idempotency.
  /// - [recipientUserId]: target user's ID (must not be self).
  /// - [content]: required for text messages, max 2000 chars.
  /// - [type]: message type (text or image for this phase).
  /// - [attachment]: required for non-text messages (image file).
  Future<Either<Failure, InitiateMessageResponse>> initiateMessage({
    required String clientMessageId,
    required String recipientUserId,
    String? content,
    required MessageType type,
    File? attachment,
  });

  /// Bulk mark ALL unread messages in a room as read.
  ///
  /// This triggers a `MessageUpdated` (updateType=Read) SignalR event
  /// to the other participant.
  Future<Either<Failure, Unit>> markMessagesAsRead(int chatRoomId);

  /// Delete a specific message. Only the sender can delete.
  ///
  /// This triggers a `MessageUpdated` (updateType=Deleted) SignalR event
  /// to the other participant.
  Future<Either<Failure, Unit>> deleteMessage(int chatRoomId, int messageId);
}
