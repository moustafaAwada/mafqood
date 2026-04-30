# 🧠 Mafqood — Master Project Blueprint & Story

> **Living Document** — This file is the single source of truth for the project's architecture, conventions, completed milestones, and future roadmap. It MUST be updated whenever a significant task is completed or an architectural rule is established.
>
> **Last Updated:** 2026-04-29

---

## 1. Project Identity & Vision

**Mafqood** (مفقود — "Missing") is an Arabic-language Flutter mobile application designed to help people find and report missing persons or lost items. The app connects community members through posts, real-time chat, notifications, and location tracking.

| Attribute | Value |
|-----------|-------|
| **Language** | Arabic — all UI text inline (no i18n framework yet) |
| **Directionality** | RTL via `Directionality(textDirection: TextDirection.rtl)` |
| **Backend** | ASP.NET Core — `https://mafqood.runasp.net/` |
| **Theme** | Material 3 with `AppColors` light/dark via `ThemeCubit` |
| **Min SDK** | Android 21 / iOS 12 |

---

## 2. Architectural Pillars

### 2.1 Clean Architecture — The Non-Negotiable Rule

Every feature module MUST follow the three-layer structure. No shortcuts, no exceptions.

```
features/<feature>/
├── data/
│   ├── datasources/       # Remote/Local data source interfaces + implementations
│   ├── models/            # DTOs, enums, JSON serialization (fromJson/toJson)
│   ├── repositories/      # Repository implementations (Either<Failure, T>)
│   └── services/          # SignalR hubs, background services
├── domain/
│   ├── entities/           # Pure Dart classes (Equatable, no JSON logic)
│   └── repositories/      # Abstract contracts (return Either<Failure, T>)
└── presentation/
    ├── cubit/              # Cubit + State (business logic orchestration)
    ├── pages/              # Full screen pages
    └── widgets/            # Reusable UI components
```

### 2.2 State Management — Cubit/Bloc

- **Primary:** `flutter_bloc` / `Cubit<State>`.
- All states extend `Equatable` with robust `copyWith()`.
- **Auth pattern:** Subclassed abstract state hierarchy (`AuthState` → `SignInSuccess`, `SignInFailure`, etc.).
- **Feature pattern:** Flat single-class state with `copyWith()` (used by PostFeed, Chat, Account).

### 2.3 Dependency Injection

| Layer | Tool | Location |
|-------|------|----------|
| Singletons | `get_it` | `service_locator.dart` — `CacheHelper`, `AuthStorage`, `ChatHubService` |
| Repositories | `MultiRepositoryProvider` | `main.dart` — each creates its own `Dio` + `DioConsumer` + `AuthInterceptor` |
| Cubits | `MultiBlocProvider` | `main.dart` — inject repository from context + singletons from `getIt` |

### 2.4 API Layer

| Component | Role |
|-----------|------|
| `ApiConsumer` | Abstract interface — `get`, `post`, `put`, `patch`, `delete` |
| `DioConsumer` | Concrete Dio implementation, base URL from `EndPoints.baseUrl` |
| `AuthInterceptor` | Auto-attaches Bearer token; handles 401 with refresh token rotation |
| `EndPoints` | Static constants for all REST endpoints + SignalR hub URLs |

### 2.5 Error Handling — The Unbreakable Chain

```
API Error → DioException → ServerException(ErrorModel.fromJson()) 
  → Repository: catch ServerException → Left(ServerFailure(e.errorModel.errorMessage))
  → Cubit: result.fold(failure → emit error, success → emit data)
```

All repository methods return `Either<Failure, T>` from `dartz`. No exceptions leak to the Cubit layer.

### 2.6 Real-Time — SignalR Contract

SignalR is a **thin notification layer only**. All writes go through REST.

| Rule | Detail |
|------|--------|
| **Never send data via SignalR** | All messages, reads, deletes → REST endpoints |
| **Hub Service pattern** | Follows `PostInteractionHubService` structure: callback properties, `_asMap` helper, connection state guards |
| **Typed DTOs at service layer** | Raw SignalR args → `fromJson()` → typed DTO before reaching Cubit |
| **Auth lifecycle** | `connectHub(token)` on login/splash, `disconnectHub()` on logout |

---

