import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mafqood/core/api/auth_interceptor.dart';
import 'package:mafqood/core/database/auth_storage.dart';
import 'package:mafqood/core/database/cache/cache_helper.dart';
import 'package:mafqood/core/services/service_locator.dart';
import 'package:mafqood/features/auth/data/datasources/auth_local_data_source_impl.dart';
import 'package:mafqood/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:mafqood/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:mafqood/core/api/dio_consumer.dart';
import 'package:mafqood/features/auth/domain/repositories/auth_repository.dart';
import 'package:mafqood/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mafqood/features/auth/presentation/pages/otp_page.dart';
import 'package:mafqood/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:mafqood/features/auth/presentation/pages/login_page.dart';
import 'package:mafqood/features/auth/presentation/pages/reset_password_page.dart';
import 'package:mafqood/features/auth/presentation/pages/signup_page.dart';
import 'package:mafqood/features/auth/presentation/pages/splash_page.dart';
import 'package:mafqood/core/theme/cubit/theme_cubit.dart';
import 'package:mafqood/core/theme/cubit/theme_state.dart';
import 'package:mafqood/core/theme/app_theme.dart';
import 'package:mafqood/core/services/location_sync_service.dart';
import 'package:mafqood/features/account/data/datasources/account_remote_data_source_impl.dart';
import 'package:mafqood/features/account/data/repositories/account_repository_impl.dart';
import 'package:mafqood/features/account/domain/repositories/account_repository.dart';
import 'package:mafqood/features/account/presentation/cubit/account_cubit.dart';
import 'package:mafqood/features/posts/data/datasources/post_remote_data_source_impl.dart';
import 'package:mafqood/features/posts/data/repositories/post_repository_impl.dart';
import 'package:mafqood/features/posts/domain/repositories/post_repository.dart';
import 'package:mafqood/features/posts/presentation/cubit/post_feed_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  await getIt<CacheHelper>().init();
  await LocationSyncService.initialize();
  runApp(MafqoodApp());
}

class MafqoodApp extends StatelessWidget {
  const MafqoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) {
            final authStorage = getIt<AuthStorage>();
            final dio = Dio();
            final apiConsumer = DioConsumer(
              dio: dio,
              interceptors: [AuthInterceptor(dio: dio, authStorage: authStorage)],
            );

            return AuthRepositoryImpl(
              remote: AuthRemoteDataSourceImpl(api: apiConsumer),
              local: AuthLocalDataSourceImpl(authStorage: authStorage),
            );
          },
        ),
        RepositoryProvider<AccountRepository>(
          create: (_) {
            final authStorage = getIt<AuthStorage>();
            final dio = Dio();
            final apiConsumer = DioConsumer(
              dio: dio,
              interceptors: [AuthInterceptor(dio: dio, authStorage: authStorage)],
            );
            return AccountRepositoryImpl(
              remote: AccountRemoteDataSourceImpl(api: apiConsumer),
            );
          },
        ),
        RepositoryProvider<PostRepository>(
          create: (_) {
            final authStorage = getIt<AuthStorage>();
            final dio = Dio();
            final apiConsumer = DioConsumer(
              dio: dio,
              interceptors: [AuthInterceptor(dio: dio, authStorage: authStorage)],
            );
            return PostRepositoryImpl(
              remote: PostRemoteDataSourceImpl(api: apiConsumer),
            );
          },
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) =>
                AuthCubit(authRepository: context.read<AuthRepository>()),
          ),
          BlocProvider<AccountCubit>(
            create: (context) => AccountCubit(
                accountRepository: context.read<AccountRepository>()),
          ),
          BlocProvider<PostFeedCubit>(
            create: (context) =>
                PostFeedCubit(postRepository: context.read<PostRepository>()),
          ),
          BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeState.isDarkMode
                  ? ThemeMode.dark
                  : ThemeMode.light,
              home: SplashPage(),
              routes: {
                SignUpPage.routeName: (ctx) => SignUpPage(),
                LoginPage.routeName: (ctx) => LoginPage(),
                ForgotPasswordPage.routeName: (ctx) => ForgotPasswordPage(),
                ResetPasswordPage.routeName: (ctx) => ResetPasswordPage(),
                OtpPage.routeName: (ctx) =>
                    // Since OtpPage requires 'email', we extract it from settings arguments if passed, otherwise default to empty.
                    OtpPage(email: ModalRoute.of(ctx)!.settings.arguments as String? ?? ''),
              },
            );
          },
        ),
      ),
    );
  }
}
