import 'package:signalr_netcore/signalr_client.dart';

class PostInteractionHubService {
  final String baseUrl;
  final String token;
  HubConnection? _connection;

  void Function(Map<String, dynamic>)? onCommentAdded;
  void Function(Map<String, dynamic>)? onReplyAdded;
  void Function(Map<String, dynamic>)? onCommentUpdated;
  void Function(Map<String, dynamic>)? onCommentDeleted;
  void Function(Map<String, dynamic>)? onReactionUpdated;

  PostInteractionHubService({
    required this.baseUrl,
    required this.token,
  });

  Future<void> connect() async {
    _connection = HubConnectionBuilder()
        .withUrl(
          '$baseUrl/hubs/post-interaction',
          options: HttpConnectionOptions(
            accessTokenFactory: () async => token,
          ),
        )
        .withAutomaticReconnect()
        .build();

    _connection!.on('CommentAdded', (args) {
      final data = _asMap(args);
      if (data != null) onCommentAdded?.call(data);
    });
    _connection!.on('ReplyAdded', (args) {
      final data = _asMap(args);
      if (data != null) onReplyAdded?.call(data);
    });
    _connection!.on('CommentUpdated', (args) {
      final data = _asMap(args);
      if (data != null) onCommentUpdated?.call(data);
    });
    _connection!.on('CommentDeleted', (args) {
      final data = _asMap(args);
      if (data != null) onCommentDeleted?.call(data);
    });
    _connection!.on('ReactionUpdated', (args) {
      final data = _asMap(args);
      if (data != null) onReactionUpdated?.call(data);
    });

    await _connection!.start();
  }

  Future<void> disconnect() async {
    await _connection?.stop();
  }

  Future<void> joinPost(int postId) async {
    if (_connection?.state == HubConnectionState.Connected) {
      await _connection!.invoke('JoinPost', args: [postId]);
    }
  }

  Future<void> leavePost(int postId) async {
    if (_connection?.state == HubConnectionState.Connected) {
      await _connection!.invoke('LeavePost', args: [postId]);
    }
  }

  Map<String, dynamic>? _asMap(List<Object?>? args) {
    if (args == null || args.isEmpty) return null;
    final raw = args.first;
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return raw.cast<String, dynamic>();
    return null;
  }
}

