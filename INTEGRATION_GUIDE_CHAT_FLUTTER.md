# Chat System & Real-Time SignalR — Flutter Integration Guide

---

## 1) Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           FLUTTER CLIENT                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  Chat List   │  │ Conversation │  │  New Chat    │  │   Contacts   │  │
│  │    Screen    │  │    Screen    │  │    Screen    │  │    Screen    │  │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  │
│         │                 │                 │                 │          │
│  ┌──────▼───────────────▼──────────────────▼─────────────────▼───────┐  │
│  │                     REST API Client (HTTP)                         │  │
│  │  • POST /chat/initiate-message (with clientMessageId)              │  │
│  │  • GET /chat-rooms, GET /chat-rooms/{id}                           │  │
│  │  • GET /chat-rooms/{id}/messages?afterTimestamp=...                 │  │
│  │  • PUT /chat-rooms/{id}/messages/read                              │  │
│  │  • DELETE /chat-rooms/{id}/messages/{messageId}                    │  │
│  └──────┬────────────────────────────────────────────┬──────────────┘  │
│         │                                              │                 │
│  ┌──────▼──────────────┐                    ┌───────────▼───────────────┐ │
│  │  SignalR Client     │                    │  Local State Management   │ │
│  │  ChatHub (5 events) │◄──────────────────►│  • currentOpenChatRoomId  │ │
│  │  • JoinChatRoom()   │                    │  • outboxQueue (offline)  │ │
│  │  • LeaveChatRoom()  │                    │  • unreadCounts (local)   │ │
│  │  • SendTyping()     │                    │  • lastMessages (local)   │ │
│  │  • On<Event>()      │                    │  • onlineUsers            │ │
│  └─────────────────────┘                    └───────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         ASP.NET CORE BACKEND                                │
├─────────────────────────────────────────────────────────────────────────────┤
│  REST API (Source of Truth)        │  SignalR Hub (Notifications Only)      │
│  • Initiate Message (idempotent)   │  • ChatHub (5 simplified events)      │
│  • Chat Room CRUD                  │  • Groups: "ChatRoom_{id}"            │
│  • Message Ops + Offline Sync     │  • Auto-join on connect                │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2) Key Design Principles

### ⚠️ Critical: REST is the Source of Truth

```
REST API (Source of Truth)  →  SignalR (Real-time notifications only)  →  Flutter (UI + state computation)
```

SignalR is a **thin notification layer**. All business logic, persistence, and validation happen via REST.

### ⚠️ Critical: Idempotent Message Sending

Every message sent from Flutter **MUST** include a `clientMessageId` (UUID v4). If the same `clientMessageId` is sent twice (e.g., network retry, double-click), the backend returns the existing message — **no duplicate is created**.

### ⚠️ Critical: Client Computes UI State

Flutter computes these locally — the server does NOT push them:
- **Unread count**: increment on `MessageReceived`, reset on `mark-as-read`
- **Last message preview**: derive from `MessageReceived` data
- **Chat room list order**: re-sort on `MessageReceived` using `sentAt`

### ⚠️ Critical: Simplified SignalR Events (5 Total)

| Event | Purpose |
|-------|---------|
| `MessageReceived` | New message notification |
| `MessageUpdated` | Read / deleted / delivered status changes |
| `ChatRoomCreated` | New room created (for recipient) |
| `UserTyping` / `UserStoppedTyping` | Typing indicators |
| `UserPresenceChanged` | Online/offline status |

### State Variables Flutter Must Maintain

```dart
class ChatState {
  int? currentOpenChatRoomId;
  bool isInConversationView;
  Set<String> pendingClientMessageIds; // for deduplication
  Map<int, int> unreadCounts;          // chatRoomId → count (computed locally)
  Set<String> onlineUsers;
  Map<int, bool> typingIndicators;
  List<OutboxMessage> outboxQueue;     // offline queue
  DateTime? lastSyncTimestamp;         // for missed message recovery
}
```

---

## 3) Base Host & Authentication

```
Base Host: https://mafqood.runasp.net
```

All chat endpoints require **Bearer Token** authentication.

```
Authorization: Bearer {token}
```

---

## 4) Response Pattern

### ✅ Success — With Data

