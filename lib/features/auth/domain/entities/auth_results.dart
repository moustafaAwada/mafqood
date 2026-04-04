class RegisterResult {
  final String userId;

  RegisterResult({required this.userId});
}

class AuthUserResult {
  final String id;
  final String email;
  final String name;
  final String phoneNumber;

  AuthUserResult({
    required this.id,
    required this.email,
    required this.name,
    required this.phoneNumber,
  });
}

class ForgetPasswordResult {
  final String email;

  ForgetPasswordResult({required this.email});
}
