import 'package:flutter/material.dart';
import 'package:mafqood/features/auth/presentation/pages/confirmation_email_page.dart';
import 'package:mafqood/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:mafqood/features/auth/presentation/pages/login_page.dart';
import 'package:mafqood/features/auth/presentation/pages/reset_password_page.dart';
import 'package:mafqood/features/auth/presentation/pages/signup_page.dart';
import 'package:mafqood/features/auth/presentation/pages/splash_page.dart';

void main() {
  runApp(const MafqoodApp());
}

class MafqoodApp extends StatelessWidget {
  const MafqoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashPage(),
      routes: {
        SignUpPage.routeName: (ctx) => const SignUpPage(),
        LoginPage.routeName: (ctx) => const LoginPage(),
        ForgotPasswordPage.routeName: (ctx) => const ForgotPasswordPage(),
        ResetPasswordPage.routeName: (ctx) => const ResetPasswordPage(),
        // MainScreen.routeName: (ctx) => const MainScreen(),
        ConfirmationEmailPage.routeName: (ctx) => const ConfirmationEmailPage(),
      },
    );
  }
}
