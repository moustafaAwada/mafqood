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
import 'package:mafqood/core/theme/cubit/theme_cubit.dart';
import 'package:mafqood/core/theme/cubit/theme_state.dart';
import 'package:mafqood/core/theme/app_theme.dart';

void main() {
  runApp(MafqoodApp());
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
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) =>
                AuthCubit(authRepository: context.read<AuthRepository>()),
          ),
          BlocProvider<ThemeCubit>(
            create: (context) => ThemeCubit(),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              home: SplashPage(),
              routes: {
                SignUpPage.routeName: (ctx) => SignUpPage(),
                LoginPage.routeName: (ctx) => LoginPage(),
                ForgotPasswordPage.routeName: (ctx) => ForgotPasswordPage(),
                ResetPasswordPage.routeName: (ctx) => ResetPasswordPage(),
                ConfirmationEmailPage.routeName: (ctx) =>
                    ConfirmationEmailPage(),
              },
            );
          },
        ),
      ),
    );
  }
}