```json
{
  "isSuccess": true,
  "hasData": true,
  "data": { ... }
}
```

### ✅ Success — Without Data

```json
{
  "isSuccess": true,
  "hasData": false
}
```

### ❌ Failure

```json
{
  "isSuccess": false,
  "statusCode": 404,
  "error": {
    "code": "ChatRoom.NotFound",
    "description": "Chat room not found."
  }
}
```

---

## 5) Enums Reference

### MessageType

| Value | Name | Description |
|-------|------|-------------|
| `0` | `Text` | Plain text message |
| `1` | `Image` | Image attachment (jpg, jpeg, png, gif — max 5 MB) |
| `2` | `File` | Document attachment (pdf, docx, doc — max 20 MB) |
| `3` | `VoiceRecord` | Voice recording attachment |

### ChatRoomFilter

| Value | Name | Description |
|-------|------|-------------|
| `0` | `All` | Return all chat rooms |
| `1` | `Unread` | Return only rooms with unread messages |

### MessageDeliveryStatus (SignalR Only)

| Value | Name | Description |
|-------|------|-------------|
| `0` | `Sent` | Message saved to database |
| `1` | `Delivered` | Delivered to recipient's client(s) |
| `2` | `Read` | Read by the recipient |

### MessageUpdateType (SignalR Only)

| Value | Name | Description |
|-------|------|-------------|
| `0` | `Read` | Messages in a room were marked as read |
| `1` | `Deleted` | A specific message was deleted |
| `2` | `Delivered` | Message delivery confirmed |

---

## 6) REST API Endpoints

### 6.1 Initiate Message (Smart + Idempotent)

```
POST {{Host}}/chat/initiate-message
Content-Type: multipart/form-data
```

**Request Body (Multipart Form):**

| Field | Type | Required | Validation |
|-------|------|----------|------------|
| `ClientMessageId` | `Guid` | ✅ | UUID v4, unique per message attempt |
| `RecipientUserId` | `string` | ✅ | Target user's ID, must not be self |
| `Content` | `string` | Conditional | Required when `Type` = 0 (Text), max 2000 chars |
| `Type` | `int` | ✅ | 0=Text, 1=Image, 2=File, 3=VoiceRecord |
| `Attachment` | `IFormFile` | Conditional | Required when `Type` ≠ 0 |

**Idempotency Behavior:**
- First call → creates message, returns `chatRoomId` + `messageId`
- Retry with same `clientMessageId` → returns existing `chatRoomId` + `messageId` (no duplicate)
- Different `clientMessageId` → creates a new message

**Success Response (200/201):**

```json
{
  "isSuccess": true,
  "hasData": true,
  "data": {
    "chatRoomId": 7,
    "messageId": 42,
    "isNewRoom": true
  }
}
```

| Field | Type | Description |
|-------|------|-------------|
| `chatRoomId` | `int` | The chat room ID (existing or newly created) |
| `messageId` | `int` | The ID of the saved message |
| `isNewRoom` | `bool` | `true` if a new room was created |

> ⚠️ When `isNewRoom` is `true`, the recipient receives both `ChatRoomCreated` and `MessageReceived` via SignalR.

---

### 6.2 Chat Room Management

#### Get Chat Rooms (Chat List)

