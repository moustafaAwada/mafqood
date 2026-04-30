# Post Management & Interactions — Flutter Integration Guide

---

## 1) Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           FLUTTER CLIENT                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  Post Feed   │  │ Post Details │  │   Comments   │  │  Saved Posts │  │
│  │    Screen    │  │    Screen    │  │    Screen    │  │    Screen    │  │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  │
│         │                 │                 │                 │          │
│  ┌──────▼───────────────▼──────────────────▼─────────────────▼───────┐  │
│  │                     REST API Client (HTTP)                         │  │
│  │  • GET /posts, GET /posts/{id}, POST /posts, PUT /posts/{id}       │  │
│  │  • GET /posts/{id}/comments, POST /posts/{id}/comments             │  │
│  │  • POST /posts/{id}/reacts, DELETE /posts/{id}/reacts             │  │
│  └──────┬────────────────────────────────────────────┬──────────────┘  │
│         │                                              │                 │
│  ┌──────▼──────────────┐                    ┌───────────▼───────────────┐ │
│  │  SignalR Client     │                    │  Local State Management   │ │
│  │  PostInteractionHub │◄────────────────►│  • currentOpenPostId      │ │
│  │  • JoinPost()       │                    │  • isInPostDetailsView    │ │
│  │  • LeavePost()      │                    │  • pendingActions         │ │
│  │  • On<Event>()      │                    │  • notificationQueue      │ │
│  └─────────────────────┘                    └───────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         ASP.NET CORE BACKEND                                │
├─────────────────────────────────────────────────────────────────────────────┤
│  REST API Endpoints                    │  SignalR Hub (Real-Time)           │
│  • Post Management                     │  • PostInteractionHub              │
│  • Post Interactions                   │  • Groups: "Post:{postId}"         │
│  • Saved Posts                         │  • Events: CommentAdded, etc.      │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2) Key Design Principles

### ⚠️ Critical: Flutter Controls UI State

The backend broadcasts **all** real-time events to **all** connected clients in a post group. **Flutter decides** how to handle each event:

| Scenario | Flutter Action |
|----------|----------------|
| User is viewing the same post | Update UI directly in real-time |
| User is NOT viewing the post | Show notification badge or store silently |
| App is in background/offline | Handle via push notification (future) — NOT SignalR |

### State Variables Flutter Must Maintain

```dart
class PostInteractionState {
  int? currentOpenPostId;      // null if not in post details
  bool isInPostDetailsView;    // true when viewing post details
  Set<String> pendingActions;  // Track actions in-flight to avoid duplication
  Map<int, int> unreadCommentCounts; // postId → unread count
}
```

---

## 3) Base Host & Authentication

```
Base Host: https://mafqood.runasp.net
```

All post endpoints require **Bearer Token** authentication (except where noted).

```
Authorization: Bearer {token}
```

---

## 4) Response Pattern

Same unified pattern as authentication endpoints.

### ✅ Success — With Data (Paginated Example)

```json
{
  "isSuccess": true,
  "hasData": true,
  "data": {
    "items": [...],
    "pageNumber": 1,
    "totalPages": 5,
    "hasPreviousPage": false,
    "hasNextPage": true
  }
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
    "code": "Post.PostNotFound",
    "description": "Post not found"
  }
}
```

---

## 5) Enums Reference

The following enums are used throughout the Post Management and Interactions APIs.

### PostType

```csharp
public enum PostType
{
    Lost = 0,
    Found = 1
}
```

| Value | Name | Description |
|-------|------|-------------|
| `0` | `Lost` | User lost an item and is searching for it |
| `1` | `Found` | User found an item and is trying to return it |

---

### ReactType

```csharp
public enum ReactType
{
    Like = 0,
    Dislike = 1
}
```

| Value | Name | Description |
|-------|------|-------------|
| `0` | `Like` | Positive reaction to a post |
| `1` | `Dislike` | Negative reaction to a post |

---

## 6) REST API Endpoints

### 6.1 Post Management

---

#### Get Posts (Feed)

```
GET {{Host}}/posts?pageNumber=1&pageSize=10&searchKey=&type=0
```

**Query Parameters:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `pageNumber` | `int` | ❌ | Default: 1 |
| `pageSize` | `int` | ❌ | Default: 10, Max: 100 |
| `searchKey` | `string?` | ❌ | Filter by description/content |
| `type` | `int?` | ❌ | 0 = Lost, 1 = Found |

**Success Response (200):**

```json
{
  "isSuccess": true,
  "hasData": true,
  "data": {
    "items": [
      {
        "id": 42,
        "userId": "abc123",
        "userName": "Ahmed Mohamed",
        "userProfilePictureUrl": "https://...",
        "imageUrl": "https://...",
        "description": "Lost black wallet near Cairo Mall",
        "latitude": 30.0444,
        "longitude": 31.2357,
        "type": 0,
        "commentsCount": 5,
        "createdAt": "2026-04-10T14:30:00Z",
        "isOwner": false,
        "isFollowedByCurrentUser": true,
        "isSaved": false
      }
    ],
    "pageNumber": 1,
    "totalPages": 5,
    "hasPreviousPage": false,
    "hasNextPage": true
  }
}
```

**Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `id` | `int` | Post ID |
| `userId` | `string` | Author's user ID |
| `userName` | `string?` | Author's display name |
| `userProfilePictureUrl` | `string?` | Author's profile picture URL |
| `imageUrl` | `string?` | Post image URL |
| `description` | `string?` | Post description |
| `latitude` | `double` | Location latitude |
| `longitude` | `double` | Location longitude |
| `type` | `int` | 0 = Lost, 1 = Found |
| `commentsCount` | `int` | Number of comments |
| `createdAt` | `DateTime` | Creation timestamp (UTC) |
| `isOwner` | `bool` | True if current user is the author |
| `isFollowedByCurrentUser` | `bool` | True if user follows the author |
| `isSaved` | `bool` | True if current user has saved this post |

---

## 6.5 UI Handling Logic for Post Actions

### 🎯 Purpose of Boolean Flags

The boolean flags (`isOwner`, `isFollowedByCurrentUser`, `isSaved`) are specifically designed to **simplify UI logic in Flutter** and eliminate the need for additional API calls or complex frontend state management.

### 📱 More Options Menu (3-dots) Logic

The post UI includes a **More Options menu** that should display different actions based on these flags:

#### ✅ Case 1: User is the Owner

```dart
if (post.isOwner) {
  // Show owner-specific actions
  return [
    PopupMenuItem(
      value: 'edit',
      child: ListTile(
        leading: Icon(Icons.edit),
        title: Text('Edit Post'),
      ),
    ),
    PopupMenuItem(
      value: 'delete',
      child: ListTile(
        leading: Icon(Icons.delete, color: Colors.red),
        title: Text('Delete Post'),
      ),
    ),
  ];
}
```

**Menu Options when `isOwner = true`:**
- **Edit Post** - Navigate to post editing screen
- **Delete Post** - Show confirmation dialog and delete post

#### ❌ Case 2: User is NOT the Owner

```dart
if (!post.isOwner) {
  // Show non-owner actions
  return [
    PopupMenuItem(
      value: post.isSaved ? 'unsave' : 'save',
      child: ListTile(
        leading: Icon(post.isSaved ? Icons.bookmark : Icons.bookmark_border),
        title: Text(post.isSaved ? 'Unsave Post' : 'Save Post'),
      ),
    ),
    PopupMenuItem(
      value: post.isFollowedByCurrentUser ? 'unfollow' : 'follow',
      child: ListTile(
        leading: Icon(post.isFollowedByCurrentUser ? Icons.person_remove : Icons.person_add),
        title: Text(post.isFollowedByCurrentUser ? 'Unfollow User' : 'Follow User'),
      ),
    ),
    PopupMenuItem(
      value: 'report',
      child: ListTile(
        leading: Icon(Icons.flag, color: Colors.orange),
        title: Text('Report Post'),
      ),
    ),
  ];
}
```

**Menu Options when `isOwner = false`:**
- **Save / Unsave Post** - Based on `isSaved` flag
- **Follow / Unfollow User** - Based on `isFollowedByCurrentUser` flag
- **Report Post** - Always available for non-owners

### 🛠️ Flutter Implementation Example

```dart
class PostMenuWidget extends StatelessWidget {
  final GetPostsResponse post;
  
  const PostMenuWidget({Key? key, required this.post}) : super(key: key);

  List<PopupMenuEntry<String>> _buildMenuItems() {
    if (post.isOwner) {
      return _buildOwnerMenu();
    } else {
      return _buildNonOwnerMenu();
    }
  }

  List<PopupMenuEntry<String>> _buildOwnerMenu() {
    return [
      PopupMenuItem(
        value: 'edit',
        child: ListTile(
          leading: Icon(Icons.edit),
          title: Text('Edit Post'),
          onTap: () => _editPost(post.id),
        ),
      ),
      PopupMenuItem(
        value: 'delete',
        child: ListTile(
          leading: Icon(Icons.delete, color: Colors.red),
          title: Text('Delete Post'),
          onTap: () => _showDeleteConfirmation(post.id),
        ),
      ),
    ];
  }

  List<PopupMenuEntry<String>> _buildNonOwnerMenu() {
    return [
      PopupMenuItem(
        value: post.isSaved ? 'unsave' : 'save',
        child: ListTile(
          leading: Icon(post.isSaved ? Icons.bookmark : Icons.bookmark_border),
          title: Text(post.isSaved ? 'Unsave Post' : 'Save Post'),
          onTap: () => post.isSaved ? _unsavePost(post.id) : _savePost(post.id),
        ),
      ),
      PopupMenuItem(
        value: post.isFollowedByCurrentUser ? 'unfollow' : 'follow',
        child: ListTile(
          leading: Icon(post.isFollowedByCurrentUser ? Icons.person_remove : Icons.person_add),
          title: Text(post.isFollowedByCurrentUser ? 'Unfollow User' : 'Follow User'),
          onTap: () => post.isFollowedByCurrentUser 
            ? _unfollowUser(post.userId) 
            : _followUser(post.userId),
        ),
      ),
      PopupMenuItem(
        value: 'report',
        child: ListTile(
          leading: Icon(Icons.flag, color: Colors.orange),
          title: Text('Report Post'),
          onTap: () => _reportPost(post.id),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert),
      onSelected: (value) {
        // Handle menu selection
        switch (value) {
          case 'edit':
            _editPost(post.id);
            break;
          case 'delete':
            _showDeleteConfirmation(post.id);
            break;
          case 'save':
            _savePost(post.id);
            break;
          case 'unsave':
            _unsavePost(post.id);
            break;
          case 'follow':
            _followUser(post.userId);
            break;
          case 'unfollow':
            _unfollowUser(post.userId);
            break;
          case 'report':
            _reportPost(post.id);
            break;
        }
      },
      itemBuilder: (context) => _buildMenuItems(),
    );
  }

  void _editPost(int postId) {
    // Navigate to edit post screen
    Navigator.pushNamed(context, '/edit-post', arguments: postId);
  }

  void _showDeleteConfirmation(int postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Post'),
        content: Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePost(postId);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _savePost(int postId) async {
    try {
      await postService.savePost(postId);
      // Update local state or refresh
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post saved')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save post')),
      );
    }
  }

  Future<void> _unsavePost(int postId) async {
    try {
      await postService.unsavePost(postId);
      // Update local state or refresh
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post unsaved')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to unsave post')),
      );
    }
  }

  Future<void> _followUser(String userId) async {
    try {
      await userService.followUser(userId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User followed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to follow user')),
      );
    }
  }

  Future<void> _unfollowUser(String userId) async {
    try {
      await userService.unfollowUser(userId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User unfollowed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to unfollow user')),
      );
    }
  }

  void _reportPost(int postId) {
    // Navigate to report post screen
    Navigator.pushNamed(context, '/report-post', arguments: postId);
  }

  Future<void> _deletePost(int postId) async {
    try {
      await postService.deletePost(postId);
      Navigator.pop(context); // Go back from post details
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete post')),
      );
    }
  }
}
```

