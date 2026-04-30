import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mafqood/core/api/end_points.dart';
import 'package:mafqood/features/chat/data/models/signalr_dtos.dart';
import 'package:signalr_netcore/signalr_client.dart';

// SignalR Connection State for diagnostics
enum HubConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

/// Callback for connection status changes
typedef ConnectionStatusCallback = void Function(HubConnectionStatus status, String? message);

/// Real-time notification service for the Chat System via SignalR.
///
/// Follows the same architectural pattern as [PostInteractionHubService].
///
/// **Key principle from the Integration Guide:**
/// SignalR is a *thin notification layer* only — all writes go through REST.
/// This service receives 5 server→client events and exposes 4 client→server
/// hub methods (join/leave room, typing indicators).
class ChatHubService {
  HubConnection? _connection;
  
  // ═══════════════════════════════════════════════════════════════════════════
  // DIAGNOSTICS & LOGGING
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Current connection status for diagnostics
  HubConnectionStatus _status = HubConnectionStatus.disconnected;
  HubConnectionStatus get status => _status;
  
  /// Last error message for diagnostics
  String? _lastError;
  String? get lastError => _lastError;
  
  /// Connection history log for debugging
  final List<Map<String, dynamic>> _connectionLog = [];
  List<Map<String, dynamic>> get connectionLog => List.unmodifiable(_connectionLog);
  
  /// Callback for status changes (for UI updates)
  ConnectionStatusCallback? onStatusChanged;

  // ═══════════════════════════════════════════════════════════════════════════
  // AUTO-RECONNECT STATE
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Last token used for connection (needed for auto-reconnect)
  String? _lastToken;

  void _log(String event, {Map<String, dynamic>? data, String? error}) {
    final entry = {
      'timestamp': DateTime.now().toIso8601String(),
      'event': event,
      if (data != null) 'data': data,
      if (error != null) 'error': error,
    };
    _connectionLog.add(entry);
    debugPrint('[ChatHubService] $event ${data != null ? '- $data' : ''} ${error != null ? '- ERROR: $error' : ''}');
  }
  
  void _setStatus(HubConnectionStatus newStatus, {String? message}) {
    if (_status != newStatus) {
      _status = newStatus;
      _lastError = message;
      _log('STATUS_CHANGE', data: {'status': newStatus.toString(), 'message': message});
      onStatusChanged?.call(newStatus, message);
    }
  }

  // ─── Callbacks (assigned by ChatCubit) ──────────────────────────────────

  /// Fired when a new message arrives in any joined room.
  void Function(MessageReceivedDto)? onMessageReceived;

  /// Fired when a message is read, deleted, or delivery-confirmed.
  void Function(MessageUpdatedDto)? onMessageUpdated;

  /// Fired when the current user is added to a newly created chat room.
  void Function(ChatRoomCreatedDto)? onChatRoomCreated;

  /// Fired when another participant starts typing.
  void Function(TypingDto)? onUserTyping;

  /// Fired when another participant stops typing.
  void Function(TypingDto)? onUserStoppedTyping;

  /// Fired when a user goes online or offline.
  void Function(UserPresenceDto)? onUserPresenceChanged;

  /// Called when the connection is successfully re-established after a drop.
  /// The ChatCubit uses this to flush the outbox and sync missed messages.
  VoidCallback? onReconnected;

  /// Called when the connection is lost (before reconnect attempts).
  VoidCallback? onDisconnected;

  /// Called when connection state changes (for UI indicator)
  void Function(HubConnectionState)? onConnectionStateChanged;

  // ─── Connection State ───────────────────────────────────────────────────

  bool get isConnected =>
      _connection?.state == HubConnectionState.Connected;

  HubConnectionState get connectionState =>
      _connection?.state ?? HubConnectionState.Disconnected;

  // ─── Connection Lifecycle ───────────────────────────────────────────────