```
GET {{Host}}/chat-rooms?pageNumber=1&pageSize=10&searchKey=&filter=0
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `pageNumber` | `int` | ❌ | Default: 1 |
| `pageSize` | `int` | ❌ | Default: 10 |
| `searchKey` | `string?` | ❌ | Filter by other participant's name or phone |
| `filter` | `int` | ❌ | 0=All, 1=Unread only |

**Success Response (200):**

```json
{
  "isSuccess": true,
  "hasData": true,
  "data": {
    "items": [
      {
        "id": 7,
        "createdAt": "2026-04-10T14:30:00Z",
        "otherParticipant": {
          "id": "user456",
          "name": "Mohamed Ali",
          "profilePictureUrl": "https://..."
        },
        "lastMessage": {
          "content": "Hello, did you find the wallet?",
          "type": 0,
          "sentAt": "2026-04-13T14:30:00Z"
        },
        "unreadCount": 3
      }
    ],
    "pageNumber": 1,
    "totalPages": 2,
    "hasPreviousPage": false,
    "hasNextPage": true
  }
}
```

---

#### Get Chat Room By ID

```
GET {{Host}}/chat-rooms/{chatRoomId}
```

**Success Response (200):**

```json
{
  "isSuccess": true,
  "hasData": true,
  "data": {
    "id": 7,
    "createdAt": "2026-04-10T14:30:00Z",
    "currentUser": { "id": "currentUserId", "name": "Ahmed", "profilePictureUrl": "..." },
    "otherUser": { "id": "user456", "name": "Mohamed Ali", "profilePictureUrl": "..." },
    "totalMessages": 42,
    "unreadMessages": 3
  }
}
```

---

#### Delete Chat Room

```
DELETE {{Host}}/chat-rooms/{chatRoomId}
```

> ⚠️ Only participants can delete. Deleting removes all messages.

---

### 6.3 Message Operations

#### Get Messages (with Offline Sync)

```
GET {{Host}}/chat-rooms/{chatRoomId}/messages?pageNumber=1&pageSize=20&typeFilter=0&afterTimestamp=2026-04-13T14:30:00Z
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `pageNumber` | `int` | ❌ | Default: 1 |
| `pageSize` | `int` | ❌ | Default: 10 |
| `typeFilter` | `int?` | ❌ | Filter by message type |
| `afterTimestamp` | `DateTime?` | ❌ | **Offline sync:** fetch only messages sent AFTER this time |

**Success Response (200):**

```json
{
  "isSuccess": true,
  "hasData": true,
  "data": {
    "items": [
      {
        "id": 42,
        "clientMessageId": "550e8400-e29b-41d4-a716-446655440000",
        "senderId": "user456",
        "senderName": "Mohamed Ali",
        "content": "Hello, did you find the wallet?",
        "type": 0,
        "sentAt": "2026-04-13T14:30:00Z",
        "isRead": true,
        "readAt": "2026-04-13T14:31:00Z",
        "isOwner": false
      }
    ],
    "pageNumber": 1,
    "totalPages": 3,
    "hasPreviousPage": false,
    "hasNextPage": true
  }
}
```

> ⚠️ **Offline Sync:** Pass `afterTimestamp` with the `sentAt` of your last known message. The API returns only newer messages. Use this on reconnect to fetch missed messages without re-downloading everything.

---

#### Mark Messages As Read

```
PUT {{Host}}/chat-rooms/{chatRoomId}/messages/read
```

Bulk-updates ALL unread messages not sent by current user. Pushes `MessageUpdated` (UpdateType=Read) via SignalR.

---

#### Delete Message

```
DELETE {{Host}}/chat-rooms/{chatRoomId}/messages/{messageId}
```

Only the sender can delete. Pushes `MessageUpdated` (UpdateType=Deleted) via SignalR.

---

## 7) SignalR Real-Time Integration

### 7.1 Hub Configuration

| Property | Value |
|----------|-------|
| Hub URL | `{{Host}}/hubs/chat` |
| Transport | WebSockets with fallback to SSE/Long Polling |
| Auth | Bearer token in query string or connection header |
| Auto-Join | Server auto-joins ALL user's rooms on connect |

### 7.2 Connection Lifecycle

```dart
class ChatHubService {
  HubConnection? _connection;
  final String baseUrl;
  final String token;

  ChatHubService({required this.baseUrl, required this.token});

  Future<void> connect() async {
    _connection = HubConnectionBuilder()
      .withUrl(
        '$baseUrl/hubs/chat',
        HttpConnectionOptions(accessTokenFactory: () async => token),
      )
      .withAutomaticReconnect()
      .build();

    // Register 5 simplified event handlers
    _connection!.on('MessageReceived', _handleMessageReceived);
    _connection!.on('MessageUpdated', _handleMessageUpdated);
    _connection!.on('ChatRoomCreated', _handleChatRoomCreated);
    _connection!.on('UserTyping', _handleUserTyping);
    _connection!.on('UserStoppedTyping', _handleUserStoppedTyping);
    _connection!.on('UserPresenceChanged', _handlePresenceChanged);

    await _connection!.start();
    // Server auto-joins all your chat rooms — no manual join needed!
  }

  Future<void> disconnect() async => await _connection?.stop();
}
```