### 🧠 Benefits of This Approach

| Benefit | Description |
|---------|-------------|
| **Performance ⚡** | No additional API calls needed to determine user permissions |
| **Simplicity 🧩** | UI logic is straightforward and easy to understand |
| **Maintainability 🛠️** | Changes to permission logic only require backend updates |
| **Consistency 🎯** | All post screens use the same flag-based logic |
| **Real-time Support 🔄** | Flags can be updated via SignalR for instant UI updates |

### 🔄 Real-time Updates

When users perform actions (save/unsave, follow/unfollow), the UI should update optimistically while waiting for backend confirmation:

```dart
// Optimistic update example
Future<void> _toggleSavePost(int postId, bool currentSavedState) async {
  // Update UI immediately
  setState(() {
    post.isSaved = !currentSavedState;
  });

  try {
    if (!currentSavedState) {
      await postService.savePost(postId);
    } else {
      await postService.unsavePost(postId);
    }
  } catch (e) {
    // Revert on error
    setState(() {
      post.isSaved = currentSavedState;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Action failed')),
    );
  }
}
```

---

#### Get Post By ID

```
GET {{Host}}/posts/{postId}
```

**Success Response (200):**

```json
{
  "isSuccess": true,
  "hasData": true,
  "data": {
    "id": 42,
    "userId": "abc123",
    "userName": "Ahmed Mohamed",
    "userProfilePictureUrl": "https://...",
    "imageUrl": "https://...",
    "latitude": 30.0444,
    "longitude": 31.2357,
    "description": "Lost black wallet near Cairo Mall",
    "type": 0,
    "createdAt": "2026-04-10T14:30:00Z",
    "updatedAt": null,
    "isOwner": false,
    "isFollowedByCurrentUser": true,
    "isSaved": false
  }
}
```

---

#### Create Post

```
POST {{Host}}/posts
Content-Type: multipart/form-data
```

**Request Body (Multipart Form):**

| Field | Type | Required | Validation |
|-------|------|----------|------------|
| `Type` | `int` | ✅ | 0 = Lost, 1 = Found |
| `Image` | `IFormFile` | ✅ | Image file (jpg, png) |
| `Latitude` | `double` | ✅ | GPS latitude |
| `Longitude` | `double` | ✅ | GPS longitude |
| `Description` | `string` | ✅ | Non-empty text |

**Success Response (201):**

```json
{
  "isSuccess": true,
  "hasData": true,
  "data": {
    "id": 43,
    "imageUrl": "https://...",
    "latitude": 30.0444,
    "longitude": 31.2357,
    "description": "Lost black wallet near Cairo Mall",
    "type": 0,
    "createdAt": "2026-04-13T14:30:00Z"
  }
}
```

---

#### Update Post

```
PUT {{Host}}/posts/{postId}
Content-Type: multipart/form-data
```

**Request Body (Multipart Form):**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `PostId` | `int` | ✅ | (from route) |
| `Type` | `int?` | ❌ | 0 = Lost, 1 = Found |
| `Image` | `IFormFile?` | ❌ | New image (optional) |
| `Latitude` | `double?` | ❌ | New latitude (optional) |
| `Longitude` | `double?` | ❌ | New longitude (optional) |
| `Description` | `string?` | ❌ | New description (optional) |

