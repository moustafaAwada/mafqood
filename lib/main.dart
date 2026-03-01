import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mafqood/features/auth/data/datasources/auth_local_data_source_impl.dart';
import 'package:mafqood/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:mafqood/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mafqood/features/auth/domain/repositories/auth_repository.dart';
import 'package:mafqood/features/auth/presentation/cubit/auth_cubit.dart';
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
    return RepositoryProvider<AuthRepository>(
      create: (_) => AuthRepositoryImpl(
        remote: AuthRemoteDataSourceImpl(),
        local: AuthLocalDataSourceImpl(),
      ),
      child: BlocProvider<AuthCubit>(
        create: (context) =>
            AuthCubit(authRepository: context.read<AuthRepository>()),
        child: MaterialApp(
          home: const SplashPage(),
          routes: {
            SignUpPage.routeName: (ctx) => const SignUpPage(),
            LoginPage.routeName: (ctx) => const LoginPage(),
            ForgotPasswordPage.routeName: (ctx) => const ForgotPasswordPage(),
            ResetPasswordPage.routeName: (ctx) => const ResetPasswordPage(),
            ConfirmationEmailPage.routeName: (ctx) =>
                const ConfirmationEmailPage(),
          },
        ),
      ),
    );
  }
}
