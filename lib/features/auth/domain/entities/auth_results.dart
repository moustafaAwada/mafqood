class RegisterResult {
  final String userId;

  const RegisterResult({required this.userId});
}

class AuthUserResult {
  final String id;
  final String email;
  final String name;
  final String phoneNumber;

  const AuthUserResult({
    required this.id,
    required this.email,
    required this.name,
    required this.phoneNumber,
  });
}

class ForgetPasswordResult {
  final String email;

  const ForgetPasswordResult({required this.email});
}
