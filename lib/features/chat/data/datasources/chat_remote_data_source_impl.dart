import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mafqood/core/api/api_consumer.dart';
import 'package:mafqood/core/api/end_points.dart';
import 'package:mafqood/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:mafqood/features/chat/data/models/chat_enums.dart';
import 'package:mafqood/features/chat/data/models/chat_models.dart';

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiConsumer _api;

  ChatRemoteDataSourceImpl({required ApiConsumer api}) : _api = api;

  // ─── Chat Room Operations ───────────────────────────────────────────────

  @override
  Future<PaginatedChatRooms> getChatRooms({
    int pageNumber = 1,
    int pageSize = 10,
    String? searchKey,
    ChatRoomFilter filter = ChatRoomFilter.all,
  }) async {
    final response = await _api.get(
      EndPoints.chatRooms,
      queryParameters: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        'filter': filter.index,
        if (searchKey != null && searchKey.trim().isNotEmpty)
          'searchKey': searchKey.trim(),
      },
    );

    final data =
        (response as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return PaginatedChatRooms.fromJson(data);
  }

  @override
  Future<ChatRoomDetailModel> getChatRoomById(int chatRoomId) async {
    final response = await _api.get(EndPoints.chatRoomById(chatRoomId));

    final data =
        (response as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return ChatRoomDetailModel.fromJson(data);
  }

  @override
  Future<void> deleteChatRoom(int chatRoomId) async {
    await _api.delete(EndPoints.chatRoomById(chatRoomId));
  }

  // ─── Message Operations ─────────────────────────────────────────────────

  @override
  Future<PaginatedMessages> getMessages(
    int chatRoomId, {
    int pageNumber = 1,
    int pageSize = 20,
    MessageType? typeFilter,
    DateTime? afterTimestamp,
  }) async {
    final response = await _api.get(
      EndPoints.chatRoomMessages(chatRoomId),
      queryParameters: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        if (typeFilter != null) 'typeFilter': typeFilter.index,
        if (afterTimestamp != null)
          'afterTimestamp': afterTimestamp.toUtc().toIso8601String(),
      },
    );

    final data =
        (response as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return PaginatedMessages.fromJson(data);
  }

  @override
  Future<InitiateMessageResponse> initiateMessage({
    required String clientMessageId,
    required String recipientUserId,
    String? content,
    required MessageType type,
    File? attachment,
  }) async {
    // Build multipart/form-data — backend always expects this format,
    // even for text-only messages (because the endpoint supports attachments).
    final formMap = <String, dynamic>{
      'ClientMessageId': clientMessageId,
      'RecipientUserId': recipientUserId,
      'Type': type.index,
      if (content != null) 'Content': content,
      if (attachment != null)
        'Attachment': MultipartFile.fromFileSync(
          attachment.path,
          filename: attachment.path.split(Platform.pathSeparator).last,
        ),
    };

    final response = await _api.post(
      EndPoints.initiateMessage,
      data: FormData.fromMap(formMap),
      isFormData: true,
    );

    final data =
        (response as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return InitiateMessageResponse.fromJson(data);
  }

  @override
  Future<void> markMessagesAsRead(int chatRoomId) async {
    await _api.put(EndPoints.markMessagesRead(chatRoomId));
  }

  @override
  Future<void> deleteMessage(int chatRoomId, int messageId) async {
    await _api.delete(EndPoints.deleteMessage(chatRoomId, messageId));
  }
}