### 7.3 Hub Methods (Client → Server)

| Method | Args | Description |
|--------|------|-------------|
| `JoinChatRoom` | `int chatRoomId` | Join a room group (validates participation) |
| `LeaveChatRoom` | `int chatRoomId` | Leave a room group |
| `SendTypingIndicator` | `int chatRoomId` | Broadcast typing to other participant |
| `SendStoppedTypingIndicator` | `int chatRoomId` | Broadcast stopped typing |

---

## 8) SignalR Event DTOs & Handlers

### 8.1 Event DTOs (Simplified — 5 Events)

| Event | DTO | Key Fields |
|-------|-----|------------|
| `MessageReceived` | `MessageDto` | `id`, `chatRoomId`, `clientMessageId`, `senderId`, `senderName`, `senderProfilePictureUrl`, `content`, `type`, `sentAt`, `deliveryStatus` |
| `MessageUpdated` | `MessageUpdatedDto` | `chatRoomId`, `updateType` (0=Read, 1=Deleted, 2=Delivered), `messageId?`, `readByUserId?`, `readAt?`, `timestamp?` |
| `ChatRoomCreated` | `ChatRoomCreatedDto` | `chatRoomId`, `createdAt`, `createdByUserId`, `createdByUserName`, `createdByUserProfilePictureUrl` |
| `UserTyping` | `TypingDto` | `chatRoomId`, `userId`, `userName` |
| `UserPresenceChanged` | `UserPresenceDto` | `userId`, `isOnline`, `timestamp` |

### 8.2 MessageReceived Handler

```dart
void _handleMessageReceived(List<Object?>? args) {
  final data = args?.first as Map<String, dynamic>?;
  if (data == null) return;

  final chatRoomId = data['chatRoomId'] as int;
  final clientMessageId = data['clientMessageId'] as String;

  // Idempotency: skip if this was our own message (already in UI via outbox)
  if (state.pendingClientMessageIds.contains(clientMessageId)) {
    state.pendingClientMessageIds.remove(clientMessageId);
    return;
  }

  if (state.currentOpenChatRoomId == chatRoomId && state.isInConversationView) {
    _addMessageToUI(MessageDto.fromJson(data));
    _markMessagesAsRead(chatRoomId); // auto-read since user is viewing
  } else {
    // Client-computed: increment unread + update last message preview
    state.unreadCounts[chatRoomId] = (state.unreadCounts[chatRoomId] ?? 0) + 1;
    _updateChatListPreview(chatRoomId, data);
  }
}
```

### 8.3 MessageUpdated Handler (Unified)

```dart
void _handleMessageUpdated(List<Object?>? args) {
  final data = args?.first as Map<String, dynamic>?;
  if (data == null) return;

  final chatRoomId = data['chatRoomId'] as int;
  final updateType = data['updateType'] as int;

  switch (updateType) {
    case 0: // Read
      if (state.currentOpenChatRoomId == chatRoomId) {
        _updateReadReceipts(chatRoomId, data['readAt'] as String);
      }
      break;
    case 1: // Deleted
      final messageId = data['messageId'] as int;
      if (state.currentOpenChatRoomId == chatRoomId) {
        _removeMessageFromUI(messageId);
      }
      break;
    case 2: // Delivered
      final messageId = data['messageId'] as int;
      if (state.currentOpenChatRoomId == chatRoomId) {
        _updateMessageStatus(messageId, MessageDeliveryStatus.delivered);
      }
      break;
  }
}
```

### 8.4 ChatRoomCreated Handler

```dart
void _handleChatRoomCreated(List<Object?>? args) {
  final data = args?.first as Map<String, dynamic>?;
  if (data == null) return;

  _addNewChatRoomToList(ChatRoomCreatedDto.fromJson(data));
  // Join the new room's SignalR group for future messages
  _connection!.invoke('JoinChatRoom', args: [data['chatRoomId']]);
}
```

### 8.5 Typing & Presence Handlers

