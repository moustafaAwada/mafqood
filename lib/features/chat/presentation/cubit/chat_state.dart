import 'package:equatable/equatable.dart';
import 'package:mafqood/features/chat/data/models/chat_models.dart';
import 'package:mafqood/features/chat/domain/entities/chat_entities.dart';
import 'package:mafqood/features/chat/data/services/chat_hub_service.dart';

class ChatState extends Equatable {
  // ─── SignalR Connection State ───────────────────────────────────────────
  final HubConnectionStatus connectionStatus;
  final String? connectionError;

  // ─── Room List ──────────────────────────────────────────────────────────
  final List<ChatRoomModel> rooms;
  final bool isLoadingRooms;
  final bool hasMoreRooms;
  final int currentRoomPage;

  // ─── Current Conversation ───────────────────────────────────────────────
  final int? currentOpenChatRoomId;
  final String? currentRecipientId;
  final List<MessageEntity> messages;
  final bool isLoadingMessages;
  final bool hasMoreMessages;
  final int currentMessagePage;

  // ─── Real-time State ────────────────────────────────────────────────────
  /// Set of clientMessageIds for messages we sent — used to skip our own
  /// MessageReceived echoes from SignalR (idempotency deduplication).
  final Set<String> pendingClientMessageIds;

  /// Client-computed unread counts per room (chatRoomId → count).
  final Map<int, int> unreadCounts;

  /// Set of user IDs currently online.
  final Set<String> onlineUsers;

  /// Typing indicators per room (chatRoomId → set of userIds).
  final Map<int, Set<String>> typingIndicators;

  // ─── Offline State ──────────────────────────────────────────────────────
  final List<OutboxMessage> outboxQueue;
  final DateTime? lastSyncTimestamp;

  // ─── Error ──────────────────────────────────────────────────────────────
  final String? error;

  // ─── Sending state ──────────────────────────────────────────────────────
  final bool isSendingMessage;

  const ChatState({
    this.connectionStatus = HubConnectionStatus.disconnected,
    this.connectionError,
    this.rooms = const [],
    this.isLoadingRooms = false,
    this.hasMoreRooms = true,
    this.currentRoomPage = 1,
    this.currentOpenChatRoomId,
    this.currentRecipientId,
    this.messages = const [],
    this.isLoadingMessages = false,
    this.hasMoreMessages = true,
    this.currentMessagePage = 1,
    this.pendingClientMessageIds = const {},
    this.unreadCounts = const {},
    this.onlineUsers = const {},
    this.typingIndicators = const {},
    this.outboxQueue = const [],
    this.lastSyncTimestamp,
    this.error,
    this.isSendingMessage = false,
  });

  /// Whether the user is currently viewing a specific conversation.
  bool get isInConversationView => currentOpenChatRoomId != null;

  ChatState copyWith({
    HubConnectionStatus? connectionStatus,
    String? connectionError,
    bool clearConnectionError = false,
    List<ChatRoomModel>? rooms,
    bool? isLoadingRooms,
    bool? hasMoreRooms,
    int? currentRoomPage,
    int? currentOpenChatRoomId,
    String? currentRecipientId,
    List<MessageEntity>? messages,
    bool? isLoadingMessages,
    bool? hasMoreMessages,
    int? currentMessagePage,
    Set<String>? pendingClientMessageIds,
    Map<int, int>? unreadCounts,
    Set<String>? onlineUsers,
    Map<int, Set<String>>? typingIndicators,
    List<OutboxMessage>? outboxQueue,
    DateTime? lastSyncTimestamp,
    String? error,
    bool? isSendingMessage,
    // Nullable clear flags
    bool clearCurrentRoom = false,
    bool clearError = false,
  }) {
    return ChatState(
      connectionStatus: connectionStatus ?? this.connectionStatus,
      connectionError: clearConnectionError ? null : (connectionError ?? this.connectionError),
      rooms: rooms ?? this.rooms,
      isLoadingRooms: isLoadingRooms ?? this.isLoadingRooms,
      hasMoreRooms: hasMoreRooms ?? this.hasMoreRooms,
      currentRoomPage: currentRoomPage ?? this.currentRoomPage,
      currentOpenChatRoomId: clearCurrentRoom
          ? null
          : (currentOpenChatRoomId ?? this.currentOpenChatRoomId),
      currentRecipientId: clearCurrentRoom
          ? null
          : (currentRecipientId ?? this.currentRecipientId),
      messages: clearCurrentRoom ? const [] : (messages ?? this.messages),
      isLoadingMessages: clearCurrentRoom
          ? false
          : (isLoadingMessages ?? this.isLoadingMessages),
      hasMoreMessages: clearCurrentRoom
          ? true
          : (hasMoreMessages ?? this.hasMoreMessages),
      currentMessagePage: clearCurrentRoom
          ? 1
          : (currentMessagePage ?? this.currentMessagePage),
      pendingClientMessageIds:
          pendingClientMessageIds ?? this.pendingClientMessageIds,
      unreadCounts: unreadCounts ?? this.unreadCounts,
      onlineUsers: onlineUsers ?? this.onlineUsers,
      typingIndicators: typingIndicators ?? this.typingIndicators,
      outboxQueue: outboxQueue ?? this.outboxQueue,
      lastSyncTimestamp: lastSyncTimestamp ?? this.lastSyncTimestamp,
      error: clearError ? null : (error ?? this.error),
      isSendingMessage: isSendingMessage ?? this.isSendingMessage,
    );
  }

  @override
  List<Object?> get props => [
        connectionStatus,
        connectionError,
        rooms,
        isLoadingRooms,
        hasMoreRooms,
        currentRoomPage,
        currentOpenChatRoomId,
        currentRecipientId,
        messages,
        isLoadingMessages,
        hasMoreMessages,
        currentMessagePage,
        pendingClientMessageIds,
        unreadCounts,
        onlineUsers,
        typingIndicators,
        outboxQueue,
        lastSyncTimestamp,
        error,
        isSendingMessage,
      ];
}
