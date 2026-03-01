/// Application-wide constants.
/// Kept in core so any layer can depend on core if needed.
class AppConstants {
  AppConstants._();

  /// Minimum password length for validation.
  static const int minPasswordLength = 6;

  /// OTP code length (e.g. for email confirmation, password reset).
  static const int otpLength = 6;
}