```dart
void _handleUserTyping(List<Object?>? args) {
  final chatRoomId = (args?.first as Map)['chatRoomId'] as int;
  state.typingIndicators[chatRoomId] = true;
  notifyListeners();
  // Auto-clear after 5 seconds
  Future.delayed(Duration(seconds: 5), () {
    state.typingIndicators[chatRoomId] = false;
    notifyListeners();
  });
}

void _handlePresenceChanged(List<Object?>? args) {
  final data = args?.first as Map<String, dynamic>?;
  if (data == null) return;
  final userId = data['userId'] as String;
  data['isOnline'] == true
      ? state.onlineUsers.add(userId)
      : state.onlineUsers.remove(userId);
  notifyListeners();
}
```

---

## 9) Idempotency Pattern

### Generate clientMessageId Before Sending

```dart
Future<InitiateMessageResponse> sendMessage(
  String recipientUserId, String content, MessageType type, {File? attachment}
) async {
  // 1. Generate UUID BEFORE sending
  final clientMessageId = Uuid().v4();

  // 2. Add to pending set to block SignalR duplicate
  state.pendingClientMessageIds.add(clientMessageId);

  // 3. Optimistically add message to UI
  final tempMessage = _createTempMessage(clientMessageId, content, type);
  _addMessageToUI(tempMessage);

  try {
    final formData = FormData.fromMap({
      'ClientMessageId': clientMessageId,
      'RecipientUserId': recipientUserId,
      'Content': content,
      'Type': type.index,
      if (attachment != null)
        'Attachment': await MultipartFile.fromFile(attachment.path),
    });

    final response = await _dio.post('/chat/initiate-message', data: formData);
    final data = response.data['data'];

    // 4. Update temp message with real server ID
    _replaceTempMessage(clientMessageId, data['messageId'], data['chatRoomId']);

    // 5. If new room, join SignalR group
    if (data['isNewRoom'] == true) {
      await _hub.joinChatRoom(data['chatRoomId']);
    }
    return InitiateMessageResponse.fromJson(data);
  } catch (e) {
    // On failure: save to outbox for retry (see Section 10)
    _saveToOutbox(clientMessageId, recipientUserId, content, type, attachment);
    rethrow;
  }
}
```

---

## 10) Offline Handling

### 10.1 Outbox Queue

```dart
class OutboxMessage {
  final String clientMessageId; // UUID — same one used for idempotency
  final String recipientUserId;
  final String content;
  final int type;
  final String? attachmentPath;
  final DateTime createdAt;
  MessageStatus status; // pending, sending, failed

  OutboxMessage({...});
}
```

### 10.2 Offline Behavior

```dart
Future<void> sendMessageSafe(String recipientId, String content, int type) async {
  final clientMessageId = Uuid().v4();

  if (!_isOnline) {
    // Store in local outbox, show as "pending" in UI
    _outbox.add(OutboxMessage(
      clientMessageId: clientMessageId,
      recipientUserId: recipientId,
      content: content,
      type: type,
      createdAt: DateTime.now(),
      status: MessageStatus.pending,
    ));
    _showPendingInUI(clientMessageId, content, type);
    return;
  }

  // Online — send normally (idempotent, safe to retry)
  await sendMessage(recipientId, content, type);
}
```

### 10.3 Sync on Reconnect

```dart
Future<void> onReconnected() async {
  // 1. Flush outbox — send all pending messages
  for (final msg in _outbox.where((m) => m.status == MessageStatus.pending)) {
    msg.status = MessageStatus.sending;
    try {
      await sendMessage(msg.recipientUserId, msg.content, MessageType.values[msg.type]);
      _outbox.remove(msg);
    } catch (e) {
      msg.status = MessageStatus.failed;
    }
  }

  // 2. Fetch missed messages for each open room
  for (final roomId in _activeRoomIds) {
    final response = await _dio.get(
      '/chat-rooms/$roomId/messages',
      queryParameters: {'afterTimestamp': state.lastSyncTimestamp?.toIso8601String()},
    );
    // Merge into local state, dedup by clientMessageId
    _mergeMessages(roomId, response.data['data']['items']);
  }

  // 3. Update sync timestamp
  state.lastSyncTimestamp = DateTime.now().toUtc();
}
```

> ⚠️ **Idempotency makes retry safe.** Even if the outbox sends a message that already arrived at the server, the `clientMessageId` ensures no duplicate is created.

---

## 11) Error Codes Reference

### Chat Room Errors

