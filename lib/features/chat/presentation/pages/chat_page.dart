import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mafqood/core/database/auth_storage.dart'; // Used by _ensureConnection
import 'package:mafqood/core/services/service_locator.dart';
import 'package:mafqood/features/chat/data/services/chat_hub_service.dart';
import 'package:mafqood/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:mafqood/features/chat/presentation/cubit/chat_state.dart';
import 'package:mafqood/features/chat/presentation/widgets/chat_item.dart';
import 'package:mafqood/features/chat/presentation/widgets/chat_search_bar.dart';
import 'package:mafqood/features/chat/presentation/widgets/empty_chat_state.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool _isSearching = false;
  String _searchQuery = '';
  final _scrollController = ScrollController();
  
  // REST polling timer — always active as primary real-time mechanism
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Fetch chat rooms when page opens
    context.read<ChatCubit>().fetchChatRooms(refresh: true);
    
    // Try SignalR in background (non-blocking, silent failure)
    _ensureConnection();
    
    // Start REST polling — this is the primary real-time mechanism
    // SignalR is a bonus optimization, not a requirement
    _startPolling();
  }
  
  void _startPolling() {
    // Poll every 5 seconds for smooth real-time feel.
    // When SignalR is connected, it provides instant updates and polling
    // is redundant but harmless (just re-confirms state).
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        context.read<ChatCubit>().fetchChatRooms(refresh: true);
      }
    });
  }
  
  Future<void> _ensureConnection() async {
    // If not connected, try to connect (don't block UI)
    if (!getIt<ChatHubService>().isConnected) {
      debugPrint('[ChatPage] SignalR not connected on open, attempting reconnect');
      final token = await getIt<AuthStorage>().getToken();
      if (token != null && mounted) {
        // Don't await - let it connect in background
        context.read<ChatCubit>().connectHub(token);
      }
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }
  
  // Diagnostics hidden behind long-press (for developers only)
  void _showDiagnosticsDialog() {
    final hubService = getIt<ChatHubService>();
    final log = hubService.connectionLog;
    final diagnostics = hubService.getDiagnostics();
    final actualStatus = hubService.status;
    final actualConnected = hubService.isConnected;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connection Diagnostics'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Real-time: ${actualConnected ? "SignalR ✓" : "REST Polling ⟳"}'),
              Text('Status: ${actualStatus.toString().split('.').last}'),
              Text('Connection ID: ${diagnostics['connectionId'] ?? 'N/A'}'),
              const Divider(),
              const Text('Recent Logs:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: log.length,
                  itemBuilder: (context, index) {
                    final entry = log[log.length - 1 - index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${entry['timestamp'].toString().substring(11, 19)}: ${entry['event']}',
                        style: TextStyle(
                          fontSize: 11,
                          color: entry.containsKey('error') ? Colors.red : Colors.black87,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ChatCubit>().loadMoreRooms();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: ChatSearchBar(
          isSearching: _isSearching,
          searchQuery: _searchQuery,
          onSearchChanged: (value) => setState(() => _searchQuery = value),
          onToggleSearch: () => setState(() => _isSearching = !_isSearching),
        ),
        body: GestureDetector(
          // Long-press anywhere on the page to open diagnostics (dev only)
          onLongPress: _showDiagnosticsDialog,
          child: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatCubit, ChatState>(
          builder: (context, state) {
            // Filter rooms by search query (client-side)
            final rooms = _searchQuery.isEmpty
                ? state.rooms
                : state.rooms
                    .where((r) =>
                        r.otherParticipant.name
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()))
                    .toList();

            // Show loading indicator
            if (state.isLoadingRooms && state.rooms.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            
            // Show error if there is one
            if (state.error != null && state.rooms.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading chats:\n${state.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<ChatCubit>().fetchChatRooms(refresh: true),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (rooms.isEmpty) {
              return EmptyChatState(searchQuery: _searchQuery);
            }

            return RefreshIndicator(
              onRefresh: () =>
                  context.read<ChatCubit>().fetchChatRooms(refresh: true),
              child: ListView.separated(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                itemCount: rooms.length + (state.hasMoreRooms ? 1 : 0),
                separatorBuilder: (_, _2) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  if (index >= rooms.length) {
                    // Loading indicator at bottom
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  final room = rooms[index];
                  return ChatItem(
                    room: room,
                    unreadCount: state.unreadCounts[room.id] ?? 0,
                    isOnline: state.onlineUsers
                        .contains(room.otherParticipant.id),
                    isTyping:
                        state.typingIndicators[room.id] == true,
                  );
                },
              ),
            );
          },
        ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
