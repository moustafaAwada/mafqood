class EndPoints {
  static const String baseUrl = 'https://mafqood.runasp.net/';

  // ─── Auth ────────────────────────────────────────────────────────────
  static const String login = 'auth/login';
  static const String register = 'auth/register';
  static const String confirmEmail = 'auth/confirm-email';
  static const String resendConfirmationEmail =
      'auth/resend-confirmation-email';
  static const String forgetPassword = 'auth/forget-password';
  static const String resetPassword = 'auth/reset-password';
  static const String refreshToken = 'auth/refresh-token';
  static const String revokeRefreshToken = 'auth/revoke-refresh-token';

  // ─── Location ────────────────────────────────────────────────────────
  static const String updateLocation = 'me/location';

  // ─── Posts — Management ──────────────────────────────────────────────
  static const String posts = 'posts';

  static String postById(int postId) => 'posts/$postId';

  // ─── Posts — Comments ────────────────────────────────────────────────
  static String postComments(int postId) => 'posts/$postId/comments';

  static String commentById(int postId, int commentId) =>
      'posts/$postId/comments/$commentId';

  // ─── Posts — Replies ─────────────────────────────────────────────────
  static String commentReplies(int postId, int commentId) =>
      'posts/$postId/comments/$commentId/replies';

  // ─── Posts — Reactions ───────────────────────────────────────────────
  static String postReacts(int postId) => 'posts/$postId/reacts';

  static String postReactCounts(int postId) => 'posts/$postId/reacts/counts';

  // ─── Saved Posts (route-param based per new guide) ───────────────────
  static const String savedPosts = 'saved-posts';

  static String savePost(int postId) => 'saved-posts/$postId';

  static String unSavePost(int postId) => 'saved-posts/$postId';

  // ─── Followers ───────────────────────────────────────────────────────
  static String followUser(String userId) => 'followers/$userId';

  static String unfollowUser(String userId) => 'followers/$userId';

  // ─── User Profile ───────────────────────────────────────────────────
  static String userProfile(String userId) => 'users/$userId';
  static const String me = 'me'; // Get current user profile
  static const String updateInfo = 'me/info';
  static const String updateProfilePicture = 'me/profile-picture';

  // ─── Chat ────────────────────────────────────────────────────────────
  static const String initiateMessage = 'chat/initiate-message';
  static const String chatRooms = 'chat-rooms';

  static String chatRoomById(int chatRoomId) => 'chat-rooms/$chatRoomId';

  static String chatRoomMessages(int chatRoomId) =>
      'chat-rooms/$chatRoomId/messages';

  static String markMessagesRead(int chatRoomId) =>
      'chat-rooms/$chatRoomId/messages/read';

  static String deleteMessage(int chatRoomId, int messageId) =>
      'chat-rooms/$chatRoomId/messages/$messageId';

  // ─── SignalR Hubs ────────────────────────────────────────────────────
  static const String postInteractionHub = 'hubs/post-interactions';  // Plural per integration guide
  static const String chatHub = 'hubs/chat';
}

class ApiKey {
  static const String email = 'email';
  static const String password = 'password';
}