| Error Code | HTTP Status | Description |
|------------|-------------|-------------|
| `ChatRoom.NotFound` | 404 | Chat room does not exist |
| `ChatRoom.AlreadyExists` | 409 | Room between these users already exists |
| `ChatRoom.SameUser` | 400 | Cannot create a chat room with yourself |
| `ChatRoom.Unauthorized` | 403 | You are not a participant |
| `ChatRoom.RecipientNotFound` | 404 | Target user not found |

### Chat Message Errors

| Error Code | HTTP Status | Description |
|------------|-------------|-------------|
| `ChatMessage.NotFound` | 404 | Message not found |
| `ChatMessage.Unauthorized` | 403 | Not authorized for this action |
| `ChatMessage.InvalidRoom` | 404 | Chat room does not exist |
| `ChatMessage.CannotMessageSelf` | 400 | Cannot message yourself |
| `ChatMessage.RecipientNotFound` | 404 | Recipient not found |

---

## 12) Best Practices

### ✅ DO

- **Always generate `clientMessageId`** (UUID v4) before sending
- **Use `initiate-message` for ALL messages** — handles room creation automatically
- **Compute unread counts locally** — increment on `MessageReceived`, reset on read
- **Compute last message preview locally** — derive from `MessageReceived` data
- **Implement outbox queue** for offline reliability
- **Use `afterTimestamp`** to sync missed messages on reconnect
- **Debounce typing indicators** — 3 second inactivity → stop
- **Mark messages as read** when entering a conversation
- **Join new room groups** after `ChatRoomCreated` event

### ❌ DON'T

- **Don't send messages through SignalR** — always use REST
- **Don't manually join all rooms on connect** — server auto-joins
- **Don't generate new `clientMessageId` on retry** — reuse the original
- **Don't assume event ordering** — use `sentAt` for display order
- **Don't store typing indicators permanently** — auto-clear after 5s

---

## 13) Quick Reference — All Endpoints

### Chat Room Management

| # | Method | Endpoint | Auth | Request | Response |
|---|--------|----------|------|---------|----------|
| 1 | POST | `/chat/initiate-message` | ✅ | `InitiateMessageRequest` (multipart) | `InitiateMessageResponse` |
| 2 | GET | `/chat-rooms` | ✅ | Query: `pageNumber`, `pageSize`, `searchKey`, `filter` | `PaginatedList<GetChatRoomsResponse>` |
| 3 | GET | `/chat-rooms/{chatRoomId}` | ✅ | — | `GetChatRoomByIdResponse` |
| 4 | DELETE | `/chat-rooms/{chatRoomId}` | ✅ | — | *(no data)* |

### Message Operations

| # | Method | Endpoint | Auth | Request | Response |
|---|--------|----------|------|---------|----------|
| 5 | GET | `/chat-rooms/{id}/messages` | ✅ | Query: `pageNumber`, `pageSize`, `typeFilter`, `afterTimestamp` | `PaginatedList<GetMessagesResponse>` |
| 6 | PUT | `/chat-rooms/{id}/messages/read` | ✅ | — | *(no data)* |
| 7 | DELETE | `/chat-rooms/{id}/messages/{messageId}` | ✅ | — | *(no data)* |

---

## 14) SignalR Event Reference

### Server → Client Events (5 Total)

| Event | DTO | Trigger | Scope |
|-------|-----|---------|-------|
| `MessageReceived` | `MessageDto` | New message sent | Room group or direct |
| `MessageUpdated` | `MessageUpdatedDto` | Read/deleted/delivered | Room group or sender |
| `ChatRoomCreated` | `ChatRoomCreatedDto` | New room created | Target user only |
| `UserTyping` / `UserStoppedTyping` | `TypingDto` | Typing state changed | Others in room group |
| `UserPresenceChanged` | `UserPresenceDto` | Online/offline | Others in room groups |

### Client → Server Hub Methods

| Method | Args | Description |
|--------|------|-------------|
| `JoinChatRoom` | `int chatRoomId` | Join room group (validates participation) |
| `LeaveChatRoom` | `int chatRoomId` | Leave room group |
| `SendTypingIndicator` | `int chatRoomId` | Broadcast typing |
| `SendStoppedTypingIndicator` | `int chatRoomId` | Broadcast stopped typing |

