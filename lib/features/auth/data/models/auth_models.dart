library;


class RegisterRequest {
  final String name;
  final String email;
  final String phoneNumber;
  final String password;
  final String deviceId;

  const RegisterRequest({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.deviceId,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password,
        'deviceId': deviceId,
      };
}

class LoginRequest {
  final String email;
  final String password;
  final String deviceId;

  const LoginRequest({
    required this.email,
    required this.password,
    required this.deviceId,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'deviceId': deviceId,
      };
}

class ConfirmEmailRequest {
  final String userId;
  final String code;

  const ConfirmEmailRequest({
    required this.userId,
    required this.code,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'code': code,
      };
}

class ForgetPasswordRequest {
  final String email;

  const ForgetPasswordRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

class ResetPasswordRequest {
  final String email;
  final String code;
  final String newPassword;

  const ResetPasswordRequest({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'code': code,
        'newPassword': newPassword,
      };
}

class RefreshTokenRequest {
  final String token;
  final String refreshToken;

  const RefreshTokenRequest({
    required this.token,
    required this.refreshToken,
  });

  Map<String, dynamic> toJson() => {
        'token': token,
        'refreshToken': refreshToken,
      };
}

class RevokeTokenRequest {
  final String token;
  final String refreshToken;

  const RevokeTokenRequest({
    required this.token,
    required this.refreshToken,
  });

  Map<String, dynamic> toJson() => {
        'token': token,
        'refreshToken': refreshToken,
      };
}

// ============ Response Models ============

class RegisterResponse {
  final String userId;

  const RegisterResponse({required this.userId});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      userId: json['userId'] as String? ?? '',
    );
  }
}

class AuthResponse {
  final String id;
  final String email;
  final String name;
  final String phoneNumber;
  final String token;
  final int expiresIn;
  final String refreshToken;
  final DateTime refreshTokenExpiration;

  const AuthResponse({
    required this.id,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.token,
    required this.expiresIn,
    required this.refreshToken,
    required this.refreshTokenExpiration,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      token: json['token'] as String? ?? '',
      expiresIn: json['expirseIn'] as int? ?? 3600,
      refreshToken: json['refreshToken'] as String? ?? '',
      refreshTokenExpiration: json['refreshTokenExpiration'] != null
          ? DateTime.parse(json['refreshTokenExpiration'] as String)
          : DateTime.now().add(const Duration(days: 7)),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'phoneNumber': phoneNumber,
        'token': token,
        'expirseIn': expiresIn,
        'refreshToken': refreshToken,
        'refreshTokenExpiration': refreshTokenExpiration.toIso8601String(),
      };
}

class ForgetPasswordResponse {
  final String email;

  const ForgetPasswordResponse({required this.email});

  factory ForgetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgetPasswordResponse(
      email: json['email'] as String? ?? '',
    );
  }
}
