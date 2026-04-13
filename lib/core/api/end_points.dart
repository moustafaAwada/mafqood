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
}

class ApiKey {
  static const String email = 'email';
  static const String password = 'password';
}
