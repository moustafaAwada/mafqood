import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mafqood/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mafqood/features/auth/presentation/cubit/auth_state.dart';
import 'package:mafqood/features/auth/presentation/pages/login_page.dart';

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
      duration: const Duration(milliseconds: 700),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) => _initApp());
  }

  Future<void> _initApp() async {
    try {
      await context.read<AuthCubit>().initialize();
    } catch (_) {}

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // Navigate based on auth state: authenticated -> home (or Login for now); else -> Login
    final isLoggedIn = context.read<AuthCubit>().state.status == AuthStatus.authenticated;
    if (isLoggedIn) {
      // TODO: Replace with MainScreen when available
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ScaleTransition(
          scale: _scale,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image.asset(
              //   'assets/images/edited-photo.png',
              //   width: 140,
              //   height: 140,
              // ),
              const SizedBox(height: 12),
              Text(
                'Mafqood',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // if (loc?.appSubtitle != null) ...[
              //   const SizedBox(height: 6),
              //   Text(
              //     loc!.appSubtitle,
              //     style: const TextStyle(fontSize: 12, color: Colors.black54),
              //   ),
              // ],
            ],
          ),
        ),
      ),
    );
  }
}
