# User Profile — Flutter Integration Guide

---

## 1) Architecture Overview

The user profile system allows users to view profile information for any user by ID. This is used when tapping on a user's profile picture or name in posts, comments, or chat.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           FLUTTER CLIENT                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                       │
│  │  Post Feed   │  │  Post        │  │  Chat        │                       │
│  │  (Tap User)  │  │  Details     │  │  (Tap User)  │                       │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘                       │
│         │                 │                 │                               │
│         ▼                 ▼                 ▼                               │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │                     REST API Client (HTTP)                            │  │
│  │  • GET /users/{userId}                                               │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
│         │                                                                    │
│         ▼                                                                    │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │                     User Profile Screen                               │  │
│  │  • Display user info                                                  │  │
│  │  • Show Follow/Unfollow button                                        │  │
│  │  • Navigate to chat                                                  │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         ASP.NET CORE BACKEND                                │
├─────────────────────────────────────────────────────────────────────────────┤
│  REST API Endpoints                                                            │
│  • Get User Profile by ID — Returns user info + follow status                  │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2) Base Host & Authentication

```
Base Host: https://mafqood.runasp.net
```

All API requests should be directed to the base host URL, denoted as `{{Host}}`.

**Authentication Required:**

All user profile endpoints require **Bearer Token** authentication.

```
Authorization: Bearer {token}
```

---

## 3) Response Pattern

All endpoints follow a unified response pattern.

### ✅ Success — With Data

```json
{
  "isSuccess": true,
  "hasData": true,
  "data": {
    // response payload here
  }
}
```

### ❌ Failure

```json
{
  "isSuccess": false,
  "statusCode": 404,
  "error": {
    "code": "User.UserNotFound",
    "description": "User not found"
  }
}
```

The HTTP status code matches `statusCode` in the error body.

---

## 4) Endpoints

---

### 4.1 Get User Profile by ID

```
GET {{Host}}/users/{userId}
```

**Route Parameters:**

| Field | Type | Required | Description |
|---|---|---|---|
| `userId` | `string` | ✅ | The user ID to fetch profile for |

**Success Response (200):**

```json
{
  "isSuccess": true,
  "hasData": true,
  "data": {
    "id": "abc123-def456-...",
    "email": "ahmed@example.com",
    "name": "Ahmed Mohamed",
    "phoneNumber": "01012345678",
    "profilePictureUrl": "https://mafqood.runasp.net/images/profiles/abc123.jpg",
    "isFollowedByCurrentUser": true
  }
}
```

**Response Fields:**

| Field | Type | Description |
|---|---|---|
| `id` | `string` | User ID |
| `email` | `string` | User email address |
| `name` | `string` | User display name |
| `phoneNumber` | `string?` | User phone number (nullable) |
| `profilePictureUrl` | `string?` | Profile picture URL (nullable) |
| `isFollowedByCurrentUser` | `bool` | True if current user follows this user |

**Error Responses:**

| Status | Error Code | Description |
|---|---|---|
| 404 | `User.UserNotFound` | User with the specified ID does not exist |
| 401 | `User.InvalidJwtToken` | Invalid or expired JWT token |

---

## 5) Error Codes Reference

| Error Code | HTTP Status | Description |
|---|---|---|
| `User.UserNotFound` | 404 | User not found |
| `User.InvalidJwtToken` | 401 | Invalid JWT token |

---

## 6) Flutter Implementation Tips

### User Profile Screen

```dart
class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  GetUserProfileByIdResponse? _userProfile;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await dio.get('/users/${widget.userId}');
      
      if (response.data['isSuccess'] == true) {
        setState(() {
          _userProfile = GetUserProfileByIdResponse.fromJson(response.data['data']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.data['error']?['description'] ?? 'Failed to load profile';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadUserProfile,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final user = _userProfile!;
    final isCurrentUser = user.id == currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: Text(user.name),
        actions: [
          if (!isCurrentUser)
            IconButton(
              icon: const Icon(Icons.message),
              onPressed: () => _startChat(user.id),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 60,
              backgroundImage: user.profilePictureUrl != null
                  ? NetworkImage(user.profilePictureUrl!)
                  : null,
              child: user.profilePictureUrl == null
                  ? const Icon(Icons.person, size: 60)
                  : null,
            ),
            const SizedBox(height: 16),
            
            // Name
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Email
            Text(
              user.email,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            
            // Phone (if available)
            if (user.phoneNumber != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    user.phoneNumber!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Action Buttons (only for other users)
            if (!isCurrentUser) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Follow/Unfollow Button
                  Expanded(
                    child: FollowButton(
                      userId: user.id,
                      isInitiallyFollowing: user.isFollowedByCurrentUser,
                      onFollowChanged: _loadUserProfile,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Message Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _startChat(user.id),
                      icon: const Icon(Icons.message),
                      label: const Text('Message'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  void _startChat(String userId) {
    Navigator.pushNamed(context, '/chat', arguments: userId);
  }
}
```

### Response Model

```dart
class GetUserProfileByIdResponse {
  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final String? profilePictureUrl;
  final bool isFollowedByCurrentUser;

  GetUserProfileByIdResponse({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    this.profilePictureUrl,
    required this.isFollowedByCurrentUser,
  });

  factory GetUserProfileByIdResponse.fromJson(Map<String, dynamic> json) {
    return GetUserProfileByIdResponse(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      isFollowedByCurrentUser: json['isFollowedByCurrentUser'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'profilePictureUrl': profilePictureUrl,
      'isFollowedByCurrentUser': isFollowedByCurrentUser,
    };
  }
}
```

### Integration with Post Card

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
          // User Header (Tappable)
          InkWell(
            onTap: () => _navigateToUserProfile(context, post.userId),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: post.userProfilePictureUrl != null
                        ? NetworkImage(post.userProfilePictureUrl!)
                        : null,
                    child: post.userProfilePictureUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.userName ?? 'Unknown User',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (post.isFollowedByCurrentUser)
                          const Text(
                            'Following',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ... rest of post card
        ],
      ),
    );
  }

  void _navigateToUserProfile(BuildContext context, String userId) {
    Navigator.pushNamed(
      context,
      '/user-profile',
      arguments: userId,
    );
  }
}
```

### Navigation Setup

```dart
// In your app's router/navigation
MaterialPageRoute getRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/user-profile':
      final userId = settings.arguments as String;
      return MaterialPageRoute(
        builder: (_) => UserProfileScreen(userId: userId),
      );
    // ... other routes
  }
}
```

---

## 7) Quick Reference — All Endpoints

| # | Method | Endpoint | Auth | Response |
|---|---|---|---|---|
| 1 | GET | `/users/{userId}` | ✅ | `GetUserProfileByIdResponse` |

---

## 8) Related Features

This endpoint works together with:

- **Follower Management** — Use the `isFollowedByCurrentUser` flag to show correct Follow/Unfollow button state
- **Chat System** — Navigate to chat from user profile
- **Post Management** — Tap on post author to view their profile

---

**Questions?** Provide this document to your Flutter team. They have everything needed for user profile implementation.
