# Posts & Feed Integration — Implementation Plan

This roadmap covers the end-to-end integration of the Posts & Feed feature, including REST API implementation for CRUD, follow/unfollow, and saved post management, alongside real-time interaction via SignalR and new UI navigation flows.

## Phase A: Dependencies, API Infrastructure & Data Models ✅
- Update `pubspec.yaml` (ensure `cached_network_image` is present).
- Register all REST endpoints in `EndPoints` class (Posts, Comments, Reactions, SavedPosts, Followers, UserProfile).
- Create Data Models and DTOs:
  - `CommentModel`, `ReplyModel`, `SavedPostModel`, `CreatePostResponseModel`.
  - SignalR DTOs (5 events).
  - `UserProfileModel`.

## Phase B: Domain Layer ✅
- Create pure entities (`CommentEntity`, `ReplyEntity`, `SavedPostItem`, `UserProfileEntity`) extending `Equatable` with `copyWith` and no JSON serialization.
- Expand `PostItem.copyWith` to include `isFollowedByCurrentUser` and `commentsCount`.
- Expand the `PostRepository` abstract contract with 18 methods covering all new endpoints.
  - All methods must return `Either<Failure, T>`.

## Phase C: Data Layer ✅
- Expand `PostRemoteDataSource` interface to include the 18 methods returning concrete data models.
- Implement the 18 methods in `PostRemoteDataSourceImpl` using `ApiConsumer` and exact route patterns, extracting `_extractData` helper.
- Update `PostRepositoryImpl` to implement all 18 methods using the strict `Either<Failure, T>` try-catch pattern. Include Model → Entity mapping to ensure domain purity.

## Phase D: Services (SignalR) ✅
- Update `PostInteractionHubService` to support connection lifecycle and event callbacks for comments, replies, and reactions.
- Ensure typed DTOs are mapped from raw SignalR map responses.

## Phase E: Presentation State & Cubit (Part 1 - Setup & Read) ✅
- Update `PostFeedState` to handle the expanded data (pagination, current user profile, specific post states).
- Expand `PostCubit` to handle fetching posts, searching, and managing the core feed state.
- Wire up `service_locator.dart` and `MultiBlocProvider` in `main.dart` if not already done.

## Phase F: Presentation Cubit (Part 2 - Write & Real-time) ✅
- Implement Create/Update/Delete Post in `PostCubit`.
- Implement adding comments/replies and toggling reactions.
- Implement saving posts and following/unfollowing users.
- Wire SignalR listeners in `PostCubit` to update the state optimistically or re-fetch when events are received.

## Phase G: UI Integration - Feed & Post Cards ✅
- Update the main feed UI to consume `PostCubit`.
- Refactor `PostCard` to display correct data, handle tap actions for reactions, save, and profile navigation.
- Implement the 3-dots menu logic based on ownership (Edit/Delete vs Report).

## Phase H: UI Integration - Comments & Profiles ✅
- Build/Refactor the `CommentsBottomSheet` and `PostDetailsPage` to display nested comments and replies.
- Build/Refactor `UserProfileScreen` to display user details and their posts.
- Ensure routing navigation scenarios defined in the chat integration guide work (e.g., navigating to profile from chat).

## Phase I: Polish & Bug Fixes ✅
- Address edge cases, error states, and loading indicators.
- Perform final static analysis and manual testing.
- Optimize image loading with `cached_network_image`.