**Notes:**
- Only the post owner can update
- Omit fields to keep existing values

---

#### Delete Post

```
DELETE {{Host}}/posts/{postId}
```

**Success Response (200):**

```json
{
  "isSuccess": true,
  "hasData": false
}
```

---

### 6.2 Post Interactions — Comments

---

#### Get Post Comments

```
GET {{Host}}/posts/{postId}/comments?pageNumber=1&pageSize=10
```

**Success Response (200):**

```json
{
  "isSuccess": true,
  "hasData": true,
  "data": {
    "items": [
      {
        "id": 101,
        "postId": 42,
        "userId": "user456",
        "name": "Mohamed Ali",
        "text": "I saw a similar wallet at the security desk",
        "parentCommentId": null,
        "replies": [
          {
            "id": 102,
            "postId": 42,
            "userId": "user789",
            "name": "Sarah Ahmed",
            "text": "What time was that?",
            "parentCommentId": 101,
            "replies": [],
            "createdAt": "2026-04-10T15:00:00Z",
            "updatedAt": null,
            "isOwner": false
          }
        ],
        "createdAt": "2026-04-10T14:45:00Z",
        "updatedAt": null,
        "isOwner": false
      }
    ],
    "pageNumber": 1,
    "totalPages": 1,
    "hasPreviousPage": false,
    "hasNextPage": false
  }
}
```

**Note:** Replies are nested within parent comments. For flat loading, use the replies endpoint.

---

#### Get Comment Replies

```
GET {{Host}}/posts/{postId}/comments/{commentId}/replies?pageNumber=1&pageSize=10
```

**Success Response (200):**

```json
{
  "isSuccess": true,
  "hasData": true,
  "data": {
    "items": [
      {
        "id": 102,
        "userId": "user789",
        "name": "Sarah Ahmed",
        "text": "What time was that?",
        "createdAt": "2026-04-10T15:00:00Z",
        "updatedAt": null,
        "isOwner": false
      }
    ],
    "pageNumber": 1,
    "totalPages": 1,
    "hasPreviousPage": false,
    "hasNextPage": false
  }
}
```

---

#### Add Comment

```
POST {{Host}}/posts/{postId}/comments
```

**Request Body:**

```json
{
  "postId": 42,
  "text": "I saw a similar wallet at the security desk"
}
```

**Field Validation:**

| Field | Type | Required | Validation |
|-------|------|----------|------------|
| `postId` | `int` | ✅ | From route, must be positive |
| `text` | `string` | ✅ | Non-empty, max 1000 characters |

**Success Response (201):**

```json
{
  "isSuccess": true,
  "hasData": true,
  "data": {
    "id": 103,
    "postId": 42,
    "userId": "currentUser",
    "text": "I saw a similar wallet at the security desk",
    "createdAt": "2026-04-13T14:30:00Z",
    "isOwner": true
  }
}
```

> ⚠️ **Important:** After receiving HTTP success, the comment will ALSO arrive via SignalR `CommentAdded` event. Flutter must track pending actions to avoid duplicate UI entries. See Section 6.

---

#### Add Reply

```
POST {{Host}}/posts/{postId}/comments/{parentCommentId}/replies
```

**Request Body:**

```json
{
  "postId": 42,
  "parentCommentId": 101,
  "text": "What time was that?"
}
```

**Success Response (201):**

```json
{
  "isSuccess": true,
  "hasData": true,
  "data": {
    "id": 104,
    "postId": 42,
    "parentCommentId": 101,
    "userId": "currentUser",
    "text": "What time was that?",
    "createdAt": "2026-04-13T14:35:00Z",
    "isOwner": true
  }
}
```

---

#### Update Comment

```
PUT {{Host}}/posts/{postId}/comments/{commentId}
```

**Request Body:**

```json
{
  "commentId": 103,
  "text": "Updated: I saw it around 3 PM at the security desk"
}
```

**Success Response (200):**

```json
{
  "isSuccess": true,
  "hasData": true,
  "data": {
    "id": 103,
    "text": "Updated: I saw it around 3 PM at the security desk",
    "updatedAt": "2026-04-13T14:40:00Z"
  }
}
```

> ⚠️ Users can only update their own comments.

---

#### Delete Comment

```
DELETE {{Host}}/posts/{postId}/comments/{commentId}
```

**Success Response (200):**

```json
{
  "isSuccess": true,
  "hasData": false
}
```

> ⚠️ Users can only delete their own comments. Post owners can delete any comment on their posts.

---

### 6.3 Post Interactions — Reactions

---

#### Get Post Reacts

```
GET {{Host}}/posts/{postId}/reacts?pageNumber=1&pageSize=10
```

**Success Response (200):**

```json
{
  "isSuccess": true,
  "hasData": true,
  "data": {
    "items": [
      {
        "userId": "user456",
        "userName": "Mohamed Ali",
        "userProfilePictureUrl": "https://...",
        "reactType": 0,
        "createdAt": "2026-04-10T14:50:00Z"
      }
    ],
    "pageNumber": 1,
    "totalPages": 1,
    "hasPreviousPage": false,
    "hasNextPage": false
  }
}
```

**ReactType:** 0 = Like, 1 = Dislike

---

#### Get Post React Counts

