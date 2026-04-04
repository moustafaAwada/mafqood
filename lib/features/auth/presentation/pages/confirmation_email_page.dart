import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mafqood/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mafqood/features/auth/presentation/cubit/auth_state.dart';
import 'package:mafqood/features/auth/presentation/pages/login_page.dart';

class ConfirmationEmailPage extends StatefulWidget {
  static const routeName = '/confirmation-email';
  final String? email;

  const ConfirmationEmailPage({super.key, this.email});

  @override
  State<ConfirmationEmailPage> createState() => _ConfirmationEmailPageState();
}

class _ConfirmationEmailPageState extends State<ConfirmationEmailPage> {
  late final TextEditingController _codeController;
  late final TextEditingController _emailController;
  bool _isLoading = false;
  bool _codeSent = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _emailController = TextEditingController(text: widget.email ?? '');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final pendingUserId = context.read<AuthCubit>().state.pendingUserId;
      if (pendingUserId != null) {
        setState(() => _codeSent = true);
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    // if (_emailController.text.isEmpty) {
    //   Fluttertoast.showToast(msg: "يرجى إدخال البريد الإلكتروني");
    //   return;
    // }

    // setState(() => _isLoading = true);
    // final auth = context.read<AuthCubit>();

    // final success = await auth.resendConfirmationEmail(
    //   email: _emailController.text.trim(),
    // );

    // if (!mounted) return;
    // setState(() => _isLoading = false);

    // if (success) {
    //   setState(() => _codeSent = true);
    //   Fluttertoast.showToast(msg: "تم إرسال رمز التحقق");
    // } else {
    //   Fluttertoast.showToast(msg: auth.state.error ?? "فشل إرسال الرمز");
    // }
  }

  Future<void> _confirmEmail() async {
    if (!_codeSent) return;
    if (_codeController.text.isEmpty || _codeController.text.length < 4) {
      // Fluttertoast.showToast(msg: "رمز التحقق غير صحيح");
      return;
    }

    // final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);

    try {
      final auth = context.read<AuthCubit>();
      final success = await auth.confirmEmail(
        code: _codeController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        // Fluttertoast.showToast(msg: l10n.accountVerified);
        //     Navigator.of(
        //       context,
        //     ).pushNamedAndRemoveUntil(MainScreen.routeName, (route) => false);
        //   } else {
        //     Fluttertoast.showToast(msg: auth.state.error ?? l10n.invalidOtp);
      }
    } catch (e) {
      // Fluttertoast.showToast(msg: l10n.authFailed);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (prev, curr) =>
          prev.isLoading != curr.isLoading || prev.error != curr.error,
      builder: (context, authState) {
        return Scaffold(
          // backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                // color: AppColors.textPrimary
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      // color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.email_outlined,
                      size: 50,
                      // color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'verifyEmailTitle',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      // color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),

                  // Step 1: Email Input
                  AnimatedOpacity(
                    duration: Duration(milliseconds: 300),
                    opacity: _codeSent ? 0.6 : 1.0,
                    child: TextFormField(
                      controller: _emailController,
                      enabled: !_codeSent, // Disable if code already sent
                      decoration: InputDecoration(
                        labelText: 'email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: _codeSent
                            ? IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () =>
                                    setState(() => _codeSent = false),
                              )
                            : null,
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),

                  SizedBox(height: 20),

                  // Button to trigger Step 1 (only if code not sent)
                  if (!_codeSent)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _sendCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.onSurface,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.scaffoldBackgroundColor,
                                ),
                              )
                            : Text(
                                "إرسال رمز التحقق",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: theme.scaffoldBackgroundColor,
                                ),
                              ),
                      ),
                    ),

                  if (_codeSent) ...[
                    SizedBox(height: 20),
                    Text(
                      'أدخل رمز التحقق المرسل إلى بريدك الإلكتروني',
                      style: TextStyle(
                        fontSize: 14,
                        // color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _codeController,
                      decoration: InputDecoration(
                        labelText: 'رمز التحقق',
                        hintText: "أدخل رمز التحقق المكون من 6 أرقام هنا",
                        prefixIcon: Icon(Icons.pin),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _confirmEmail,
                        style: ElevatedButton.styleFrom(
                          // backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.scaffoldBackgroundColor,
                                ),
                              )
                            : Text(
                                'sendCode',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: theme.scaffoldBackgroundColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () => setState(() => _codeSent = false),
                      child: Text("لم يصلك الرمز؟ إعادة الإرسال"),
                    ),
                  ],

                  if (authState.error != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        authState.error!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          LoginPage.routeName,
                          (route) => false,
                        ),
                    child: Text('backToLogin', style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
