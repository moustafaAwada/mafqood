import 'package:flutter/foundation.dart';
import 'package:mafqood/core/api/end_points.dart';
import 'package:mafqood/features/posts/data/models/post_signalr_dtos.dart';
import 'package:signalr_netcore/signalr_client.dart';

/// Real-time notification service for the Post Interaction System via SignalR.
///
/// Follows the same architectural pattern as [ChatHubService]:
/// - No token in the constructor — use [connect] / [disconnect] lifecycle.
/// - Registered as a lazy singleton in `service_locator.dart`.
/// - Connected on splash/login, disconnected on logout.
///
/// **Key principle:** SignalR is a *thin notification layer* only — all writes
/// go through REST. This service receives 5 server→client events and exposes
/// 2 client→server hub methods (join/leave post).
class PostInteractionHubService {
  HubConnection? _connection;

  // ─── Typed callbacks (assigned by the PostCubit) ────────────────────────

  /// Fired when a new comment is added to a joined post.
  void Function(CommentAddedDto)? onCommentAdded;

  /// Fired when a reply is added to a comment in a joined post.
  void Function(ReplyAddedDto)? onReplyAdded;

  /// Fired when a comment is edited in a joined post.
  void Function(CommentUpdatedDto)? onCommentUpdated;

  /// Fired when a comment is deleted in a joined post.
  void Function(CommentDeletedDto)? onCommentDeleted;

  /// Fired when a reaction is toggled/removed in a joined post.
  void Function(ReactionUpdatedDto)? onReactionUpdated;

  /// Called when the connection is successfully re-established after a drop.
  VoidCallback? onReconnected;

  /// Called when the connection is lost (before reconnect attempts).
  VoidCallback? onDisconnected;

  // ─── Connection State ───────────────────────────────────────────────────

  bool get isConnected =>
      _connection?.state == HubConnectionState.Connected;

  // ─── Connection Lifecycle ───────────────────────────────────────────────

  /// Connect to the PostInteractionHub with the user's Bearer token.
  Future<void> connect(String token) async {
    // Prevent double-connect
    if (_connection != null &&
        _connection!.state == HubConnectionState.Connected) {
      return;
    }

    // SignalR accessTokenFactory should return RAW token (without "Bearer " prefix)
    final rawToken = token.startsWith('Bearer ') ? token.substring(7) : token;

    _connection = HubConnectionBuilder()
        .withUrl(
          '${EndPoints.baseUrl}${EndPoints.postInteractionHub}',
          options: HttpConnectionOptions(
            accessTokenFactory: () async => rawToken,
          ),
        )
        .withAutomaticReconnect()
        .build();

    // ── Register 5 server→client event listeners ──────────────────────

    // Backend event names follow the integration guide.
    _connection!.on('CommentAdded', (args) {
      final data = _asMap(args);
      if (data != null) onCommentAdded?.call(CommentAddedDto.fromJson(data));
    });

    _connection!.on('ReplyAdded', (args) {
      final data = _asMap(args);
      if (data != null) onReplyAdded?.call(ReplyAddedDto.fromJson(data));
    });

    _connection!.on('CommentUpdated', (args) {
      final data = _asMap(args);
      if (data != null) {
        onCommentUpdated?.call(CommentUpdatedDto.fromJson(data));
      }
    });

    _connection!.on('CommentDeleted', (args) {
      final data = _asMap(args);
      if (data != null) {
        onCommentDeleted?.call(CommentDeletedDto.fromJson(data));
      }
    });

    _connection!.on('ReactionUpdated', (args) {
      final data = _asMap(args);
      if (data != null) {
        onReactionUpdated?.call(ReactionUpdatedDto.fromJson(data));
      }
    });

    // ── Reconnection handlers ─────────────────────────────────────────

    _connection!.onreconnected(({connectionId}) {
      debugPrint('PostInteractionHub reconnected: $connectionId');
      onReconnected?.call();
    });

    _connection!.onclose(({error}) {
      debugPrint('PostInteractionHub disconnected: $error');
      onDisconnected?.call();
    });

    // ── Start connection ──────────────────────────────────────────────

    await _connection!.start();
    debugPrint('PostInteractionHub connected');
  }

  /// Gracefully disconnect from the PostInteractionHub.
  Future<void> disconnect() async {
    await _connection?.stop();
    _connection = null;
  }

  // ─── Hub Methods (Client → Server) ──────────────────────────────────────

  /// Join a specific post's SignalR group to receive real-time updates.
  Future<void> joinPost(int postId) async {
    if (_connection?.state == HubConnectionState.Connected) {
      await _connection!.invoke('JoinPost', args: [postId]);
    }
  }

  /// Leave a specific post's SignalR group.
  Future<void> leavePost(int postId) async {
    if (_connection?.state == HubConnectionState.Connected) {
      await _connection!.invoke('LeavePost', args: [postId]);
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
