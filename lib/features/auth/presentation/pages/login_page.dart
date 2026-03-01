import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mafqood/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mafqood/features/auth/presentation/cubit/auth_state.dart';
import 'package:mafqood/features/auth/presentation/pages/confirmation_email_page.dart';
import 'package:mafqood/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:mafqood/features/auth/presentation/pages/signup_page.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/login';
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool hidePassword = true;
  bool _rememberMe = false;

  final Map<String, String> _authData = {'email': '', 'password': ''};

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
      // CommonFunctions.showSuccessToast('  اهلاً ${authCubit.state.user.name} ');
    }
    // Error is shown via BlocBuilder from state.error
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (prev, curr) =>
          prev.isLoading != curr.isLoading || prev.error != curr.error,
      builder: (context, authState) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    Center(
                      child: Image.asset(
                        'assets/images/logo.jpg',
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 24),
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'مرحباً بك في ',
                            style: TextStyle(
                              color: Colors.black,
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
                    const SizedBox(height: 4),
                    const Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
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
                          ),
                          const SizedBox(height: 16),
                          _buildInputField(
                            controller: _passwordController,
                            label: 'كلمة المرور',
                            isPassword: true,
                            hidePassword: hidePassword,
                            onTogglePassword: () =>
                                setState(() => hidePassword = !hidePassword),
                            validator: (input) => (input ?? '').length < 3
                                ? 'كلمة المرور قصيرة جداً'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    activeColor: const Color(0xFF00AEEF),
                                    onChanged: (val) {
                                      setState(() {
                                        _rememberMe = val ?? false;
                                      });
                                    },
                                  ),
                                  const Text('تذكرني لاحقاً'),
                                ],
                              ),
                              TextButton(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  ForgotPasswordPage.routeName,
                                ),
                                child: const Text(
                                  'نسيت كلمة المرور؟',
                                  style: TextStyle(
                                    color: Color(0xFFFFA000),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (authState.error != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              authState.error!,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: authState.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF00AEEF),
                                    ),
                                  )
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF00AEEF),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: _submit,
                                    child: const Text(
                                      'تسجيل الدخول',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('لا يوجد لديك حساب؟'),
                              TextButton(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  SignUpPage.routeName,
                                ),
                                child: const Text(
                                  'إنشاء حساب جديد',
                                  style: TextStyle(
                                    color: Color(0xFFFFA000),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ConfirmationEmailPage(
                                  email: _emailController.text.trim(),
                                ),
                              ),
                            ),
                            child: Text(
                              'التحقق من البريد الإلكتروني!',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
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
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBDBDBD)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword && hidePassword,
        validator: validator,
        decoration: InputDecoration(
          hintText: label,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    hidePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: onTogglePassword,
                )
              : null,
        ),
      ),
    );
  }
}
