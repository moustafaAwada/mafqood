# Saved Posts Management — Flutter Integration Guide

---

## 1) The Whole Scenario

The saved posts system allows users to bookmark posts they want to revisit later. Users can save any post (except their own), view their saved posts collection, and remove posts from their saved list.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           FLUTTER CLIENT                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  Post Feed   │  │  Post        │  │  Saved       │  │  Unsave      │  │
│  │  (Save)      │  │  Details     │  │  Posts       │  │  Post        │  │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  │
│         │                 │                 │                 │          │
│         │                 │                 │                 │          │
│         ▼                 ▼                 ▼                 ▼          │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │                     REST API Client (HTTP)                            │  │
│  │  • POST /saved-posts/{postId}                                        │  │
│  │  • DELETE /saved-posts/{postId}                                      │  │
│  │  • GET /saved-posts?pageNumber=1&pageSize=10                         │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         ASP.NET CORE BACKEND                                │
├─────────────────────────────────────────────────────────────────────────────┤
│  REST API Endpoints                                                            │
│  • Save Post — Adds a post to user's saved collection                          │
│  • Unsave Post — Removes a post from user's saved collection                   │
│  • Get Saved Posts — Returns paginated list of saved posts                     │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Step-by-Step Flow

1. **View Post** — User sees a post in the feed or post details screen.

2. **Check Save Status** — The `isSaved` flag from the post indicates if already saved.

3. **Save Post** — If not saved, call `POST /saved-posts/{postId}` to add to saved collection.

4. **View Saved Posts** — Navigate to saved posts screen and call `GET /saved-posts` to retrieve the collection.

5. **Unsave Post** — Call `DELETE /saved-posts/{postId}` to remove from saved collection.

---

## 2) Base Host

```
Base Host: https://mafqood.runasp.net
```

All API requests should be directed to the base host URL, denoted as `{{Host}}`.

All saved posts endpoints are under the `saved-posts` route prefix:

```
{{Host}}/saved-posts/...
```

---

## 3) Response Pattern

