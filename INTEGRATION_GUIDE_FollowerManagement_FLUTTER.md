# Follower Management — Flutter Integration Guide

---

## 1) The Whole Scenario

The follower management system allows users to follow and unfollow other users. This creates a one-way relationship where the follower sees posts from the followed user in their feed.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           FLUTTER CLIENT                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                       │
│  │  User        │  │  Follow      │  │  Unfollow    │                       │
│  │  Profile     │────▶│  User        │  │  User        │                       │
│  │  Screen      │  │  (POST)      │  │  (DELETE)    │                       │
│  └──────────────┘  └──────────────┘  └──────────────┘                       │
│         │                 │                 │                               │
│         │                 │                 │                               │
│         ▼                 ▼                 ▼                               │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │                     REST API Client (HTTP)                            │  │
│  │  • POST /followers/{followedUserId}                                 │  │
│  │  • DELETE /followers/{followedUserId}                               │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         ASP.NET CORE BACKEND                                │
├─────────────────────────────────────────────────────────────────────────────┤
│  REST API Endpoints                                                            │
│  • Follow User — Creates a follower relationship                               │
│  • Unfollow User — Removes a follower relationship                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Step-by-Step Flow

1. **View User Profile** — User navigates to another user's profile page.

2. **Check Follow Status** — The `isFollowedByCurrentUser` flag from the post or user profile indicates if already following.

3. **Follow User** — If not following, call `POST /followers/{followedUserId}` to create the relationship.

4. **Unfollow User** — If already following, call `DELETE /followers/{followedUserId}` to remove the relationship.

5. **UI Update** — Toggle the follow button state optimistically while awaiting server confirmation.

---

## 2) Base Host

```
Base Host: https://mafqood.runasp.net
```

All API requests should be directed to the base host URL, denoted as `{{Host}}`.

All follower endpoints are under the `followers` route prefix:

```
{{Host}}/followers/...
```

---

## 3) Response Pattern

All endpoints follow a unified response pattern.

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
    "code": "Follower.AlreadyFollowing",
    "description": "You are already following this user."
  }
}
```

The HTTP status code also matches `statusCode` in the error body.

---

## 4) Endpoints

---

### 4.1 Follow User

```
POST {{Host}}/followers/{followedUserId}
```

**Route Parameters:**

| Field | Type | Required | Description |
|---|---|---|---|
| `followedUserId` | `string` | ✅ | The user ID to follow |

**Request Body:** None

**Success Response (200):**

```json
{
  "isSuccess": true,
  "hasData": false
}
```

> ✅ The user is now following the target user. Posts from this user will appear in the follower's feed.

**Error Responses:**

| Status | Error Code | Description |
|---|---|---|
| 400 | `Follower.CannotFollowSelf` | Cannot follow yourself |
| 404 | `Follower.UserNotFound` | Target user does not exist |
| 409 | `Follower.AlreadyFollowing` | You are already following this user |

---

### 4.2 Unfollow User

```
DELETE {{Host}}/followers/{followedUserId}
```

**Route Parameters:**

| Field | Type | Required | Description |
|---|---|---|---|
| `followedUserId` | `string` | ✅ | The user ID to unfollow |

**Request Body:** None

**Success Response (200):**

```json
{
  "isSuccess": true,
  "hasData": false
}
```

> ✅ The follow relationship has been removed. Posts from this user will no longer appear in the feed.

**Error Responses:**

| Status | Error Code | Description |
|---|---|---|
| 404 | `Follower.NotFollowing` | You are not following this user |

---

## 5) Error Codes Reference

| Error Code | HTTP Status | Description |
|---|---|---|
| `Follower.UserNotFound` | 404 | Target user not found |
| `Follower.AlreadyFollowing` | 409 | You are already following this user |
| `Follower.NotFollowing` | 404 | You are not following this user |
| `Follower.CannotFollowSelf` | 400 | Cannot follow yourself |

---

## 6) Flutter Implementation Tips

### Follow Button Widget

```dart
class FollowButton extends StatefulWidget {
  final String userId;
  final bool isInitiallyFollowing;
  final VoidCallback? onFollowChanged;

