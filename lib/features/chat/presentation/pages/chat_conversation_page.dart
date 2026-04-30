import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mafqood/features/chat/data/models/chat_enums.dart';
import 'package:mafqood/features/chat/domain/entities/chat_entities.dart';
import 'package:mafqood/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:mafqood/features/chat/presentation/cubit/chat_state.dart';
import 'package:mafqood/features/chat/presentation/widgets/date_chip.dart';
import 'package:mafqood/features/chat/presentation/widgets/message_bubble.dart';
import 'package:mafqood/features/chat/presentation/widgets/message_input.dart';

class ChatConversationPage extends StatefulWidget {
  final int chatRoomId;
  final String recipientId;
  final String contactName;

  const ChatConversationPage({
    super.key,
    required this.chatRoomId,
    required this.recipientId,
    required this.contactName,
  });

  @override
  State<ChatConversationPage> createState() => _ChatConversationPageState();
}

class _ChatConversationPageState extends State<ChatConversationPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  ChatCubit? _chatCubit; // Save reference to avoid context access in dispose
  
  // REST polling timer for when SignalR is not connected
  Timer? _pollingTimer;

  static const _autoScrollThresholdPx = 120.0;

  // Show/hide scroll-to-bottom button
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    // Save cubit reference for use in dispose
    _chatCubit = context.read<ChatCubit>();
    _chatCubit!.openConversation(widget.chatRoomId, widget.recipientId);
    _scrollController.addListener(_onScroll);
    
    // Start REST polling as fallback when SignalR is not available
    _startPolling();
  }
  
  void _startPolling() {
    // Poll every 3 seconds for snappy message delivery without SignalR
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        _chatCubit?.refreshMessages();
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel(); // Stop polling timer
    // Use saved reference instead of context.read() to avoid crash
    _chatCubit?.closeConversation();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // With `reverse: true`, older messages live near maxScrollExtent.
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ChatCubit>().loadMoreMessages();
    }
    
    // Show/hide scroll-to-bottom button based on scroll position
    final isNearBottom = _scrollController.position.pixels <=
        _scrollController.position.minScrollExtent + _autoScrollThresholdPx + 100;
    if (_showScrollToBottom != !isNearBottom) {
      setState(() {
        _showScrollToBottom = !isNearBottom;
      });
    }
  }

  bool get _isNearBottom {
    if (!_scrollController.hasClients) return true;
    // In reverse mode, "bottom" is minScrollExtent.
    return _scrollController.position.pixels <=
        _scrollController.position.minScrollExtent + _autoScrollThresholdPx;
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    final target = _scrollController.position.minScrollExtent;
    if (!animated) {
      _scrollController.jumpTo(target);
      return;
    }
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Haptic feedback for better UX
    HapticFeedback.lightImpact();

    context.read<ChatCubit>().sendMessage(
          recipientId: widget.recipientId,
          content: text,
          type: MessageType.text,
        );
    _messageController.clear();

    // Scroll to bottom after sending (reverse mode → minScrollExtent).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_forward_ios,
                color: colorScheme.onPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          titleSpacing: 0,
          title: BlocBuilder<ChatCubit, ChatState>(
            buildWhen: (prev, curr) =>
                prev.onlineUsers != curr.onlineUsers ||
                prev.typingIndicators != curr.typingIndicators,
            builder: (context, state) {
              final isOnline =
                  state.onlineUsers.contains(widget.recipientId);
              final activeRoomId = state.currentOpenChatRoomId ?? widget.chatRoomId;
              final typingUsers = state.typingIndicators[activeRoomId] ?? {};
              final isTyping = typingUsers.contains(widget.recipientId);

              // Determine subtitle: only show typing/online status
              String statusText;
              if (isTyping) {
                statusText = 'يكتب...';
              } else if (isOnline) {
                statusText = 'متصل الآن';
              } else {
                statusText = 'غير متصل';
              }

              return Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor:
                        colorScheme.onPrimary.withValues(alpha: 0.1),
                    child: Text(
                      widget.contactName.isNotEmpty
                          ? widget.contactName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.contactName,
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                          Row(
                            children: [
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  statusText,
                                  style: TextStyle(
                                    color: colorScheme.onPrimary
                                        .withValues(alpha: 0.7),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.call_outlined,
                  color: colorScheme.onPrimary, size: 22),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.more_vert_rounded,
                  color: colorScheme.onPrimary),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            // Messages list
            Expanded(
              child: BlocConsumer<ChatCubit, ChatState>(
                listenWhen: (prev, curr) =>
                    prev.messages.length != curr.messages.length ||
                    prev.outboxQueue.length != curr.outboxQueue.length,
                listener: (context, state) {
                  if (_isNearBottom) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                    });
                  }
                },
                buildWhen: (prev, curr) =>
                    prev.messages != curr.messages ||
                    prev.isLoadingMessages != curr.isLoadingMessages ||
                    prev.outboxQueue != curr.outboxQueue,
                builder: (context, state) {
                  // Combine server messages + pending outbox for this room.
                  // Prefer filtering by roomId; fall back to recipient match for
                  // legacy/outbox items where roomId is unknown.
                  final activeRoomId = state.currentOpenChatRoomId ?? widget.chatRoomId;
                  final pendingForRoom = state.outboxQueue.where((o) {
                    final byRoom = o.chatRoomId == activeRoomId;
                    final byRecipient =
                        o.chatRoomId == null && o.recipientUserId == widget.recipientId;
                    return byRoom || byRecipient;
                  }).map((o) {
                    return MessageEntity(
                      id: -1,
                      clientMessageId: o.clientMessageId,
                      senderId: '',
                      senderName: '',
                      content: o.content,
                      type: o.type,
                      sentAt: o.createdAt,
                      isRead: false,
                      isOwner: true,
                      deliveryStatus: MessageDeliveryStatus.sent,
                    );
                  });

                  final combined = <MessageEntity>[
                    ...state.messages,
                    ...pendingForRoom,
                  ];

                  combined.sort((a, b) {
                    final byTime = a.sentAt.compareTo(b.sentAt);
                    if (byTime != 0) return byTime;
                    final byId = a.id.compareTo(b.id);
                    if (byId != 0) return byId;
                    return a.clientMessageId.compareTo(b.clientMessageId);
                  });

                  // For `reverse:true`, we want newest-first so the newest is at
                  // index 0 and appears at the bottom.
                  final displayMessages = combined.reversed.toList();

                  if (state.isLoadingMessages && displayMessages.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final itemCount =
                      displayMessages.length + (state.isLoadingMessages ? 1 : 0);

                  return ListView.builder(
                    reverse: true,
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      // Loading indicator for older messages (top) in reverse mode.
                      if (state.isLoadingMessages && index == itemCount - 1) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }

                      final adjustedIndex = index;
                      final message = displayMessages[adjustedIndex];

                      // Date chip based on render adjacency (newest→oldest).
                      final isLastItem = adjustedIndex == displayMessages.length - 1;
                      final showDate = isLastItem ||
                          message.sentAt.day !=
                              displayMessages[adjustedIndex + 1].sentAt.day ||
                          message.sentAt.month !=
                              displayMessages[adjustedIndex + 1].sentAt.month ||
                          message.sentAt.year !=
                              displayMessages[adjustedIndex + 1].sentAt.year;

                      // Outbox status detection
                      final outboxMsg = state.outboxQueue
                          .where((o) =>
                              o.clientMessageId == message.clientMessageId)
                          .firstOrNull;
                      final isPending = outboxMsg != null &&
                          outboxMsg.status == OutboxMessageStatus.pending;
                      final isFailed = outboxMsg != null &&
                          outboxMsg.status == OutboxMessageStatus.failed;

                      return Column(
                        key: ValueKey(message.clientMessageId),
                        children: [
                          if (showDate) DateChip(date: message.sentAt),
                          GestureDetector(
                            onLongPress: isFailed
                                ? () => context
                                    .read<ChatCubit>()
                                    .retryFailedMessage(message.clientMessageId)
                                : null,
                            child: AnimatedMessageBubble(
                              message: message,
                              isPending: isPending,
                              isFailed: isFailed,
                              index: index,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),

            // Scroll to bottom button
            if (_showScrollToBottom)
              Positioned(
                right: 16,
                bottom: 80,
                child: FloatingActionButton.small(
                  onPressed: () => _scrollToBottom(),
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.arrow_downward, color: Colors.black54),
                ),
              ),

            // Input area
            MessageInput(
              controller: _messageController,
              onSendMessage: _sendMessage,
              onTyping: () =>
                  context.read<ChatCubit>().sendTyping(),
            ),
          ],
        ),
      ),
    );
  }
}