## 3. Feature Pipeline — Standard Workflow

Every new feature integration MUST follow these 6 steps in order. This is the proven pipeline we used for Auth, Posts, Account, and Chat.

### Step 1 — Dependencies & API Infrastructure
- Add packages to `pubspec.yaml`.
- Register REST endpoints in `EndPoints`.
- Register SignalR hub URL (if applicable).

### Step 2 — Data Models & DTOs
- Create enums in `data/models/<feature>_enums.dart`.
- Create API response/request models in `data/models/<feature>_models.dart`.
- Create SignalR DTOs in `data/models/signalr_dtos.dart` (if applicable).
- All models have `fromJson()` factory constructors, `Equatable`, `copyWith()`.

### Step 3 — Domain Layer
- Create pure entities in `domain/entities/` — `Equatable`, no JSON, `copyWith()`.
- Create abstract repository contract in `domain/repositories/` — all methods return `Either<Failure, T>`.

### Step 4 — Data Layer (REST Repository)
- Create abstract `RemoteDataSource` interface — returns data models.
- Create concrete `RemoteDataSourceImpl` — uses `ApiConsumer`, `FormData` for file uploads.
- Create `RepositoryImpl` — wraps remote calls in `try/catch`, maps `ServerException` → `ServerFailure`.

### Step 5 — Services (SignalR / Background)
- Create hub service following `PostInteractionHubService` pattern (if real-time needed).
- Typed callbacks, connection lifecycle, `withAutomaticReconnect()`.

### Step 6 — Presentation (Cubit + UI + DI Wiring)
- Create `State` class extending `Equatable` with all fields + `copyWith()`.
- Create `Cubit` — inject repository, hub service, cache helper as needed.
- Refactor or create UI pages/widgets to consume `BlocBuilder<Cubit, State>`.
- Wire in `service_locator.dart`, `MultiRepositoryProvider`, `MultiBlocProvider` in `main.dart`.

---

## 4. Completed Milestones

### 4.1 ✅ Authentication System
| Aspect | Detail |
|--------|--------|
| **Architecture** | Full Clean Architecture |
| **Features** | Login, Register, OTP Email Verification, Forgot Password, Reset Password, Splash (auto-login) |
| **Security** | `FlutterSecureStorage` for JWT + refresh token, `AuthInterceptor` for auto-refresh on 401 |
| **State** | Subclassed `AuthState` hierarchy — 16 state classes for granular UI reactivity |
| **Files** | `auth_cubit.dart`, `auth_state.dart`, `auth_repository.dart`, `auth_repository_impl.dart`, `auth_remote_data_source_impl.dart`, `auth_local_data_source_impl.dart`, 6 page files |

### 4.2 🔄 Posts / Feed System (In Progress)
| Aspect | Detail |
|--------|--------|
| **Architecture** | Full Clean Architecture + SignalR |
| **Features** | CRUD posts, Reactions, Comments, Replies, Save/Unsave, Follow/Unfollow |
| **Status** | **Phase A** (Endpoints & Models) ✅<br>**Phase B** (Domain Entities & Repo Contract) ✅<br>**Phase C** (Data Layer & Repository Impl) ✅<br>**Phase D** (Hub Service Enhancement & DI Wiring) ✅<br>**Phase E** (Cubit State & Read Operations) ✅<br>**Phase F** (Cubit Write & Optimistic UI) ✅<br>**Phase G & H** (UI Integration & Navigation Bridge) ✅<br>**Phase I** (Polish, DI Audit & Documentation) ✅<br>✅ **INTEGRATION COMPLETE** |

### 4.3 ✅ Account / Profile
| Aspect | Detail |
|--------|--------|
| **Architecture** | Full Clean Architecture |
| **Features** | Edit Profile (name, phone, photo), Change Password, My Posts, Saved Posts, Settings, Donations, Family Care |

### 4.4 ✅ Chat System Integration (The Complex One)
*Completed: 2026-04-29 — 8 steps, 15 new files, 7 modified files*