  /// Connect to the ChatHub with the user's Bearer token.
  ///
  /// The server auto-joins ALL of the user's existing chat rooms on connect,
  /// so no manual bulk-join is needed.
  Future<void> connect(String token) async {
    // Format token for logging (mask most of it)
    final displayToken = token.isNotEmpty 
        ? '${token.substring(0, token.length > 10 ? 10 : token.length)}... [${token.length} chars]' 
        : 'EMPTY';
    
    _log('CONNECT_START', data: {
      'hasToken': token.isNotEmpty,
      'tokenLength': token.length,
      'tokenPrefix': displayToken,
      'hubUrl': '${EndPoints.baseUrl}${EndPoints.chatHub}',
      'formattedWithBearer': !token.startsWith('Bearer '),
    });
    
    // Prevent double-connect
    if (_connection != null &&
        _connection!.state == HubConnectionState.Connected) {
      _log('CONNECT_ALREADY_CONNECTED');
      return;
    }
    
    _setStatus(HubConnectionStatus.connecting);

    
    // SignalR accessTokenFactory should return RAW token (without "Bearer " prefix)
    // The server extracts it from the query string: ?access_token=TOKEN
    final rawToken = token.startsWith('Bearer ') ? token.substring(7) : token;
    
    _log('TOKEN_PREPARED', data: {
      'originalLength': token.length,
      'rawLength': rawToken.length,
      'hasBearerPrefix': token.startsWith('Bearer '),
    });
    
    // Save token for auto-reconnect
    _lastToken = token;
    try {
      _connection = HubConnectionBuilder()
          .withUrl(
            '${EndPoints.baseUrl}${EndPoints.chatHub}',
            options: HttpConnectionOptions(
              accessTokenFactory: () async {
                _log('ACCESS_TOKEN_FACTORY_CALLED', data: {'tokenLength': rawToken.length});
                return rawToken;
              },
            ),
          )
          .withAutomaticReconnect(
            retryDelays: [2000, 5000, 10000, 20000], // Retry with delays
          )
          .build();
    } catch (e, stackTrace) {
      _setStatus(HubConnectionStatus.error, message: 'Build error: $e');
      _log('CONNECTION_BUILD_ERROR', error: '$e\n$stackTrace');
      rethrow;
    }

    // ── Register 5 server→client event listeners ──────────────────────
    _log('REGISTERING_EVENT_HANDLERS');

    _connection!.on('MessageReceived', (args) {
      _log('EVENT_MessageReceived', data: {'argsCount': args?.length ?? 0});
      final data = _asMap(args);
      if (data != null) {
        _log('EVENT_MessageReceived_PARSED', data: {'chatRoomId': data['chatRoomId'], 'senderId': data['senderId']});
        try {
          onMessageReceived?.call(MessageReceivedDto.fromJson(data));
          _log('EVENT_MessageReceived_HANDLED');
        } catch (e, stackTrace) {
          _log('EVENT_MessageReceived_ERROR', error: '$e\n$stackTrace');
        }
      } else {
        _log('EVENT_MessageReceived_NO_DATA', error: 'args could not be parsed: $args');
      }
    });

    _connection!.on('MessageUpdated', (args) {
      _log('EVENT_MessageUpdated', data: {'argsCount': args?.length ?? 0});
      final data = _asMap(args);
      if (data != null) {
        try {
          onMessageUpdated?.call(MessageUpdatedDto.fromJson(data));
          _log('EVENT_MessageUpdated_HANDLED', data: {'updateType': data['updateType']});
        } catch (e, stackTrace) {
          _log('EVENT_MessageUpdated_ERROR', error: '$e\n$stackTrace');
        }
      }
    });

    _connection!.on('ChatRoomCreated', (args) {
      _log('EVENT_ChatRoomCreated', data: {'argsCount': args?.length ?? 0});
      final data = _asMap(args);
      if (data != null) {
        try {
          onChatRoomCreated?.call(ChatRoomCreatedDto.fromJson(data));
          _log('EVENT_ChatRoomCreated_HANDLED', data: {'chatRoomId': data['chatRoomId']});
        } catch (e, stackTrace) {
          _log('EVENT_ChatRoomCreated_ERROR', error: '$e\n$stackTrace');
        }
      }
    });

    _connection!.on('UserTyping', (args) {
      _log('EVENT_UserTyping', data: {'argsCount': args?.length ?? 0});
      final data = _asMap(args);
      if (data != null) {
        try {
          onUserTyping?.call(TypingDto.fromJson(data));
          _log('EVENT_UserTyping_HANDLED', data: {'chatRoomId': data['chatRoomId'], 'userId': data['userId']});
        } catch (e, stackTrace) {
          _log('EVENT_UserTyping_ERROR', error: '$e\n$stackTrace');
        }
      }
    });

    _connection!.on('UserStoppedTyping', (args) {
      _log('EVENT_UserStoppedTyping', data: {'argsCount': args?.length ?? 0});
      final data = _asMap(args);
      if (data != null) {
        try {
          onUserStoppedTyping?.call(TypingDto.fromJson(data));
          _log('EVENT_UserStoppedTyping_HANDLED', data: {'chatRoomId': data['chatRoomId']});
        } catch (e, stackTrace) {
          _log('EVENT_UserStoppedTyping_ERROR', error: '$e\n$stackTrace');
        }
      }
    });

    _connection!.on('UserPresenceChanged', (args) {
      _log('EVENT_UserPresenceChanged', data: {'argsCount': args?.length ?? 0});
      final data = _asMap(args);
      if (data != null) {
        try {
          onUserPresenceChanged?.call(UserPresenceDto.fromJson(data));
          _log('EVENT_UserPresenceChanged_HANDLED', data: {'userId': data['userId'], 'isOnline': data['isOnline']});
        } catch (e, stackTrace) {
          _log('EVENT_UserPresenceChanged_ERROR', error: '$e\n$stackTrace');
        }
      }
    });

    // ── Backend error handler ────────────────────────────────────────
    // Listen for explicit backend errors (new feature)
    _connection!.on('ConnectionError', (args) {
      _log('EVENT_ConnectionError', data: {'argsCount': args?.length ?? 0});
      if (args != null && args.isNotEmpty) {
        final errorData = _asMap(args);
        if (errorData != null) {
          final message = errorData['message'] ?? 'Unknown backend error';
          final type = errorData['type'] ?? 'Unknown';
          final stackTrace = errorData['stackTrace'] ?? '';
          _log('BACKEND_ERROR_RECEIVED', 
            error: '🚨 BACKEND ERROR: $type\n$message\n$stackTrace',
            data: {'type': type, 'message': message},
          );
        }
      }
    });

    // ── Reconnection handlers ─────────────────────────────────────────

    _connection!.onreconnecting(({error}) {
      _setStatus(HubConnectionStatus.reconnecting, message: error?.toString());
      _log('ON_RECONNECTING', data: {'error': error?.toString()});
    });

    _connection!.onreconnected(({connectionId}) {
      _setStatus(HubConnectionStatus.connected);
      _log('ON_RECONNECTED', data: {'connectionId': connectionId});
      onReconnected?.call();
    });

    _connection!.onclose(({error}) {
      _setStatus(HubConnectionStatus.disconnected, message: error?.toString());
      _log('ON_CLOSE', data: {'error': error?.toString()});
      onDisconnected?.call();
      
      // Auto-reconnect after unexpected disconnection
      if (_lastToken != null) {
        _log('AUTO_RECONNECT_SCHEDULED', data: {'delaySeconds': 3});
        Future.delayed(const Duration(seconds: 3), () {
          if (_status == HubConnectionStatus.disconnected && _lastToken != null) {
            _log('AUTO_RECONNECT_EXECUTING');
            connect(_lastToken!);
          }
        });
      }
    });

    // ── Start connection — with retry logic ─────────────────────────────
    const maxRetries = 3;
    const retryDelays = [2000, 5000, 10000]; // 2s, 5s, 10s
    
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        _log('STARTING_CONNECTION_ATTEMPT', data: {'attempt': attempt + 1, 'maxRetries': maxRetries});
        
        final startFuture = _connection!.start();
        if (startFuture == null) {
          throw Exception('Connection start returned null');
        }
        await startFuture.timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('Connection timed out after 10 seconds.');
          },
        );
        
        _setStatus(HubConnectionStatus.connected);
        _log('CONNECTION_STARTED_SUCCESS', data: {
          'state': _connection!.state.toString(),
          'connectionId': _connection!.connectionId,
          'attempts': attempt + 1,
        });
        return; // Success! Exit the retry loop
        
      } catch (e) {
        final isLastAttempt = attempt == maxRetries - 1;
        _log('CONNECTION_ATTEMPT_FAILED', 
          data: {'attempt': attempt + 1, 'isLastAttempt': isLastAttempt},
          error: '$e',
        );
        
        if (isLastAttempt) {
          // All retries exhausted — fail silently
          _setStatus(HubConnectionStatus.disconnected);
          _log('CONNECTION_FAILED_SILENT_AFTER_RETRIES', 
            data: {'totalAttempts': maxRetries},
            error: '$e',
          );
          // Don't rethrow — REST polling handles everything
          return;
        }
        
        // Wait before retrying
        final delay = retryDelays[attempt];
        _log('RETRYING_CONNECTION', data: {'delayMs': delay, 'nextAttempt': attempt + 2});
        await Future.delayed(Duration(milliseconds: delay));
      }
    }
  }

  /// Gracefully disconnect from the ChatHub.
  Future<void> disconnect() async {
    _log('DISCONNECTING');
    // Clear token to prevent auto-reconnect (user logged out)
    _lastToken = null;
    // Clear connection state
    try {
      await _connection?.stop();
      _setStatus(HubConnectionStatus.disconnected);
      _log('DISCONNECTED');
    } catch (e, stackTrace) {
      _log('DISCONNECT_ERROR', error: '$e\n$stackTrace');
    }
    _connection = null;
  }
  
  /// Force a reconnection attempt (useful for manual retry).
  Future<void> reconnect(String token) async {
    _log('MANUAL_RECONNECT_REQUESTED');
    await disconnect();
    // Small delay to ensure clean state
    await Future.delayed(const Duration(milliseconds: 500));
    await connect(token);
  }
  
  /// Get detailed connection diagnostics for troubleshooting.
  Map<String, dynamic> getDiagnostics() {
    return {
      'status': _status.toString(),
      'isConnected': isConnected,
      'connectionState': _connection?.state.toString(),
      'connectionId': _connection?.connectionId,
      'lastError': _lastError,
      'logCount': _connectionLog.length,
      'recentLogs': _connectionLog.take(20).toList(),
    };
  }

  // ─── Hub Methods (Client → Server) ──────────────────────────────────────

  /// Join a specific chat room's SignalR group.
  ///
  /// Only needed after receiving a `ChatRoomCreated` event for a new room.
  /// Existing rooms are auto-joined by the server on connect.
  Future<void> joinChatRoom(int chatRoomId) async {
    _log('JOIN_CHAT_ROOM', data: {'chatRoomId': chatRoomId, 'connected': _connection?.state == HubConnectionState.Connected});
    if (_connection?.state == HubConnectionState.Connected) {
      try {
        await _connection!.invoke('JoinChatRoom', args: [chatRoomId]);
        _log('JOIN_CHAT_ROOM_SUCCESS', data: {'chatRoomId': chatRoomId});
      } catch (e, stackTrace) {
        _log('JOIN_CHAT_ROOM_ERROR', data: {'chatRoomId': chatRoomId}, error: '$e\n$stackTrace');
      }
    } else {
      _log('JOIN_CHAT_ROOM_SKIPPED_NOT_CONNECTED', data: {'state': _connection?.state.toString()});
    }
  }

  /// Leave a specific chat room's SignalR group.
  Future<void> leaveChatRoom(int chatRoomId) async {
    _log('LEAVE_CHAT_ROOM', data: {'chatRoomId': chatRoomId, 'connected': _connection?.state == HubConnectionState.Connected});
    if (_connection?.state == HubConnectionState.Connected) {
      try {
        await _connection!.invoke('LeaveChatRoom', args: [chatRoomId]);
        _log('LEAVE_CHAT_ROOM_SUCCESS', data: {'chatRoomId': chatRoomId});
      } catch (e, stackTrace) {
        _log('LEAVE_CHAT_ROOM_ERROR', data: {'chatRoomId': chatRoomId}, error: '$e\n$stackTrace');
      }
    }
  }

  /// Broadcast a typing indicator to the other participant.
  Future<void> sendTypingIndicator(int chatRoomId) async {
    _log('SEND_TYPING_INDICATOR', data: {'chatRoomId': chatRoomId, 'connected': _connection?.state == HubConnectionState.Connected});
    if (_connection?.state == HubConnectionState.Connected) {
      try {
        await _connection!.invoke('SendTypingIndicator', args: [chatRoomId]);
        _log('SEND_TYPING_INDICATOR_SUCCESS', data: {'chatRoomId': chatRoomId});
      } catch (e, stackTrace) {
        _log('SEND_TYPING_INDICATOR_ERROR', data: {'chatRoomId': chatRoomId}, error: '$e\n$stackTrace');
      }
    }
  }

  /// Broadcast a stopped-typing indicator to the other participant.
  Future<void> sendStoppedTypingIndicator(int chatRoomId) async {
    _log('SEND_STOPPED_TYPING', data: {'chatRoomId': chatRoomId, 'connected': _connection?.state == HubConnectionState.Connected});
    if (_connection?.state == HubConnectionState.Connected) {
      try {
        await _connection!.invoke('SendStoppedTypingIndicator', args: [chatRoomId]);
        _log('SEND_STOPPED_TYPING_SUCCESS', data: {'chatRoomId': chatRoomId});
      } catch (e, stackTrace) {
        _log('SEND_STOPPED_TYPING_ERROR', data: {'chatRoomId': chatRoomId}, error: '$e\n$stackTrace');
      }
    }
  }

  // ─── Helpers ────────────────────────────────────────────────────────────

  /// Safely extract a Map from SignalR event args.
  /// Handles both `Map<String, dynamic>` and raw `Map` types.
  Map<String, dynamic>? _asMap(List<Object?>? args) {
    if (args == null || args.isEmpty) return null;
    final raw = args.first;
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return raw.cast<String, dynamic>();
    return null;
  }
}
