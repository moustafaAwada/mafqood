import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mafqood/core/database/cache/cache_helper.dart';
import 'package:mafqood/features/chat/data/models/chat_enums.dart';
import 'package:mafqood/features/chat/data/models/chat_models.dart';
import 'package:mafqood/features/chat/data/models/signalr_dtos.dart';
import 'package:mafqood/features/chat/data/services/chat_hub_service.dart';
import 'package:mafqood/features/chat/domain/entities/chat_entities.dart';
import 'package:mafqood/features/chat/domain/repositories/chat_repository.dart';
import 'package:mafqood/features/chat/presentation/cubit/chat_state.dart';
import 'package:uuid/uuid.dart';

// Re-export for convenience
export 'package:mafqood/features/chat/data/services/chat_hub_service.dart' show HubConnectionStatus;

const _outboxCacheKey = 'chat_outbox_queue';
const _uuid = Uuid();

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;
  final ChatHubService _hubService;
  final CacheHelper _cacheHelper;

  Timer? _typingDebounceTimer;

  static int _compareMessages(MessageEntity a, MessageEntity b) {
    final byTime = a.sentAt.compareTo(b.sentAt);
    if (byTime != 0) return byTime;
    final byId = a.id.compareTo(b.id);
    if (byId != 0) return byId;
    return a.clientMessageId.compareTo(b.clientMessageId);
  }

  static List<MessageEntity> _dedupAndSortByClientMessageId(
    Iterable<MessageEntity> input,
  ) {
    final byClientId = <String, MessageEntity>{};
    for (final m in input) {
      final existing = byClientId[m.clientMessageId];
      if (existing == null) {
        byClientId[m.clientMessageId] = m;
        continue;
      }

      // Prefer the non-temp server message over optimistic/outbox temp (-1),
      // BUT preserve isOwner from the optimistic message (backend sends wrong isOwner)
      MessageEntity pick;
      if (existing.id == -1 && m.id != -1) {
        // Server message replaces temp, but preserve correct isOwner from optimistic
        pick = m.copyWith(isOwner: existing.isOwner || m.isOwner);
      } else if (m.id == -1 && existing.id != -1) {
        // Temp message, keep existing server message but preserve isOwner
        pick = existing.copyWith(isOwner: existing.isOwner || m.isOwner);
      } else {
        // Both have real IDs or both are temp.
        // Prefer the one that is 'read', then 'delivered', then later sentAt.
        if (existing.isRead && !m.isRead) {
          pick = existing;
        } else if (m.isRead && !existing.isRead) {
          pick = m;
        } else if (existing.deliveryStatus.index > m.deliveryStatus.index) {
          pick = existing;
        } else if (m.deliveryStatus.index > existing.deliveryStatus.index) {
          pick = m;
        } else {
          pick = m.sentAt.isAfter(existing.sentAt) ? m : existing;
        }
      }
      byClientId[m.clientMessageId] = pick;
    }

    final list = byClientId.values.toList()..sort(_compareMessages);
    return list;
  }

  ChatCubit({
    required ChatRepository repository,
    required ChatHubService hubService,
    required CacheHelper cacheHelper,
  })  : _repository = repository,
        _hubService = hubService,
        _cacheHelper = cacheHelper,
        super(const ChatState()) {
    _setupHubListeners();
    _loadOutboxFromCache();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════════════════════════

  void _setupHubListeners() {
    _hubService.onMessageReceived = _onMessageReceived;
    _hubService.onMessageUpdated = _onMessageUpdated;
    _hubService.onChatRoomCreated = _onChatRoomCreated;
    _hubService.onUserTyping = _onUserTyping;
    _hubService.onUserStoppedTyping = _onUserStoppedTyping;
    _hubService.onUserPresenceChanged = _onPresenceChanged;
    _hubService.onReconnected = _onReconnected;
  }

  Future<void> _loadOutboxFromCache() async {
    try {
      final raw = _cacheHelper.getDataString(key: _outboxCacheKey);
      if (raw == null || raw.isEmpty) return;
      final list = (jsonDecode(raw) as List)
          .map((e) => OutboxMessage.fromJson(e as Map<String, dynamic>))
          .toList();
      emit(state.copyWith(outboxQueue: list));
    } catch (e) {
      debugPrint('Failed to load outbox: $e');
    }
  }

  Future<void> _saveOutboxToCache() async {
    final json = jsonEncode(state.outboxQueue.map((m) => m.toJson()).toList());
    await _cacheHelper.saveData(key: _outboxCacheKey, value: json);
  }

  /// Connect the SignalR hub. Call after authentication.
  ///
  /// SignalR is optional — REST polling is the primary real-time mechanism.
  /// If SignalR connects, it provides instant updates. If not, polling
  /// handles everything transparently.
  Future<void> connectHub(String token) async {
    debugPrint('[ChatCubit] connectHub called (non-blocking)');

    // Listen to connection status changes
    _hubService.onStatusChanged = (status, message) {
      debugPrint('[ChatCubit] Hub status: $status');
      emit(state.copyWith(
        connectionStatus: status,
        connectionError: message,
      ));
    };

    // connect() no longer throws — it fails silently
    await _hubService.connect(token);
    
    if (_hubService.isConnected) {
      debugPrint('[ChatCubit] ✓ SignalR connected — real-time mode');
    } else {
      debugPrint('[ChatCubit] ⟳ SignalR unavailable — REST polling active');
    }
  }

  /// Disconnect the SignalR hub. Call on logout.
  Future<void> disconnectHub() async {
    await _hubService.disconnect();
  }

  /// Initiate a chat with a user from their profile page.
  /// Sends a default greeting and returns the [chatRoomId] for navigation,
  /// or `null` on failure.
  Future<int?> initiateChatWithUser(String userId) async {
    // Check if we already have a room with this user
    for (final room in state.rooms) {
      if (room.otherParticipant.id == userId) {
        return room.id;
      }
    }
    
    // Return -1 to indicate a new, empty chat room that will be created
    // upon sending the first message.
    return -1;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ROOM MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> fetchChatRooms({bool refresh = false}) async {
    if (state.isLoadingRooms) return;

    final page = refresh ? 1 : state.currentRoomPage;
    emit(state.copyWith(isLoadingRooms: true, clearError: true));

    final result = await _repository.getChatRooms(pageNumber: page);

    result.fold(
      (failure) => emit(state.copyWith(
        isLoadingRooms: false,
        error: failure.message,
      )),
      (paginated) {
        // Safety: Don't clear existing rooms if backend returns empty unexpectedly
        final isUnexpectedEmpty = paginated.items.isEmpty && 
                                   state.rooms.isNotEmpty && 
                                   refresh;
        
        final updatedRooms = refresh
            ? (isUnexpectedEmpty ? state.rooms : paginated.items)
            : [...state.rooms, ...paginated.items];

        // Merge server unread counts into local map
        final updatedUnreads = Map<int, int>.from(state.unreadCounts);
        for (final room in paginated.items) {
          updatedUnreads[room.id] = room.unreadCount;
        }

        emit(state.copyWith(
          rooms: updatedRooms,
          isLoadingRooms: false,
          hasMoreRooms: paginated.hasNextPage,
          currentRoomPage: page + 1,
          unreadCounts: updatedUnreads,
        ));
      },
    );
  }

  Future<void> loadMoreRooms() async {
    if (!state.hasMoreRooms || state.isLoadingRooms) return;
    await fetchChatRooms();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CONVERSATION MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> openConversation(int roomId, String recipientId) async {
    // If roomId is -1, this is a new conversation that doesn't exist on the server yet.
    if (roomId == -1) {
      emit(state.copyWith(
        currentOpenChatRoomId: null, // Keep null to signify it's not created yet
        currentRecipientId: recipientId,
        messages: const [],
        isLoadingMessages: false,
        currentMessagePage: 1,
        hasMoreMessages: false,
        clearError: true,
      ));
      return;
    }

    // Be explicit about group membership for reliability across reconnects.
    _hubService.joinChatRoom(roomId);

    emit(state.copyWith(
      currentOpenChatRoomId: roomId,
      currentRecipientId: recipientId,
      messages: const [],
      isLoadingMessages: true,
      currentMessagePage: 1,
      hasMoreMessages: true,
      clearError: true,
    ));

    // Fetch first page of messages
    final result = await _repository.getMessages(roomId, pageNumber: 1);

    result.fold(
      (failure) => emit(state.copyWith(
        isLoadingMessages: false,
        error: failure.message,
      )),
      (paginated) {
        final entities = paginated.items.map(_messageModelToEntity).toList();
        final sorted = _dedupAndSortByClientMessageId(entities);
        final latest = sorted.isEmpty ? null : sorted.last.sentAt;
        emit(state.copyWith(
          messages: sorted,
          isLoadingMessages: false,
          hasMoreMessages: paginated.hasNextPage,
          currentMessagePage: 2,
          lastSyncTimestamp: latest,
        ));
      },
    );

    // Note: Do NOT mark as read here. Messages sent by us should remain 
    // unread (isRead: false) until the OTHER person actually reads them.
    // The _onMessageUpdated event from SignalR will mark them as read 
    // when the recipient opens the chat.
  }

  Future<void> loadMoreMessages() async {
    final roomId = state.currentOpenChatRoomId;
    if (roomId == null || !state.hasMoreMessages || state.isLoadingMessages) {
      return;
    }

    emit(state.copyWith(isLoadingMessages: true));

    final result = await _repository.getMessages(
      roomId,
      pageNumber: state.currentMessagePage,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isLoadingMessages: false,
        error: failure.message,
      )),
      (paginated) {
        final older = paginated.items.map(_messageModelToEntity).toList();
        final merged = _dedupAndSortByClientMessageId([...state.messages, ...older]);
        final latest = merged.isEmpty ? state.lastSyncTimestamp : merged.last.sentAt;
        emit(state.copyWith(
          messages: merged,
          isLoadingMessages: false,
          hasMoreMessages: paginated.hasNextPage,
          currentMessagePage: state.currentMessagePage + 1,
          lastSyncTimestamp: latest,
        ));
      },
    );
  }

  void closeConversation() {
    final roomId = state.currentOpenChatRoomId;
    if (roomId != null) {
      _hubService.leaveChatRoom(roomId);
    }
    emit(state.copyWith(clearCurrentRoom: true));
  }

  /// Refresh messages to get new ones (used for REST polling when SignalR is disconnected)
  Future<void> refreshMessages() async {
    final roomId = state.currentOpenChatRoomId;
    if (roomId == null || state.isLoadingMessages) return;

    // Fetch first page to get new messages (page 1 has newest)
    final result = await _repository.getMessages(roomId, pageNumber: 1);

    result.fold(
      (failure) {
        // Silently fail - don't show error for background refresh
        debugPrint('[ChatCubit] refreshMessages failed: ${failure.message}');
      },
      (paginated) {
        final newMessages = paginated.items.map(_messageModelToEntity).toList();
        final merged = _dedupAndSortByClientMessageId([...newMessages, ...state.messages]);
        final latest = merged.isEmpty ? state.lastSyncTimestamp : merged.last.sentAt;
        
        // Always emit merged messages so read receipts and status updates
        // are reflected even if the total count hasn't changed.
        if (merged != state.messages) {
          debugPrint('[ChatCubit] refreshMessages: state updated');
          emit(state.copyWith(
            messages: merged,
            lastSyncTimestamp: latest,
          ));
        }
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MESSAGE SENDING — IDEMPOTENCY FLOW
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> sendMessage({
    required String recipientId,
    required String content,
    MessageType type = MessageType.text,
    String? attachmentPath,
  }) async {
    // 1. Generate UUID v4
    final clientMessageId = _uuid.v4();

    // 2. Track in pending set
    final updatedPending = Set<String>.from(state.pendingClientMessageIds)
      ..add(clientMessageId);

    // 3. Optimistic UI — add temp message
    final optimistic = MessageEntity(
      id: -1, // Temp ID, replaced on success
      clientMessageId: clientMessageId,
      senderId: '', // Will be resolved
      senderName: '',
      content: content,
      type: type,
      sentAt: DateTime.now(),
      isRead: false,
      isOwner: true,
      attachmentUrl: attachmentPath,
      deliveryStatus: MessageDeliveryStatus.sent,
    );

    emit(state.copyWith(
      messages: [...state.messages, optimistic],
      pendingClientMessageIds: updatedPending,
      isSendingMessage: true,
    ));

    // 4. Call REST
    final result = await _repository.initiateMessage(
      clientMessageId: clientMessageId,
      recipientUserId: recipientId,
      content: type == MessageType.text ? content : null,
      type: type,
      attachment: attachmentPath != null ? File(attachmentPath) : null,
    );

    result.fold(
      (failure) {
        // 6. On failure: add to outbox
        _addToOutbox(
          clientMessageId: clientMessageId,
          recipientId: recipientId,
          content: content,
          type: type,
          attachmentPath: attachmentPath,
        );
      },
      (response) {
        // 5. On success: update optimistic message with real ID
        final updatedMessages = state.messages.map((msg) {
          if (msg.clientMessageId == clientMessageId) {
            return msg.copyWith(
              id: response.messageId,
              deliveryStatus: MessageDeliveryStatus.sent,
            );
          }
          return msg;
        }).toList();

        // Update room list with new last message
        final updatedRooms = _updateRoomLastMessage(
          response.chatRoomId,
          content,
          type,
          DateTime.now(),
        );

        emit(state.copyWith(
          messages: updatedMessages,
          rooms: updatedRooms,
          isSendingMessage: false,
          currentOpenChatRoomId: state.currentOpenChatRoomId ?? response.chatRoomId,
        ));

        // If new room was created, join SignalR group
        if (response.isNewRoom) {
          _hubService.joinChatRoom(response.chatRoomId);
          // Refresh rooms to get the new room in the list
          fetchChatRooms(refresh: true);
        }
      },
    );
  }

  Future<void> deleteMessage(int messageId) async {
    final roomId = state.currentOpenChatRoomId;
    if (roomId == null) return;

    final result = await _repository.deleteMessage(roomId, messageId);
    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (_) {
        final updated =
            state.messages.where((m) => m.id != messageId).toList();
        emit(state.copyWith(messages: updated));
      },
    );
  }

  Future<void> deleteChatRoom(int roomId) async {
    final result = await _repository.deleteChatRoom(roomId);
    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (_) {
        final updated = state.rooms.where((r) => r.id != roomId).toList();
        emit(state.copyWith(rooms: updated));
        if (state.currentOpenChatRoomId == roomId) {
          closeConversation();
        }
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TYPING INDICATORS (OUTGOING)
  // ═══════════════════════════════════════════════════════════════════════════

  void sendTyping() {
    final roomId = state.currentOpenChatRoomId;
    if (roomId == null) {
      debugPrint('[ChatCubit] sendTyping: no current room');
      return;
    }

    debugPrint('[ChatCubit] sendTyping: roomId=$roomId, connected=${_hubService.isConnected}');
    _hubService.sendTypingIndicator(roomId);

    // Auto-stop after 3s of inactivity
    _typingDebounceTimer?.cancel();
    _typingDebounceTimer = Timer(const Duration(seconds: 3), () {
      _hubService.sendStoppedTypingIndicator(roomId);
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SIGNALR EVENT HANDLERS
  // ═══════════════════════════════════════════════════════════════════════════

  void _onMessageReceived(MessageReceivedDto dto) {
    debugPrint('[ChatCubit] _onMessageReceived: chatRoomId=${dto.chatRoomId}, senderId=${dto.senderId}, clientId=${dto.clientMessageId}');
    debugPrint('[ChatCubit] Current open room: ${state.currentOpenChatRoomId}, pending IDs: ${state.pendingClientMessageIds.length}');
    
    _markUserOnline(dto.senderId);

    // Idempotency: skip if we sent this message (we already have it)
    if (state.pendingClientMessageIds.contains(dto.clientMessageId)) {
      debugPrint('[ChatCubit] Message was sent by us, skipping (idempotency)');
      final updatedPending = Set<String>.from(state.pendingClientMessageIds)
        ..remove(dto.clientMessageId);
      emit(state.copyWith(pendingClientMessageIds: updatedPending));
      return;
    }

    final entity = MessageEntity(
      id: dto.id,
      clientMessageId: dto.clientMessageId,
      senderId: dto.senderId,
      senderName: dto.senderName,
      content: dto.content,
      type: dto.type,
      sentAt: dto.sentAt,
      isRead: false,
      isOwner: false,
      deliveryStatus: dto.deliveryStatus,
    );

    // Update room list: last message preview + re-sort
    final updatedRooms = _updateRoomLastMessage(
      dto.chatRoomId,
      dto.content ?? '',
      dto.type,
      dto.sentAt,
    );

    if (state.currentOpenChatRoomId == dto.chatRoomId) {
      // User is viewing this conversation — add message + auto-read
      debugPrint('[ChatCubit] User is viewing this conversation, adding message to UI');
      final merged = _dedupAndSortByClientMessageId([...state.messages, entity]);
      final latest =
          merged.isEmpty ? state.lastSyncTimestamp : merged.last.sentAt;
      emit(state.copyWith(
        messages: merged,
        rooms: updatedRooms,
        lastSyncTimestamp: latest,
      ));
      debugPrint('[ChatCubit] Message added to UI, total messages: ${merged.length}');
      _markAsReadAndClearUnread(dto.chatRoomId);
    } else {
      // Not in this conversation — increment unread count
      debugPrint('[ChatCubit] User not in this conversation, incrementing unread count');
      final updatedUnreads = Map<int, int>.from(state.unreadCounts);
      updatedUnreads[dto.chatRoomId] =
          (updatedUnreads[dto.chatRoomId] ?? 0) + 1;
      emit(state.copyWith(
        rooms: updatedRooms,
        unreadCounts: updatedUnreads,
      ));
    }
  }

  void _onMessageUpdated(MessageUpdatedDto dto) {
    switch (dto.updateType) {
      case MessageUpdateType.read:
        if (dto.readByUserId != null) {
          _markUserOnline(dto.readByUserId!);
        }
        // Mark all our sent messages in this room as read
        if (state.currentOpenChatRoomId == dto.chatRoomId) {
          final updated = state.messages.map((msg) {
            if (msg.isOwner && !msg.isRead) {
              return msg.copyWith(
                isRead: true,
                readAt: dto.readAt,
                deliveryStatus: MessageDeliveryStatus.read,
              );
            }
            return msg;
          }).toList();
          emit(state.copyWith(messages: updated));
        }
        break;

      case MessageUpdateType.deleted:
        if (state.currentOpenChatRoomId == dto.chatRoomId &&
            dto.messageId != null) {
          final updated =
              state.messages.where((m) => m.id != dto.messageId).toList();
          emit(state.copyWith(messages: updated));
        }
        break;

      case MessageUpdateType.delivered:
        if (state.currentOpenChatRoomId == dto.chatRoomId) {
          final updated = state.messages.map((msg) {
            if (msg.isOwner &&
                msg.deliveryStatus == MessageDeliveryStatus.sent) {
              return msg.copyWith(
                deliveryStatus: MessageDeliveryStatus.delivered,
              );
            }
            return msg;
          }).toList();
          emit(state.copyWith(messages: updated));
        }
        break;
    }
  }

  void _onChatRoomCreated(ChatRoomCreatedDto dto) {
    debugPrint('[ChatCubit] _onChatRoomCreated: chatRoomId=${dto.chatRoomId}, createdBy=${dto.createdByUserId}');
    // Join the new room's SignalR group
    _hubService.joinChatRoom(dto.chatRoomId);

    // Add room to list
    final newRoom = ChatRoomModel(
      id: dto.chatRoomId,
      createdAt: dto.createdAt,
      otherParticipant: ParticipantModel(
        id: dto.createdByUserId,
        name: dto.createdByUserName,
        profilePictureUrl: dto.createdByUserProfilePictureUrl,
      ),
      unreadCount: 0,
    );

    emit(state.copyWith(rooms: [newRoom, ...state.rooms]));
  }

  void _onUserTyping(TypingDto dto) {
    debugPrint('[ChatCubit] _onUserTyping: chatRoomId=${dto.chatRoomId}, userId=${dto.userId}');
    _markUserOnline(dto.userId);
    final updated = Map<int, Set<String>>.from(state.typingIndicators);
    updated[dto.chatRoomId] = Set<String>.from(updated[dto.chatRoomId] ?? {})..add(dto.userId);
    emit(state.copyWith(typingIndicators: updated));

    // Auto-clear after 5s if no stop event received
    Future.delayed(const Duration(seconds: 5), () {
      if (state.typingIndicators[dto.chatRoomId]?.contains(dto.userId) == true) {
        final cleared = Map<int, Set<String>>.from(state.typingIndicators);
        cleared[dto.chatRoomId] = Set<String>.from(cleared[dto.chatRoomId] ?? {})..remove(dto.userId);
        if (cleared[dto.chatRoomId]!.isEmpty) cleared.remove(dto.chatRoomId);
        emit(state.copyWith(typingIndicators: cleared));
      }
    });
  }

  void _onUserStoppedTyping(TypingDto dto) {
    debugPrint('[ChatCubit] _onUserStoppedTyping: chatRoomId=${dto.chatRoomId}');
    final updated = Map<int, Set<String>>.from(state.typingIndicators);
    updated[dto.chatRoomId] = Set<String>.from(updated[dto.chatRoomId] ?? {})..remove(dto.userId);
    if (updated[dto.chatRoomId]!.isEmpty) updated.remove(dto.chatRoomId);
    emit(state.copyWith(typingIndicators: updated));
  }

  void _markUserOnline(String userId) {
    if (userId.isEmpty) return;
    if (!state.onlineUsers.contains(userId)) {
      final updated = Set<String>.from(state.onlineUsers)..add(userId);
      emit(state.copyWith(onlineUsers: updated));
    }
  }

  void _onPresenceChanged(UserPresenceDto dto) {
    final updated = Set<String>.from(state.onlineUsers);
    if (dto.isOnline) {
      updated.add(dto.userId);
    } else {
      updated.remove(dto.userId);
    }
    emit(state.copyWith(onlineUsers: updated));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // OFFLINE OUTBOX
  // ═══════════════════════════════════════════════════════════════════════════

  void _addToOutbox({
    required String clientMessageId,
    required String recipientId,
    required String content,
    required MessageType type,
    String? attachmentPath,
  }) {
    final outboxMsg = OutboxMessage(
      chatRoomId: state.currentOpenChatRoomId,
      clientMessageId: clientMessageId,
      recipientUserId: recipientId,
      content: content,
      type: type,
      attachmentPath: attachmentPath,
      createdAt: DateTime.now(),
      status: OutboxMessageStatus.pending,
    );

    final updatedQueue = [...state.outboxQueue, outboxMsg];
    emit(state.copyWith(outboxQueue: updatedQueue, isSendingMessage: false));
    _saveOutboxToCache();
  }

  Future<void> flushOutbox() async {
    if (state.outboxQueue.isEmpty) return;

    final pending = List<OutboxMessage>.from(state.outboxQueue);
    final remaining = <OutboxMessage>[];

    for (final msg in pending) {
      // Mark as sending in-memory (best-effort UI signal).
      remaining.add(msg.copyWith(status: OutboxMessageStatus.sending));

      final result = await _repository.initiateMessage(
        clientMessageId: msg.clientMessageId,
        recipientUserId: msg.recipientUserId,
        content: msg.type == MessageType.text ? msg.content : null,
        type: msg.type,
        attachment:
            msg.attachmentPath != null ? File(msg.attachmentPath!) : null,
      );

      result.fold(
        (_) {
          // Replace the sending marker with failed.
          remaining
            ..removeWhere((m) => m.clientMessageId == msg.clientMessageId)
            ..add(msg.copyWith(status: OutboxMessageStatus.failed));
        },
        (response) {
          // Success — remove pending ID
          final p = Set<String>.from(state.pendingClientMessageIds)
            ..remove(msg.clientMessageId);
          emit(state.copyWith(pendingClientMessageIds: p));

          // Remove from remaining (it was added as sending)
          remaining.removeWhere((m) => m.clientMessageId == msg.clientMessageId);

          // If we are currently in this conversation, replace the temp message id.
          if (state.currentOpenChatRoomId == response.chatRoomId) {
            final updatedMessages = state.messages.map((m) {
              if (m.clientMessageId == msg.clientMessageId) {
                return m.copyWith(id: response.messageId);
              }
              return m;
            }).toList();
            final merged = _dedupAndSortByClientMessageId(updatedMessages);
            final latest =
                merged.isEmpty ? state.lastSyncTimestamp : merged.last.sentAt;
            emit(state.copyWith(messages: merged, lastSyncTimestamp: latest));
          }
        },
      );
    }

    emit(state.copyWith(outboxQueue: remaining));
    _saveOutboxToCache();
  }

  Future<void> retryFailedMessage(String clientMessageId) async {
    final msg = state.outboxQueue.where((m) => m.clientMessageId == clientMessageId).firstOrNull;
    if (msg == null) return;

    // IMPORTANT: retry must reuse the same clientMessageId (idempotency).
    final updatedQueue = state.outboxQueue.map((m) {
      if (m.clientMessageId == clientMessageId) {
        return m.copyWith(status: OutboxMessageStatus.sending);
      }
      return m;
    }).toList();
    emit(state.copyWith(outboxQueue: updatedQueue));
    _saveOutboxToCache();

    final result = await _repository.initiateMessage(
      clientMessageId: msg.clientMessageId,
      recipientUserId: msg.recipientUserId,
      content: msg.type == MessageType.text ? msg.content : null,
      type: msg.type,
      attachment:
          msg.attachmentPath != null ? File(msg.attachmentPath!) : null,
    );

    result.fold(
      (_) {
        final failedQueue = state.outboxQueue.map((m) {
          if (m.clientMessageId == clientMessageId) {
            return m.copyWith(status: OutboxMessageStatus.failed);
          }
          return m;
        }).toList();
        emit(state.copyWith(outboxQueue: failedQueue));
        _saveOutboxToCache();
      },
      (response) {
        // Remove from outbox on success.
        final cleared =
            state.outboxQueue.where((m) => m.clientMessageId != clientMessageId).toList();
        emit(state.copyWith(outboxQueue: cleared));
        _saveOutboxToCache();

        // Replace temp message id if present in current messages.
        if (state.currentOpenChatRoomId == response.chatRoomId) {
          final updatedMessages = state.messages.map((m) {
            if (m.clientMessageId == clientMessageId) {
              return m.copyWith(id: response.messageId);
            }
            return m;
          }).toList();
          final merged = _dedupAndSortByClientMessageId(updatedMessages);
          final latest =
              merged.isEmpty ? state.lastSyncTimestamp : merged.last.sentAt;
          emit(state.copyWith(messages: merged, lastSyncTimestamp: latest));
        }
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // RECONNECTION HANDLER
  // ═══════════════════════════════════════════════════════════════════════════

  void _onReconnected() {
    debugPrint('[ChatCubit] _onReconnected: flushing outbox & syncing');
    flushOutbox();

    // Sync missed messages if we have a timestamp
    if (state.currentOpenChatRoomId != null &&
        state.lastSyncTimestamp != null) {
      _syncMissedMessages(
          state.currentOpenChatRoomId!, state.lastSyncTimestamp!);
    }
  }

  Future<void> _syncMissedMessages(
      int roomId, DateTime afterTimestamp) async {
    final result = await _repository.getMessages(
      roomId,
      afterTimestamp: afterTimestamp,
      pageSize: 50,
    );

    result.fold(
      (_) {},
      (paginated) {
        final newMessages = paginated.items.map(_messageModelToEntity).toList();
        final merged = _dedupAndSortByClientMessageId([
          ...state.messages,
          ...newMessages,
        ]);
        final latest = merged.isEmpty ? state.lastSyncTimestamp : merged.last.sentAt;
        if (merged.length != state.messages.length) {
          emit(state.copyWith(
            messages: merged,
            lastSyncTimestamp: latest,
          ));
        }
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _markAsReadAndClearUnread(int roomId) async {
    _repository.markMessagesAsRead(roomId);
    final updatedUnreads = Map<int, int>.from(state.unreadCounts);
    updatedUnreads[roomId] = 0;
    emit(state.copyWith(unreadCounts: updatedUnreads));
  }

  MessageEntity _messageModelToEntity(MessageModel model) {
    return MessageEntity(
      id: model.id,
      clientMessageId: model.clientMessageId,
      senderId: model.senderId,
      senderName: model.senderName,
      content: model.content,
      type: model.type,
      sentAt: model.sentAt,
      isRead: model.isRead,
      readAt: model.readAt,
      isOwner: model.isOwner,
      attachmentUrl: model.attachmentUrl,
      deliveryStatus: model.deliveryStatus,
    );
  }

  List<ChatRoomModel> _updateRoomLastMessage(
    int chatRoomId,
    String content,
    MessageType type,
    DateTime sentAt,
  ) {
    final rooms = state.rooms.map((room) {
      if (room.id == chatRoomId) {
        return room.copyWith(
          lastMessage: LastMessageModel(
            content: content,
            type: type,
            sentAt: sentAt,
          ),
        );
      }
      return room;
    }).toList();

    // Re-sort: most recent message first
    rooms.sort((a, b) {
      final aTime = a.lastMessage?.sentAt ?? a.createdAt;
      final bTime = b.lastMessage?.sentAt ?? b.createdAt;
      return bTime.compareTo(aTime);
    });

    return rooms;
  }

  void clearError() => emit(state.copyWith(clearError: true));

  @override
  Future<void> close() {
    _typingDebounceTimer?.cancel();
    return super.close();
  }
}