```
GET {{Host}}/posts/{postId}/reacts/counts
```

**Success Response (200):**

```json
{
  "isSuccess": true,
  "hasData": true,
  "data": {
    "postId": 42,
    "likesCount": 15,
    "dislikesCount": 2,
    "userReactType": 0
  }
}
```

| Field | Type | Description |
|-------|------|-------------|
| `postId` | `int` | Post ID |
| `likesCount` | `int` | Total likes |
| `dislikesCount` | `int` | Total dislikes |
| `userReactType` | `int?` | Current user's reaction: 0 = Like, 1 = Dislike, null = no reaction |

---

#### Toggle React

```
POST {{Host}}/posts/{postId}/reacts
```

**Request Body:**

```json
{
  "postId": 42,
  "reactType": 0
}
```

**Behavior:**
- If user has no reaction → adds the reaction
- If user has different reaction → switches to new reaction
- If user has same reaction → removes the reaction (toggle off)

**Success Response (200):**

```json
{
  "isSuccess": true,
  "hasData": true,
  "data": {
    "postId": 42,
    "currentReactType": 0,
    "likesCount": 16,
    "dislikesCount": 2
  }
}
```

> ⚠️ If `currentReactType` is `null`, the user removed their reaction.

---

#### Remove React

```
DELETE {{Host}}/posts/{postId}/reacts
```

**Success Response (200):**

```json
{
  "isSuccess": true,
  "hasData": false
}
```

---

### 6.4 Saved Posts

---

#### Get Saved Posts

```
GET {{Host}}/saved-posts?pageNumber=1&pageSize=10
```

Returns the same `GetPostsResponse` structure as the main feed.

---

#### Save Post

```
POST {{Host}}/saved-posts
```

**Request Body:**

```json
{
  "postId": 42
}
```

---

#### Unsave Post

```
DELETE {{Host}}/saved-posts
```

**Request Body:**

```json
{
  "postId": 42
}
```

---

## 7) SignalR Real-Time Integration

### 7.1 Hub Configuration

| Property | Value |
|----------|-------|
| Hub URL | `{{Host}}/hubs/post-interaction` |
| Transport | WebSockets with fallback to SSE/Long Polling |
| Auth | Bearer token in query string or connection header |

### 7.2 Connection Lifecycle

```dart
class PostInteractionHubService {
  HubConnection? _connection;
  final String baseUrl;
  final String token;

  PostInteractionHubService({required this.baseUrl, required this.token});

  Future<void> connect() async {
    _connection = HubConnectionBuilder()
      .withUrl(
        '$baseUrl/hubs/post-interaction',
        HttpConnectionOptions(
          accessTokenFactory: () async => token,
        ),
      )
      .withAutomaticReconnect()
      .build();

    // Register event handlers
    _connection!.on('CommentAdded', _handleCommentAdded);
    _connection!.on('ReplyAdded', _handleReplyAdded);
    _connection!.on('CommentUpdated', _handleCommentUpdated);
    _connection!.on('CommentDeleted', _handleCommentDeleted);
    _connection!.on('ReactionUpdated', _handleReactionUpdated);

    await _connection!.start();
  }

  Future<void> disconnect() async {
    await _connection?.stop();
  }
}
```

### 7.3 Join/Leave Post Groups

**Join when entering post details:**

```dart
await _connection!.invoke('JoinPost', args: [postId]);
```

**Leave when exiting post details:**

```dart
await _connection!.invoke('LeavePost', args: [postId]);
```

> ⚠️ **Critical:** Always call `LeavePost` when the user navigates away. SignalR auto-cleans on disconnect, but explicit leaving improves performance.

### 7.4 Event Handling Strategy

```dart
class PostInteractionState {
  int? currentOpenPostId;
  bool isInPostDetailsView = false;
  Set<String> pendingActions = {};
  Map<int, int> unreadCommentCounts = {};
}

// Helper to generate unique action keys
String generateActionKey(String action, int postId, {int? commentId, int? replyId}) {
  return '$action:$postId:${commentId ?? ''}:${replyId ?? ''}:${DateTime.now().millisecondsSinceEpoch}';
}
```

---

## 8) SignalR Event Mapping

### 8.1 Event DTOs

| Event | DTO | Fields |
|-------|-----|--------|
| `CommentAdded` | `CommentAddedDto` | `id`, `postId`, `userId`, `text`, `createdAt` |
| `ReplyAdded` | `ReplyAddedDto` | `id`, `postId`, `parentCommentId`, `userId`, `text`, `createdAt` |
| `CommentUpdated` | `CommentUpdatedDto` | `id`, `postId`, `text`, `updatedAt` |
| `CommentDeleted` | `CommentDeletedDto` | `id`, `postId` |
| `ReactionUpdated` | `ReactionUpdatedDto` | `postId`, `userId`, `currentReactType`, `likesCount`, `dislikesCount` |

### 8.2 Event Handler Implementations

#### CommentAdded

