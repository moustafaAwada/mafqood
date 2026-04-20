class EndPoints {
  static const String baseUrl = 'https://mafqood.runasp.net/';
  static const String login = 'auth/login';
  static const String register = 'auth/register';
  static const String confirmEmail = 'auth/confirm-email';
  static const String resendConfirmationEmail =
      'auth/resend-confirmation-email';
  static const String forgetPassword = 'auth/forget-password';
  static const String resetPassword = 'auth/reset-password';
  static const String refreshToken = 'auth/refresh-token';
  static const String revokeRefreshToken = 'auth/revoke-refresh-token';
  static const String updateLocation = 'me/location';
  static const String posts = 'posts';
  static const String savedPosts = 'saved-posts';
  static const String postInteractionHub = 'hubs/post-interaction';

  static String postById(int postId) => 'posts/$postId';
  static String postComments(int postId) => 'posts/$postId/comments';
  static String commentById(int postId, int commentId) =>
      'posts/$postId/comments/$commentId';
  static String commentReplies(int postId, int commentId) =>
      'posts/$postId/comments/$commentId/replies';
  static String postReacts(int postId) => 'posts/$postId/reacts';
  static String postReactCounts(int postId) => 'posts/$postId/reacts/counts';
}

class ApiKey {
  static const String email = 'email';
  static const String password = 'password';
}
