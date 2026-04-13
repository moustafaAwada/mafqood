import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mafqood/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mafqood/features/auth/presentation/cubit/auth_state.dart';
import 'package:mafqood/features/auth/presentation/pages/otp_page.dart';
import 'package:mafqood/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:mafqood/features/auth/presentation/pages/signup_page.dart';
import 'package:mafqood/features/main/presentation/main_shell_page.dart';


class LoginPage extends StatefulWidget {
  static const routeName = '/login';
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool hidePassword = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _submit() async {
    final authCubit = context.read<AuthCubit>();
    if (authCubit.state.isLoading) return;
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final success = await authCubit.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainShellPage()),
        (route) => false,
      );
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
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 16),
                    Center(
                      child: Image.asset(
                        'assets/images/logo.jpg',
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 24),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'مرحباً بك في ',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: 'مفقود',
                            style: TextStyle(
                              color: Color(0xFFFFA000),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 32),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildInputField(
                            controller: _emailController,
                            label: 'البريد الإلكتروني',
                            keyboardType: TextInputType.emailAddress,
                            validator: (input) =>
                                !RegExp(r".+@.+\..+").hasMatch(input ?? '')
                                ? 'بريد إلكتروني غير صالح'
                                : null,
                            theme: theme,
                          ),
                          SizedBox(height: 16),
                          _buildInputField(
                            controller: _passwordController,
                            label: 'كلمة المرور',
                            isPassword: true,
                            hidePassword: hidePassword,
                            onTogglePassword: () =>
                                setState(() => hidePassword = !hidePassword),
                            validator: (input) =>
                                (input ?? '').length < 6
                                ? 'كلمة المرور قصيرة جداً (6 أحرف على الأقل)'
                                : null,
                            theme: theme,
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  ForgotPasswordPage.routeName,
                                ),
                                child: Text(
                                  'نسيت كلمة المرور؟',
                                  style: TextStyle(
                                    color: Color(0xFFFFA000),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // ── Error display ──
                          if (authState.error != null) ...[
                            SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colorScheme.error.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: colorScheme.error.withOpacity(0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    authState.error!,
                                    style: TextStyle(
                                      color: colorScheme.error,
                                      fontSize: 13,
                                    ),
                                  ),
                                  // If email not confirmed, show a quick verify link
                                  if (authState is SignInFailure &&
                                      (authState.error?.contains(
                                              'EmailNotConfirmed') ==
                                          true ||
                                          authState.error?.contains(
                                                  'لم يتم تأكيد') ==
                                              true)) ...[
                                    const SizedBox(height: 6),
                                    GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => OtpPage(
                                            email:
                                                _emailController.text.trim(),
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'انقر هنا لتأكيد بريدك الإلكتروني',
                                        style: TextStyle(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          decoration:
                                              TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                          SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: authState.isLoading
                                ? Center(
                                    child: CircularProgressIndicator(
                                      color: colorScheme.primary,
                                    ),
                                  )
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: _submit,
                                    child: Text(
                                      'تسجيل الدخول',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: theme.scaffoldBackgroundColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          ),
                          SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('لا يوجد لديك حساب؟'),
                              TextButton(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  SignUpPage.routeName,
                                ),
                                child: Text(
                                  'إنشاء حساب جديد',
                                  style: TextStyle(
                                    color: Color(0xFFFFA000),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // ── Verify email link ──
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OtpPage(
                                  email: _emailController.text.trim(),
                                ),
                              ),
                            ),
                            child: Text(
                              'تأكيد البريد الإلكتروني',
                              style: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.5),
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    bool isPassword = false,
    bool hidePassword = false,
    VoidCallback? onTogglePassword,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    required ThemeData theme,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFBDBDBD)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword && hidePassword,
        validator: validator,
        decoration: InputDecoration(
          hintText: label,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    hidePassword ? Icons.visibility_off : Icons.visibility,
                    color: theme.dividerColor.withOpacity(0.6),
                  ),
                  onPressed: onTogglePassword,
                )
              : null,
        ),
      ),
    );
  }
}