```dart
void _handleCommentAdded(List<Object?>? args) {
  final data = args?.first as Map<String, dynamic>?;
  if (data == null) return;

  final postId = data['postId'] as int;
  final commentId = data['id'] as int;
  final actionKey = 'comment:$postId:$commentId';

  // Skip if this was our own action (already handled optimistically)
  if (state.pendingActions.contains(actionKey)) {
    state.pendingActions.remove(actionKey);
    return;
  }

  if (state.currentOpenPostId == postId && state.isInPostDetailsView) {
    // User is viewing this post — add comment to UI
    _addCommentToUI(Comment.fromJson(data));
  } else {
    // User is elsewhere — increment unread badge
    state.unreadCommentCounts[postId] = (state.unreadCommentCounts[postId] ?? 0) + 1;
    _showNotificationBadge(postId);
  }
}
```

#### ReplyAdded

```dart
void _handleReplyAdded(List<Object?>? args) {
  final data = args?.first as Map<String, dynamic>?;
  if (data == null) return;

  final postId = data['postId'] as int;
  final parentCommentId = data['parentCommentId'] as int?;
  final replyId = data['id'] as int;
  final actionKey = 'reply:$postId:$parentCommentId:$replyId';

  if (state.pendingActions.contains(actionKey)) {
    state.pendingActions.remove(actionKey);
    return;
  }

  if (state.currentOpenPostId == postId && state.isInPostDetailsView) {
    _addReplyToUI(parentCommentId, Reply.fromJson(data));
  } else {
    state.unreadCommentCounts[postId] = (state.unreadCommentCounts[postId] ?? 0) + 1;
  }
}
```

#### CommentUpdated

```dart
void _handleCommentUpdated(List<Object?>? args) {
  final data = args?.first as Map<String, dynamic>?;
  if (data == null) return;

  final postId = data['postId'] as int;
  final commentId = data['id'] as int;
  final actionKey = 'update:$postId:$commentId';

  if (state.pendingActions.contains(actionKey)) {
    state.pendingActions.remove(actionKey);
    return;
  }

  if (state.currentOpenPostId == postId && state.isInPostDetailsView) {
    _updateCommentText(commentId, data['text'] as String);
  }
}
```

#### CommentDeleted

```dart
void _handleCommentDeleted(List<Object?>? args) {
  final data = args?.first as Map<String, dynamic>?;
  if (data == null) return;

  final postId = data['postId'] as int;
  final commentId = data['id'] as int;
  final actionKey = 'delete:$postId:$commentId';

  if (state.pendingActions.contains(actionKey)) {
    state.pendingActions.remove(actionKey);
    return;
  }

  if (state.currentOpenPostId == postId && state.isInPostDetailsView) {
    _removeCommentFromUI(commentId);
  }
}
```

#### ReactionUpdated

```dart
void _handleReactionUpdated(List<Object?>? args) {
  final data = args?.first as Map<String, dynamic>?;
  if (data == null) return;

  final postId = data['postId'] as int;
  final actionKey = 'react:$postId';

  if (state.pendingActions.contains(actionKey)) {
    state.pendingActions.remove(actionKey);
    return;
  }

  // Always update reaction counts (visible in both feed and detail views)
  _updateReactionCounts(
    postId,
    likesCount: data['likesCount'] as int,
    dislikesCount: data['dislikesCount'] as int,
    userReactType: data['currentReactType'] as int?,
  );
}
```

---

## 9) Action Deduplication Pattern

### Critical: Prevent Duplicate UI Updates

When Flutter performs an action via HTTP, it should track that action and ignore the corresponding SignalR event.

```dart
class CommentService {
  final PostInteractionState _state;
  final PostInteractionHubService _hub;
  final Dio _dio;

  Future<Comment> addComment(int postId, String text) async {
    // Generate unique action key BEFORE sending request
    final tempId = DateTime.now().millisecondsSinceEpoch;
    final actionKey = 'comment:$postId:$tempId';
    
    // Add to pending to block SignalR duplicate
    _state.pendingActions.add(actionKey);

    try {
      final response = await _dio.post(
        '/posts/$postId/comments',
        data: {'postId': postId, 'text': text},
      );

      final comment = Comment.fromJson(response.data['data']);
      
      // Optimistically add to UI immediately
      _addCommentToUI(comment);
      
      return comment;
    } catch (e) {
      // Remove from pending on error so SignalR can handle if needed
      _state.pendingActions.remove(actionKey);
      rethrow;
    }
    // Note: Don't remove from pending on success — let SignalR handler do it
    // when it receives the event and matches the key
  }
}
```

---

## 10) Navigation State Management

### Track Current Post Context

```dart
class PostNavigationObserver extends NavigatorObserver {
  final PostInteractionState _state;
  final PostInteractionHubService _hub;

  PostNavigationObserver(this._state, this._hub);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _updateState(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _updateState(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _updateState(newRoute);
  }

  void _updateState(Route<dynamic>? route) {
    if (route?.settings.name == '/post-details') {
      final postId = route!.settings.arguments as int;
      
      // Leave previous post if any
      if (_state.currentOpenPostId != null && _state.currentOpenPostId != postId) {
        _hub.leavePost(_state.currentOpenPostId!);
      }
      
      // Join new post
      _state.currentOpenPostId = postId;
      _state.isInPostDetailsView = true;
      _hub.joinPost(postId);
      
      // Clear unread count for this post
      _state.unreadCommentCounts.remove(postId);
    } else {
      // Left post details
      if (_state.currentOpenPostId != null) {
        _hub.leavePost(_state.currentOpenPostId!);
      }
      _state.currentOpenPostId = null;
      _state.isInPostDetailsView = false;
    }
  }
}
```