All endpoints follow a unified response pattern.

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
  "statusCode": 409,
  "error": {
    "code": "SavedPost.AlreadySaved",
    "description": "Post is already saved."
  }
}
```

The HTTP status code also matches `statusCode` in the error body.

---

## 4) Enums Reference

### PostType

| Value | Name | Description |
|-------|------|-------------|
| `0` | `Lost` | User lost an item and is searching for it |
| `1` | `Found` | User found an item and is trying to return it |

---

## 5) REST API Endpoints

---

### 5.1 Save Post

```
POST {{Host}}/saved-posts/{postId}
```

**Route Parameters:**

| Field | Type | Required | Description |
|---|---|---|---|
| `postId` | `int` | ✅ | The post ID to save |

**Request Body:** None

**Success Response (200):**

```json
{
  "isSuccess": true,
  "hasData": false
}
```

> ✅ The post is now saved to the user's collection.

**Error Responses:**

| Status | Error Code | Description |
|---|---|---|
| 404 | `SavedPost.PostNotFound` | Post does not exist |
| 409 | `SavedPost.AlreadySaved` | Post is already saved |

---

### 5.2 Unsave Post

```
DELETE {{Host}}/saved-posts/{postId}
```

**Route Parameters:**

| Field | Type | Required | Description |
|---|---|---|---|
| `postId` | `int` | ✅ | The post ID to unsave |

**Request Body:** None

**Success Response (200):**

```json
{
  "isSuccess": true,
  "hasData": false
}
```

> ✅ The post has been removed from the user's saved collection.

**Error Responses:**

| Status | Error Code | Description |
|---|---|---|
| 404 | `SavedPost.NotSaved` | Post is not in your saved list |

---

### 5.3 Get Saved Posts

```
GET {{Host}}/saved-posts?pageNumber=1&pageSize=10
```

**Query Parameters:**

| Field | Type | Required | Description |
|---|---|---|---|
| `pageNumber` | `int` | ❌ | Default: 1 |
| `pageSize` | `int` | ❌ | Default: 10, Max: 100 |

**Success Response (200):**

```json
{
  "isSuccess": true,
  "hasData": true,
  "data": {
    "items": [
      {
        "postId": 42,
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
        "savedAt": "2026-04-13T10:15:00Z",
        "isOwner": false,
        "isFollowedByCurrentUser": true
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
|---|---|---|
| `postId` | `int` | Post ID |
| `userId` | `string` | Author's user ID |
| `userName` | `string?` | Author's display name |
| `userProfilePictureUrl` | `string?` | Author's profile picture URL |
| `imageUrl` | `string?` | Post image URL |
| `description` | `string?` | Post description |
| `latitude` | `double` | Location latitude |
| `longitude` | `double` | Location longitude |
| `type` | `int` | 0 = Lost, 1 = Found |
| `commentsCount` | `int` | Number of comments |
| `createdAt` | `DateTime` | Post creation timestamp (UTC) |
| `savedAt` | `DateTime` | When the post was saved (UTC) |
| `isOwner` | `bool` | True if current user is the author |
| `isFollowedByCurrentUser` | `bool` | True if user follows the author |

> ℹ️ Saved posts are ordered by `savedAt` in descending order (most recently saved first).

---

## 6) Error Codes Reference

| Error Code | HTTP Status | Description |
|---|---|---|
| `SavedPost.PostNotFound` | 404 | Post not found |
| `SavedPost.AlreadySaved` | 409 | Post is already saved |
| `SavedPost.NotSaved` | 404 | Post is not in your saved list |

---

## 7) Flutter Implementation Tips

### Save Button Widget

```dart
class SaveButton extends StatefulWidget {
  final int postId;
  final bool isInitiallySaved;
  final VoidCallback? onSaveChanged;

  const SaveButton({
    Key? key,
    required this.postId,
    required this.isInitiallySaved,
    this.onSaveChanged,
  }) : super(key: key);

  @override
  State<SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton> {
  late bool isSaved;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isSaved = widget.isInitiallySaved;
  }

  Future<void> _toggleSave() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    // Optimistic update
    setState(() => isSaved = !isSaved);

    try {
      if (isSaved) {
        await _savePost();
      } else {
        await _unsavePost();
      }
      widget.onSaveChanged?.call();
    } catch (e) {
      // Revert on error
      setState(() => isSaved = !isSaved);
      _showErrorSnackBar(e);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _savePost() async {
    final response = await dio.post('/saved-posts/${widget.postId}');
    if (response.data['isSuccess'] != true) {
      throw Exception('Failed to save post');
    }
  }

  Future<void> _unsavePost() async {
    final response = await dio.delete('/saved-posts/${widget.postId}');
    if (response.data['isSuccess'] != true) {
      throw Exception('Failed to unsave post');
    }
  }

  void _showErrorSnackBar(dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error is DioException 
          ? error.response?.data?['error']?['description'] ?? 'Action failed'
          : 'Action failed'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: isLoading ? null : _toggleSave,
      icon: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: isSaved ? Theme.of(context).primaryColor : null,
            ),
    );
  }
}
```

### Post Card Integration

```dart
class PostCard extends StatelessWidget {
  final GetPostsResponse post;

  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header with user info
          _buildPostHeader(),
          // Post image
          _buildPostImage(),
          // Action bar
          Row(
            children: [
              // Like/Dislike buttons
              _buildReactionButtons(),
              const Spacer(),
              // Save button
              if (!post.isOwner)
                SaveButton(
                  postId: post.id,
                  isInitiallySaved: post.isSaved,
                  onSaveChanged: () {
                    // Trigger refresh if needed
                  },
                ),
              // More options menu
              _buildMoreOptionsMenu(),
            ],
          ),
          // Post description
          _buildDescription(),
        ],
      ),
    );
  }
}
```

### Saved Posts Screen

```dart
class SavedPostsScreen extends StatefulWidget {
  const SavedPostsScreen({Key? key}) : super(key: key);

  @override
  State<SavedPostsScreen> createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends State<SavedPostsScreen> {
  final List<GetSavedPostsResponse> _savedPosts = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadSavedPosts();
  }

  Future<void> _loadSavedPosts({bool refresh = false}) async {
    if (_isLoading) return;
    if (!refresh && !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final page = refresh ? 1 : _currentPage;
      final response = await dio.get(
        '/saved-posts',
        queryParameters: {'pageNumber': page, 'pageSize': 10},
      );

      if (response.data['isSuccess'] == true) {
        final data = response.data['data'];
        final items = (data['items'] as List)
            .map((e) => GetSavedPostsResponse.fromJson(e))
            .toList();

        setState(() {
          if (refresh) {
            _savedPosts.clear();
          }
          _savedPosts.addAll(items);
          _currentPage = data['pageNumber'] + 1;
          _totalPages = data['totalPages'];
          _hasMore = data['hasNextPage'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load saved posts')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _unsavePost(int postId) async {
    try {
      final response = await dio.delete('/saved-posts/$postId');
      if (response.data['isSuccess'] == true) {
        setState(() {
          _savedPosts.removeWhere((p) => p.postId == postId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post removed from saved')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to remove post')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Posts')),
      body: RefreshIndicator(
        onRefresh: () => _loadSavedPosts(refresh: true),
        child: _savedPosts.isEmpty && !_isLoading
            ? _buildEmptyState()
            : ListView.builder(
                itemCount: _savedPosts.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _savedPosts.length) {
                    _loadSavedPosts();
                    return const Center(child: CircularProgressIndicator());
                  }
                  return SavedPostCard(
                    post: _savedPosts[index],
                    onUnsave: () => _unsavePost(_savedPosts[index].postId),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No saved posts yet',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Save posts to view them here',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
```

### Post Menu Integration

Following the pattern from the Post Management guide, the save/unsave action is available in the post menu for non-owner users:

```dart
List<PopupMenuEntry<String>> _buildNonOwnerMenu(GetPostsResponse post) {
  return [
    PopupMenuItem(
      value: post.isSaved ? 'unsave' : 'save',
      child: ListTile(
        leading: Icon(
          post.isSaved ? Icons.bookmark : Icons.bookmark_border,
        ),
        title: Text(
          post.isSaved ? 'Unsave Post' : 'Save Post',
        ),
        onTap: () async {
          Navigator.pop(context);
          if (post.isSaved) {
            await _unsavePost(post.id);
          } else {
            await _savePost(post.id);
          }
        },
      ),
    ),
    // ... other menu items
  ];
}

Future<void> _savePost(int postId) async {
  try {
    final response = await dio.post('/saved-posts/$postId');
    if (response.data['isSuccess'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post saved')),
      );
      _refreshPosts();
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to save post')),
    );
  }
}

Future<void> _unsavePost(int postId) async {
  try {
    final response = await dio.delete('/saved-posts/$postId');
    if (response.data['isSuccess'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post unsaved')),
      );
      _refreshPosts();
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to unsave post')),
    );
  }
}
```

### Saved Post Card Widget

```dart
class SavedPostCard extends StatelessWidget {
  final GetSavedPostsResponse post;
  final VoidCallback onUnsave;

  const SavedPostCard({
    Key? key,
    required this.post,
    required this.onUnsave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () => _navigateToPostDetails(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post image
            if (post.imageUrl != null)
              Image.network(
                post.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User info
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: post.userProfilePictureUrl != null
                            ? NetworkImage(post.userProfilePictureUrl!)
                            : null,
                        child: post.userProfilePictureUrl == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          post.userName ?? 'Unknown User',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      // Unsave button
                      IconButton(
                        icon: const Icon(Icons.bookmark, color: Colors.blue),
                        onPressed: onUnsave,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Description
                  if (post.description != null)
                    Text(
                      post.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  // Saved timestamp
                  Text(
                    'Saved on ${_formatDate(post.savedAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToPostDetails(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/post-details',
      arguments: post.postId,
    );
  }
}
```

---

## 8) Quick Reference — All Endpoints

| # | Method | Endpoint | Auth | Request | Response |
|---|---|---|---|---|---|
| 1 | POST | `/saved-posts/{postId}` | ✅ | — | *(no data)* |
| 2 | DELETE | `/saved-posts/{postId}` | ✅ | — | *(no data)* |
| 3 | GET | `/saved-posts` | ✅ | Query: `pageNumber`, `pageSize` | `PaginatedList<GetSavedPostsResponse>` |

> All saved posts endpoints require Bearer token authentication.

---

**Questions?** Provide this document to your Flutter team. They have everything needed for saved posts implementation.