**Group Name Format:** `ChatRoom_{chatRoomId}` (e.g., `ChatRoom_7`)

---

## 15) Required Flutter Packages

```yaml
dependencies:
  dio: ^5.0.0              # HTTP client
  signalr_core: ^1.3.0     # SignalR client
  uuid: ^4.0.0             # Generate clientMessageId (UUID v4)
  flutter_secure_storage: ^9.0.0  # Secure token storage
  sqflite: ^2.3.0          # Local DB for outbox queue
  connectivity_plus: ^5.0.0 # Network state detection
  
  # State management (choose one)
  flutter_bloc: ^8.1.0
  provider: ^6.1.0
```

---

## 16) Chat Navigation Scenarios & UI Logic

### 🎯 Integration with Post System

The chat system integrates seamlessly with the post system. When users interact with posts, they can navigate to chat functionality through specific scenarios.

### 🧩 Scenario 1: No Existing Chat (Profile Picture Click)

When the user clicks on the **profile picture** in a post:

#### User Flow:
```
Post Details Screen → Profile Picture Click → User Profile Screen → Start New Chat
```

#### Implementation Steps:

1. **Navigate to Profile Page**
   ```dart
   GestureDetector(
     onTap: () {
       Navigator.pushNamed(
         context, 
         '/user-profile', 
         arguments: post.userId
       );
     },
     child: CircleAvatar(
       backgroundImage: NetworkImage(post.userProfilePictureUrl),
     ),
   )
   ```

2. **User Profile Screen Actions**
   ```dart
   class UserProfileScreen extends StatelessWidget {
     final String userId;
     
     // ... build method
     
     Widget _buildActionButtons() {
       return Row(
         children: [
           if (!isCurrentUser) ...[
             ElevatedButton.icon(
               onPressed: _startNewChat,
               icon: Icon(Icons.message),
               label: Text('Message'),
             ),
             SizedBox(width: 8),
             ElevatedButton.icon(
               onPressed: _toggleFollow,
               icon: Icon(isFollowing ? Icons.person_remove : Icons.person_add),
               label: Text(isFollowing ? 'Unfollow' : 'Follow'),
             ),
           ],
         ],
       );
     }
     
     void _startNewChat() async {
       try {
         final chatRoom = await chatService.initiateChat(userId);
         Navigator.pushReplacementNamed(
           context,
           '/chat-room',
           arguments: chatRoom.id,
         );
       } catch (e) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Failed to start chat')),
         );
       }
     }
   }
   ```

3. **Backend API Call**
   ```dart
   Future<ChatRoom> initiateChat(String targetUserId) async {
     final response = await dio.post(
       '/chat/initiate-message',
       data: {
         'recipientId': targetUserId,
         'message': 'Hello!', // Optional initial message
         'clientMessageId': Uuid().v4(), // Required for idempotency
       },
     );
     
     return ChatRoom.fromJson(response.data['data']);
   }
   ```

---

### 🔁 Scenario 2: Existing Chat Already Exists

If a chat already exists between the two users, the system should **navigate to the existing chat room** instead of creating a new one.

#### Implementation Options:

##### Option A: Check Existing Chats First
```dart
void _startChat() async {
  try {
    // First, check if chat already exists
    final existingChat = await chatService.findExistingChat(userId);
    
    if (existingChat != null) {
      // Navigate to existing chat
      Navigator.pushReplacementNamed(
        context,
        '/chat-room',
        arguments: existingChat.id,
      );
    } else {
      // Create new chat
      final newChat = await chatService.initiateChat(userId);
      Navigator.pushReplacementNamed(
        context,
        '/chat-room',
        arguments: newChat.id,
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to start chat')),
    );
  }
}
```

##### Option B: Backend Handles Chat Existence
```dart
Future<ChatRoom> initiateChat(String targetUserId) async {
  final response = await dio.post(
    '/chat/initiate-message',
    data: {
      'recipientId': targetUserId,
      'message': 'Hello!',
      'clientMessageId': Uuid().v4(),
    },
  );
  
  // Backend returns existing chat if it exists, or creates new one
  return ChatRoom.fromJson(response.data['data']);
}
```

---

### 🧭 Navigation from Chat List

