import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mafqood/core/database/auth_storage.dart';
import 'package:mafqood/core/services/service_locator.dart';
import 'package:mafqood/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mafqood/features/auth/presentation/cubit/auth_state.dart';
import 'package:mafqood/features/auth/presentation/pages/login_page.dart';
import 'package:mafqood/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:mafqood/features/main/presentation/main_shell_page.dart';
import 'package:mafqood/features/posts/data/services/post_interaction_hub_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) => _initApp());
  }

  Future<void> _initApp() async {
    try {
      await context.read<AuthCubit>().initialize();
    } catch (_) {}

    await Future.delayed(Duration(seconds: 1));

    if (!mounted) return;

    final isLoggedIn =
        context.read<AuthCubit>().state.status == AuthStatus.authenticated;
    if (isLoggedIn) {
      // Connect SignalR hubs with the stored JWT
      final token = await getIt<AuthStorage>().getToken();
      if (token != null && mounted) {
        context.read<ChatCubit>().connectHub(token);
        getIt<PostInteractionHubService>().connect(token);
      }
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => MainShellPage()));
    } else {
      Navigator.of(
        context,
        // ).pushReplacement(MaterialPageRoute(builder: (_) => MainShellPage()));
      ).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: ScaleTransition(
          scale: _scale,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/logo.jpg',
                width: 300,
                height: 300,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 12),
              Text(
                'Mafqood',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              // if (loc?.appSubtitle != null) ...[
              //   SizedBox(height: 6),
              //   Text(
              //     loc!.appSubtitle,
              //     style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.6)),
              //   ),
              // ],
            ],
          ),
        ),
      ),
    );
  }
}