  const FollowButton({
    Key? key,
    required this.userId,
    required this.isInitiallyFollowing,
    this.onFollowChanged,
  }) : super(key: key);

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  late bool isFollowing;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isFollowing = widget.isInitiallyFollowing;
  }

  Future<void> _toggleFollow() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    // Optimistic update
    setState(() => isFollowing = !isFollowing);

    try {
      if (isFollowing) {
        await _followUser();
      } else {
        await _unfollowUser();
      }
      widget.onFollowChanged?.call();
    } catch (e) {
      // Revert on error
      setState(() => isFollowing = !isFollowing);
      _showErrorSnackBar(e);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _followUser() async {
    final response = await dio.post('/followers/${widget.userId}');
    if (response.data['isSuccess'] != true) {
      throw Exception('Failed to follow user');
    }
  }

  Future<void> _unfollowUser() async {
    final response = await dio.delete('/followers/${widget.userId}');
    if (response.data['isSuccess'] != true) {
      throw Exception('Failed to unfollow user');
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
    return ElevatedButton.icon(
      onPressed: isLoading ? null : _toggleFollow,
      icon: isLoading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: isFollowing ? Colors.grey : Colors.white,
              ),
            )
          : Icon(
              isFollowing ? Icons.person_remove : Icons.person_add,
            ),
      label: Text(isFollowing ? 'Unfollow' : 'Follow'),
      style: ElevatedButton.styleFrom(
        backgroundColor: isFollowing ? Colors.grey.shade200 : Theme.of(context).primaryColor,
        foregroundColor: isFollowing ? Colors.black87 : Colors.white,
      ),
    );
  }
}
```

### User Profile Screen Integration

```dart
class UserProfileScreen extends StatelessWidget {
  final String userId;

  const UserProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile>(
      future: userService.getUserProfile(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final user = snapshot.data!;
        final isCurrentUser = userId == currentUserId;

        return Scaffold(
          appBar: AppBar(title: Text(user.name)),
          body: Column(
            children: [
              _buildProfileHeader(user),
              if (!isCurrentUser) ...[
                const SizedBox(height: 16),
                FollowButton(
                  userId: userId,
                  isInitiallyFollowing: user.isFollowedByCurrentUser,
                  onFollowChanged: () {
                    // Refresh feed or profile data
                  },
                ),
              ],
              const SizedBox(height: 16),
              _buildUserPosts(userId),
            ],
          ),
        );
      },
    );
  }
}
```

### Post Menu Integration

Following the pattern from the Post Management guide, the follow/unfollow action is available in the post menu for non-owner users:

```dart
List<PopupMenuEntry<String>> _buildNonOwnerMenu(GetPostsResponse post) {
  return [
    PopupMenuItem(
      value: post.isFollowedByCurrentUser ? 'unfollow' : 'follow',
      child: ListTile(
        leading: Icon(
          post.isFollowedByCurrentUser ? Icons.person_remove : Icons.person_add,
        ),
        title: Text(
          post.isFollowedByCurrentUser ? 'Unfollow User' : 'Follow User',
        ),
        onTap: () async {
          Navigator.pop(context);
          if (post.isFollowedByCurrentUser) {
            await _unfollowUser(post.userId);
          } else {
            await _followUser(post.userId);
          }
        },
      ),
    ),
    // ... other menu items
  ];
}

Future<void> _followUser(String userId) async {
  try {
    final response = await dio.post('/followers/$userId');
    if (response.data['isSuccess'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User followed')),
      );
      // Refresh posts to update isFollowedByCurrentUser flags
      _refreshPosts();
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to follow user')),
    );
  }
}

Future<void> _unfollowUser(String userId) async {
  try {
    final response = await dio.delete('/followers/$userId');
    if (response.data['isSuccess'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User unfollowed')),
      );
      _refreshPosts();
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to unfollow user')),
    );
  }
}
```

---

## 7) Quick Reference — All Endpoints

| # | Method | Endpoint | Auth Required | Response Data |
|---|---|---|---|---|
| 1 | POST | `/followers/{followedUserId}` | ✅ | *(no data)* |
| 2 | DELETE | `/followers/{followedUserId}` | ✅ | *(no data)* |

> All follower endpoints require Bearer token authentication.

---

**Questions?** Provide this document to your Flutter team. They have everything needed for follower management implementation.