Users can also access chat through the main chat system:

#### Chat List Screen Integration
```dart
class ChatListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildChatList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewChatDialog,
        child: Icon(Icons.add),
      ),
    );
  }
  
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Search User'),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Enter username or email...',
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (query) => _searchUsers(query),
        ),
      ),
    );
  }
  
  Future<void> _searchUsers(String query) async {
    try {
      final users = await userService.searchUsers(query);
      _showUserSearchResults(users);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search failed')),
      );
    }
  }
}
```

---

### 🔍 User Search Within Chat System

Users can search for other users directly within the chat system:

#### Search Implementation
```dart
class UserSearchScreen extends StatefulWidget {
  @override
  _UserSearchScreenState createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  List<User> searchResults = [];
  bool isLoading = false;
  
  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults.clear();
      });
      return;
    }
    
    setState(() {
      isLoading = true;
    });
    
    try {
      final results = await userService.searchUsers(query);
      setState(() {
        searchResults = results;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search failed')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Users'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _searchUsers,
              decoration: InputDecoration(
                hintText: 'Search by username...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          if (isLoading) 
            Center(child: CircularProgressIndicator())
          else
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final user = searchResults[index];
                  return _buildUserTile(user);
                },
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildUserTile(User user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(user.profilePictureUrl),
      ),
      title: Text(user.name),
      subtitle: Text(user.username),
      trailing: IconButton(
        icon: Icon(Icons.message),
        onPressed: () => _startChatWithUser(user),
      ),
      onTap: () => _startChatWithUser(user),
    );
  }
  
  Future<void> _startChatWithUser(User user) async {
    try {
      final chatRoom = await chatService.initiateChat(user.id);
      Navigator.pushReplacementNamed(
        context,
        '/chat-room',
        arguments: chatRoom.id,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start chat')),
      );
    }
  }
}
```

---

### 🎯 Complete Navigation Flow Summary

| Entry Point | Action | Navigation Path | Backend Call |
|-------------|--------|-----------------|--------------|
| **Post Profile Picture** | Tap | Post → User Profile → New Chat | `POST /chat/initiate-message` |
| **Chat List** | Search User | Chat List → User Search → Chat Room | `GET /users/search` → `POST /chat/initiate-message` |
| **Chat List** | Existing Chat | Chat List → Chat Room | `GET /chat-rooms/{id}` |
| **User Profile** | Message Button | Profile → Chat Room | `POST /chat/initiate-message` |

---

### 🛠️ Flutter Service Implementation

#### Chat Service
```dart
class ChatService {
  final Dio _dio;
  
  ChatService(this._dio);
  
  Future<ChatRoom?> findExistingChat(String userId) async {
    try {
      final response = await _dio.get(
        '/chat-rooms/existing-with-user',
        queryParameters: {'userId': userId},
      );
      
      if (response.data['hasData']) {
        return ChatRoom.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      return null; // Chat doesn't exist or error occurred
    }
  }
  
  Future<ChatRoom> initiateChat(String recipientId, {String? message}) async {
    final response = await _dio.post(
      '/chat/initiate-message',
      data: {
        'recipientId': recipientId,
        'message': message ?? 'Hello!',
        'clientMessageId': Uuid().v4(),
      },
    );
    
    return ChatRoom.fromJson(response.data['data']);
  }
  
  Future<List<User>> searchUsers(String query) async {
    final response = await _dio.get(
      '/users/search',
      queryParameters: {'q': query},
    );
    
    final users = response.data['data']['items'] as List;
    return users.map((user) => User.fromJson(user)).toList();
  }
}
```

---

### 🧠 Benefits of This Navigation Design

| Benefit | Description |
|---------|-------------|
| **Intuitive Flow 🎯** | Users naturally progress from posts to profiles to chats |
| **No Duplicate Chats 🚫** | Backend prevents creating multiple chats between same users |
| **Fast Navigation ⚡** | Direct navigation to existing chats when available |
| **Search Integration 🔍** | Built-in user search within chat system |
| **Consistent UX 🎨** | Same navigation patterns across all entry points |

---

**Questions?** Provide this document to your Flutter team. They have everything needed for idempotent, offline-capable, real-time chat implementation with comprehensive navigation scenarios.

