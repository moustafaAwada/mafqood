class RegisterRequest {
  final String name;
  final String email;
  final String phoneNumber;
  final String password;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phoneNumber': phoneNumber,
    'password': password,
  };
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}

class ConfirmEmailRequest {
  final String userId;
  final String code;

  ConfirmEmailRequest({required this.userId, required this.code});

  Map<String, dynamic> toJson() => {'userId': userId, 'code': code};
}

class ForgetPasswordRequest {
  final String email;

  ForgetPasswordRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

class ResetPasswordRequest {
  final String email;
  final String code;
  final String newPassword;

  ResetPasswordRequest({
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

  RefreshTokenRequest({required this.token, required this.refreshToken});

  Map<String, dynamic> toJson() => {
    'token': token,
    'refreshToken': refreshToken,
  };
}

class RevokeTokenRequest {
  final String token;
  final String refreshToken;

  RevokeTokenRequest({required this.token, required this.refreshToken});

  Map<String, dynamic> toJson() => {
    'token': token,
    'refreshToken': refreshToken,
  };
}
