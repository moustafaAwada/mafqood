import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mafqood/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mafqood/features/auth/presentation/cubit/auth_state.dart';
import 'package:mafqood/features/main/presentation/main_shell_page.dart';

class OtpPage extends StatefulWidget {
  static const routeName = '/otp';
  final String email;

  const OtpPage({super.key, required this.email});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final List<TextEditingController> _digitControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _secondsRemaining = 60;
  bool _enableResend = false;
  Timer? _timer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _digitControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = 60;
      _enableResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _enableResend = true;
        });
        _timer?.cancel();
      }
    });
  }

  String get _otpCode => _digitControllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  void _clearOtp() {
    for (final c in _digitControllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
    setState(() {});
  }

  Future<void> _verifyOtp() async {
    if (_otpCode.length < 6) return;

    setState(() => _isLoading = true);

    try {
      final auth = context.read<AuthCubit>();
      final success = await auth.confirmEmail(code: _otpCode);

      if (!mounted) return;

      if (success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainShellPage()),
          (route) => false,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    if (!_enableResend) return;
    
    setState(() => _isLoading = true);
    try {
      final success = await context
          .read<AuthCubit>()
          .resendConfirmationEmail(email: widget.email);
          
      if (success && mounted) {
        _clearOtp();
        _startTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم إرسال رمز تحقق جديد إلى بريدك الإلكتروني'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.close,
                  color: colorScheme.onSurface,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Image.asset(
                        "assets/images/edited-photo.png",
                        height: 100,
                        width: 100,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.mark_email_unread_outlined, size: 80, color: colorScheme.primary),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'التحقق من البريد الإلكتروني',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'لقد أرسلنا رمزاً مكوناً من 6 أرقام إلى\n${widget.email}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 48),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(6, (i) {
                          return Container(
                            width: MediaQuery.of(context).size.width * 0.11,
                            height: MediaQuery.of(context).size.width * 0.13,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _focusNodes[i].hasFocus
                                    ? colorScheme.primary
                                    : colorScheme.onSurface.withOpacity(0.2),
                                width: _focusNodes[i].hasFocus ? 2 : 1,
                              ),
                            ),
                            child: TextFormField(
                              controller: _digitControllers[i],
                              focusNode: _focusNodes[i],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                              decoration: const InputDecoration(
                                counterText: '',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (v) => _onDigitChanged(i, v),
                            ),
                          );
                        }),
                      ),
                      if (authState.error != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          authState.error!,
                          style: TextStyle(color: colorScheme.error),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                      if (_isLoading || authState.isLoading)
                        const CircularProgressIndicator()
                      else
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _otpCode.length == 6 ? _verifyOtp : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'متابعة',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.scaffoldBackgroundColor,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: _enableResend && !_isLoading && !authState.isLoading
                              ? _resendOtp
                              : null,
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                              color: _enableResend ? colorScheme.primary : theme.dividerColor,
                            ),
                          ),
                          child: Text(
                            _enableResend ? 'إعادة إرسال الرمز' : "إعادة الإرسال بعد $_secondsRemaining ثانية",
                            style: TextStyle(
                              color: _enableResend ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.5),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