---

## 11) Error Codes Reference

| Error Code | HTTP Status | Description |
|------------|-------------|-------------|
| `Post.PostNotFound` | 404 | Post does not exist |
| `PostComment.CommentNotFound` | 404 | Comment does not exist |
| `PostComment.UnauthorizedAccess` | 403 | User cannot modify this comment |
| `PostReact.InvalidReactType` | 400 | Invalid reaction type value |
| `PostImage.InvalidImage` | 400 | Invalid or missing image file |

---

## 12) Flutter Implementation Examples

### 12.1 SignalR Service Provider

```dart
class PostInteractionProvider extends ChangeNotifier {
  final PostInteractionHubService _hub;
  final PostInteractionState _state = PostInteractionState();

  PostInteractionProvider({required String baseUrl, required String token})
      : _hub = PostInteractionHubService(baseUrl: baseUrl, token: token) {
    _initializeListeners();
  }

  PostInteractionState get state => _state;

  Future<void> connect() => _hub.connect();
  Future<void> disconnect() => _hub.disconnect();

  void _initializeListeners() {
    _hub.onCommentAdded = (data) {
      // Handle based on current state
      if (_state.shouldApplyRealtimeUpdate(data.postId)) {
        _addComment(data);
      } else {
        _incrementUnread(data.postId);
      }
      notifyListeners();
    };
    // ... other handlers
  }

  void enterPost(int postId) {
    _hub.joinPost(postId);
    _state.currentOpenPostId = postId;
    _state.isInPostDetailsView = true;
    _state.unreadCommentCounts.remove(postId);
    notifyListeners();
  }

  void exitPost(int postId) {
    _hub.leavePost(postId);
    _state.currentOpenPostId = null;
    _state.isInPostDetailsView = false;
    notifyListeners();
  }
}
```

### 12.2 Complete SignalR Hub Service

```dart
import 'package:signalr_core/signalr_core.dart';

class PostInteractionHubService {
  late HubConnection _connection;
  final String _url;
  final String _token;

  // Callbacks
  void Function(CommentAddedDto)? onCommentAdded;
  void Function(ReplyAddedDto)? onReplyAdded;
  void Function(CommentUpdatedDto)? onCommentUpdated;
  void Function(CommentDeletedDto)? onCommentDeleted;
  void Function(ReactionUpdatedDto)? onReactionUpdated;

  PostInteractionHubService({required String baseUrl, required String token})
      : _url = '$baseUrl/hubs/post-interaction',
        _token = token;

  Future<void> connect() async {
    _connection = HubConnectionBuilder()
      .withUrl(
        _url,
        HttpConnectionOptions(
          accessTokenFactory: () async => _token,
          logging: (level, message) => print('[SignalR] $message'),
        ),
      )
      .withAutomaticReconnect()
      .build();

    _connection.on('CommentAdded', (args) {
      final data = _parseCommentAdded(args);
      onCommentAdded?.call(data);
    });

    _connection.on('ReplyAdded', (args) {
      final data = _parseReplyAdded(args);
      onReplyAdded?.call(data);
    });

    _connection.on('CommentUpdated', (args) {
      final data = _parseCommentUpdated(args);
      onCommentUpdated?.call(data);
    });

    _connection.on('CommentDeleted', (args) {
      final data = _parseCommentDeleted(args);
      onCommentDeleted?.call(data);
    });

    _connection.on('ReactionUpdated', (args) {
      final data = _parseReactionUpdated(args);
      onReactionUpdated?.call(data);
    });

    await _connection.start();
  }

  Future<void> disconnect() => _connection.stop();
  Future<void> joinPost(int postId) => _connection.invoke('JoinPost', args: [postId]);
  Future<void> leavePost(int postId) => _connection.invoke('LeavePost', args: [postId]);

  // Parsers
  CommentAddedDto _parseCommentAdded(List<Object?>? args) => 
      CommentAddedDto.fromJson(args?.first as Map<String, dynamic>);
  ReplyAddedDto _parseReplyAdded(List<Object?>? args) => 
      ReplyAddedDto.fromJson(args?.first as Map<String, dynamic>);
  CommentUpdatedDto _parseCommentUpdated(List<Object?>? args) => 
      CommentUpdatedDto.fromJson(args?.first as Map<String, dynamic>);
  CommentDeletedDto _parseCommentDeleted(List<Object?>? args) => 
      CommentDeletedDto.fromJson(args?.first as Map<String, dynamic>);
  ReactionUpdatedDto _parseReactionUpdated(List<Object?>? args) => 
      ReactionUpdatedDto.fromJson(args?.first as Map<String, dynamic>);
}
```

---

## 13) Best Practices

### ✅ DO

