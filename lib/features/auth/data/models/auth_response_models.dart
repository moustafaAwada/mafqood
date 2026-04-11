class RegisterResponse {
  final String userId;

  RegisterResponse({required this.userId});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(userId: json['userId'] as String? ?? '');
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

  AuthResponse({
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
      expiresIn: json['expiresIn'] as int? ?? json['expirseIn'] as int? ?? 3600,
      refreshToken: json['refreshToken'] as String? ?? '',
      refreshTokenExpiration: json['refreshTokenExpiration'] != null
          ? DateTime.parse(json['refreshTokenExpiration'] as String)
          : DateTime.now().add(Duration(days: 7)),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'phoneNumber': phoneNumber,
    'token': token,
    'expiresIn': expiresIn,
    'refreshToken': refreshToken,
    'refreshTokenExpiration': refreshTokenExpiration.toIso8601String(),
  };
}

class ForgetPasswordResponse {
  final String email;

  ForgetPasswordResponse({required this.email});

  factory ForgetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgetPasswordResponse(email: json['email'] as String? ?? '');
  }
}