| Aspect | Detail |
|--------|--------|
| **Architecture** | Full Clean Architecture + REST + SignalR + Offline Outbox |
| **Idempotency** | Every message gets a UUID v4 `clientMessageId` before sending. Backend deduplicates. Safe to retry. |
| **Optimistic UI** | Message appears instantly → REST call → success: update ID / failure: move to outbox |
| **Offline Outbox** | Failed messages queued in `CacheHelper` (JSON). Flushed on reconnect. `retryFailedMessage()` on long-press. |
| **SignalR Events** | 5 server→client events, 4 client→server methods, auto-reconnect with missed message sync via `afterTimestamp` |
| **Auth Lifecycle** | `connectHub(token)` in Splash + Login, `disconnectHub()` in Logout |

#### Chat Files Created
```
data/models/chat_enums.dart          — 5 enums
data/models/chat_models.dart         — 8 DTOs
data/models/signalr_dtos.dart        — 5 SignalR event DTOs
data/datasources/chat_remote_data_source.dart      — Abstract (7 methods)
data/datasources/chat_remote_data_source_impl.dart  — Dio/FormData impl
data/repositories/chat_repository_impl.dart         — Either<Failure,T> wrapper
data/services/chat_hub_service.dart                 — SignalR hub (6 callbacks, 4 methods)
domain/entities/chat_entities.dart                  — 4 entities (ChatRoom, ChatRoomDetail, MessageEntity, OutboxMessage)
domain/repositories/chat_repository.dart            — Abstract contract (7 methods)
presentation/cubit/chat_state.dart                  — 18-field Equatable state
presentation/cubit/chat_cubit.dart                  — Full business logic orchestrator
```

#### Chat API Endpoints
| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/chat/initiate-message` | Send message (multipart/form-data, idempotent) |
| GET | `/chat-rooms` | Paginated chat rooms |
| GET | `/chat-rooms/{id}` | Single room details |
| DELETE | `/chat-rooms/{id}` | Delete room |
| GET | `/chat-rooms/{id}/messages` | Messages (supports `afterTimestamp` sync) |
| PUT | `/chat-rooms/{id}/messages/read` | Mark all as read |
| DELETE | `/chat-rooms/{id}/messages/{msgId}` | Delete message |

#### Chat SignalR Hub
- **URL:** `{baseUrl}/hubs/chat` — Bearer token via `accessTokenFactory`
- **Server → Client:** `MessageReceived`, `MessageUpdated`, `ChatRoomCreated`, `UserTyping`, `UserStoppedTyping`, `UserPresenceChanged`
- **Client → Server:** `JoinChatRoom`, `LeaveChatRoom`, `SendTypingIndicator`, `SendStoppedTypingIndicator`

### 4.5 ✅ Supporting Systems
| System | Status | Notes |
|--------|--------|-------|
| Home / Feed UI | 🔄 In Progress | Integrating with complete Posts backend |
| Main Shell | ✅ Done | Bottom navigation (Home, Notifications, Chat, Account) |
| Location Sync | ✅ Done | Background sync via `WorkManager` |
| Theme System | ✅ Done | Light/Dark mode, Material 3, `ThemeCubit` |
| Family Care | ✅ Done | Subscription, Members, Location, Emergency |
| Donations | ✅ Done | Donation page UI |

---

## 5. Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_bloc` | ^9.1.0 | State management (Cubit) |
| `equatable` | ^2.0.7 | Value equality for states/entities |
| `dio` | ^5.9.2 | HTTP client |
| `dartz` | ^0.10.1 | Functional programming (`Either<L, R>`) |
| `flutter_secure_storage` | ^9.0.0 | Secure JWT/refresh token storage |
| `shared_preferences` | ^2.5.5 | General key-value cache (`CacheHelper`) |
| `get_it` | ^9.2.1 | Service locator / DI |
| `signalr_netcore` | ^1.4.4 | SignalR client for real-time |
| `uuid` | ^4.5.1 | UUID v4 for message idempotency |
| `connectivity_plus` | ^6.1.4 | Network state detection |
| `geolocator` | ^14.0.2 | GPS location |
| `image_picker` | ^0.8.8+5 | Camera/gallery image selection |
| `workmanager` | ^0.9.0+3 | Background tasks (location sync) |
| `cached_network_image` | ^3.4.1 | Image caching and performance |

---

## 6. Roadmap — What's Next