- **Always call `LeavePost`** when navigating away from post details
- **Track pending actions** to prevent duplicate UI updates
- **Apply optimistic updates** immediately on HTTP success, let SignalR confirm
- **Handle reconnection** gracefully — re-join groups after reconnect
- **Use pagination** for comments and reactions (don't load everything)
- **Cache post feed** locally for offline viewing
- **Debounce rapid actions** (e.g., multiple reaction toggles)

### ❌ DON'T

- **Don't rely on SignalR for critical operations** — always use HTTP
- **Don't show error on SignalR disconnection** in background — it's normal
- **Don't assume backend filters events** — Flutter must filter based on state
- **Don't forget to clear pending actions** on error or timeout
- **Don't store SignalR messages indefinitely** — have a retention policy

---

## 14) Common Pitfalls

| Pitfall | Solution |
|---------|----------|
| Duplicate comments appearing | Implement pending action tracking |
| Real-time updates when viewing different post | Check `currentOpenPostId` before applying UI updates |
| Missing updates after reconnect | Re-join all relevant post groups on reconnection |
| Memory leaks from SignalR | Properly dispose and disconnect in widget `dispose()` |
| Race condition: HTTP vs SignalR | Use action keys and timestamps for deduplication |

---

## 15) Quick Reference — All Endpoints

### Post Management

| # | Method | Endpoint | Auth | Request | Response |
|---|--------|----------|------|---------|----------|
| 1 | GET | `/posts` | ✅ | Query: `pageNumber`, `pageSize`, `searchKey`, `type` | `PaginatedList<GetPostsResponse>` |
| 2 | GET | `/posts/{postId}` | ✅ | — | `GetPostByIdResponse` |
| 3 | POST | `/posts` | ✅ | `CreatePostRequest` (multipart) | `CreatePostResponse` |
| 4 | PUT | `/posts/{postId}` | ✅ | `UpdatePostRequest` (multipart) | `UpdatePostResponse` |
| 5 | DELETE | `/posts/{postId}` | ✅ | — | *(no data)* |

### Post Interactions — Comments

| # | Method | Endpoint | Auth | Request | Response |
|---|--------|----------|------|---------|----------|
| 6 | GET | `/posts/{postId}/comments` | ✅ | Query: `pageNumber`, `pageSize` | `PaginatedList<GetPostCommentsResponse>` |
| 7 | GET | `/posts/{postId}/comments/{commentId}/replies` | ✅ | Query: `pageNumber`, `pageSize` | `PaginatedList<GetCommentRepliesResponse>` |
| 8 | POST | `/posts/{postId}/comments` | ✅ | `AddCommentRequest` | `AddCommentResponse` |
| 9 | POST | `/posts/{postId}/comments/{parentCommentId}/replies` | ✅ | `AddReplyRequest` | `AddReplyResponse` |
| 10 | PUT | `/posts/{postId}/comments/{commentId}` | ✅ | `UpdateCommentRequest` | `UpdateCommentResponse` |
| 11 | DELETE | `/posts/{postId}/comments/{commentId}` | ✅ | — | *(no data)* |

### Post Interactions — Reactions

| # | Method | Endpoint | Auth | Request | Response |
|---|--------|----------|------|---------|----------|
| 12 | GET | `/posts/{postId}/reacts` | ✅ | Query: `pageNumber`, `pageSize` | `PaginatedList<GetPostReactsResponse>` |
| 13 | GET | `/posts/{postId}/reacts/counts` | ✅ | — | `GetPostReactCountsResponse` |
| 14 | POST | `/posts/{postId}/reacts` | ✅ | `ToggleReactRequest` | `ToggleReactResponse` |
| 15 | DELETE | `/posts/{postId}/reacts` | ✅ | — | *(no data)* |

### Saved Posts

| # | Method | Endpoint | Auth | Request | Response |
|---|--------|----------|------|---------|----------|
| 16 | GET | `/saved-posts` | ✅ | Query: `pageNumber`, `pageSize` | `PaginatedList<GetPostsResponse>` |
| 17 | POST | `/saved-posts` | ✅ | `SavePostRequest` | *(no data)* |
| 18 | DELETE | `/saved-posts` | ✅ | `UnsavePostRequest` | *(no data)* |

---

## 16) SignalR Event Reference

| Event | Hub Method | When to Join | When to Leave |
|-------|------------|--------------|---------------|
| `CommentAdded` | `JoinPost(postId)` | Enter post details | Exit post details |
| `ReplyAdded` | `JoinPost(postId)` | Enter post details | Exit post details |
| `CommentUpdated` | `JoinPost(postId)` | Enter post details | Exit post details |
| `CommentDeleted` | `JoinPost(postId)` | Enter post details | Exit post details |
| `ReactionUpdated` | `JoinPost(postId)` | Enter post details | Exit post details |

**Group Name Format:** `Post:{postId}` (e.g., `Post:42`)

---

## 17) Required Flutter Packages

```yaml
dependencies:
  # HTTP client
  dio: ^5.0.0
  
  # SignalR client
  signalr_core: ^1.3.0
  
  # Secure storage for tokens
  flutter_secure_storage: ^9.0.0
  
  # State management (choose one)
  flutter_bloc: ^8.1.0
  provider: ^6.1.0
  riverpod: ^2.4.0
```

---

**Questions?** Provide this document to your Flutter team. They have everything needed for posts and real-time interactions implementation.