| Task | Priority | Status |
|------|----------|--------|
| Notification Backend Integration | 🔴 High | Next Up |
| Push Notifications (FCM) | 🟡 Medium | Not Started |
| Internationalization (i18n) | 🟢 Low | Not Started |
| Deep Links | 🟢 Low | Not Started |
| Unit / Widget Tests | 🟢 Low | Not Started |

---

## 7. Change Log

| Date | Milestone |
|------|-----------|
| 2026-04-29 | 📄 Initial `AI_PROJECT_MEMORY.md` created. Enforced **Living Document** rule and standardized **6-step feature pipeline**. |
| 2026-04-29 | 🏗️ **Chat Steps 1–2:** Dependencies (`uuid`, `connectivity_plus`), 7 endpoints, 5 enums, 8 data models, 5 SignalR DTOs. |
| 2026-04-29 | 🏗️ **Chat Steps 3–4:** Domain entities (4) + repository contract, Remote data source + repository impl (FormData, afterTimestamp). |
| 2026-04-29 | 🏗️ **Chat Step 5:** `ChatHubService` — 6 typed callbacks, 4 hub methods, auto-reconnect. |
| 2026-04-29 | 🧠 **Chat Step 6:** `ChatCubit` + `ChatState` — idempotent sending, optimistic UI, outbox, 5 event handlers, typing debounce, reconnect sync. |
| 2026-04-29 | 🎨 **Chat Step 7:** 5 UI files refactored — BlocBuilder, delivery status ticks, online dots, typing indicators, scroll pagination. |
| 2026-04-29 | 🔌 **Chat Step 8:** DI wiring in `service_locator.dart` + `main.dart`. |
| 2026-04-29 | 🔐 **Auth ↔ SignalR Lifecycle:** `connectHub` in Splash/Login, `disconnectHub` in Logout. |
| 2026-04-29 | 📘 Restructured memory file into **Master Project Blueprint & Story** format. |
| 2026-04-29 | 🚀 **Posts Phase A:** 100% Complete. 13 endpoints registered, 6 data models (Comments, Replies, Reactions, SavedPosts, Followers, UserProfile). |
| 2026-04-29 | 🚀 **Posts Phase B:** 100% Complete. 5 Domain Entities, `PostRepository` abstract contract expanded to 18 methods. |
| 2026-04-29 | 🚀 **Posts Phase C:** 100% Complete. `PostRemoteDataSourceImpl` and `PostRepositoryImpl` fully implemented with strict `Either<Failure, T>` return values. Zero analysis errors. |
| 2026-04-29 | 🔌 **Posts Phase D:** 100% Complete. `PostInteractionHubService` refactored to match `ChatHubService` lifecycle pattern (`connect(token)`/`disconnect()`). Registered as lazySingleton in DI. Auth lifecycle hooks wired in Splash, Login, and Logout. |
| 2026-04-29 | 🧠 **Posts Phase E:** 100% Complete. `PostFeedState` expanded to 18 fields. `PostFeedCubit` rebuilt with SignalR callback wiring, action key deduplication, feed pagination, post details navigation context (join/leave), and comments pagination. DI wiring updated in `main.dart`. |
| 2026-04-29 | 📝 **Posts Phase F:** 100% Complete. 11 write methods added: Post CRUD (create/update/delete), Comments & Replies (add/update/delete with action key dedup + optimistic UI + rollback), Follow/Unfollow (batch-update all posts by userId), Report stub with successMessage feedback. |
| 2026-04-29 | 🎨 **Posts Phase G & H:** 100% Complete. Created `PostMenuWidget` (owner/non-owner 3-dots menu), refactored `PostCard` to accept `PostItem`, created `PostDetailsPage` with full comment/reply tree and SignalR lifecycle, created `UserProfileScreen` with follow/message buttons, added `ChatCubit.initiateChatWithUser`, wired `/post-details` and `/user-profile` routes. |
| 2026-04-29 | ✨ **Posts Phase I:** 100% Complete. Final DI & provider audit passed (all dependencies correctly injected). All `Image.network`/`NetworkImage` replaced with `CachedNetworkImage` (placeholders + error widgets). Dead code & unused imports cleaned. Implementation plan fully ✅. **POSTS & FEED INTEGRATION 100% COMPLETE. CHAT NAVIGATION BRIDGE 100% COMPLETE.** Zero analysis errors across entire `lib/`. |
