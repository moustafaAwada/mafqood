import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mafqood/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mafqood/features/auth/presentation/cubit/auth_state.dart';
import 'package:mafqood/features/auth/presentation/pages/otp_page.dart';

class SignUpPage extends StatefulWidget {
  static const routeName = '/signup';
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  bool _hidePassword = true;

  final Color primaryColor = Colors.lightBlue;

  final _firstNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Validators matching backend rules
  static final _phoneRegex = RegExp(r'^(010|011|012|015)\d{8}$');
  static final _passwordRegex =
      RegExp(r'(?=.*[0-9])(?=.*[!@#$%^&*()\[\]{}\-_+=~`|:;<>,./?]).{6,}');

  @override
  void dispose() {
    _firstNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final authCubit = context.read<AuthCubit>();
    if (authCubit.state.isLoading) return;
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_passwordController.text != _confirmPasswordController.text) {
      return;
    }

    final success = await authCubit.register(
      name: _firstNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phoneNumber: _phoneController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              OtpPage(email: _emailController.text.trim()),
        ),
      );
    }
  }

  InputDecoration _inputDecoration(
    String hint,
    IconData icon,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return InputDecoration(
      filled: true,
      fillColor: theme.scaffoldBackgroundColor,
      prefixIcon: Icon(icon, color: colorScheme.primary),
      hintText: hint,
      hintStyle: TextStyle(
        color: colorScheme.onSurface.withValues(alpha: 0.38),
        fontSize: 14,
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 15),
      // Light border for clean look
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: theme.dividerColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (prev, curr) =>
          prev.error != curr.error && curr.error != null,
      listener: (context, state) {
        if (state.error != null) {
          showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('خطأ'),
              content: Text(state.error!),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('موافق'),
                ),
              ],
            ),
          );
        }
      },
      buildWhen: (prev, curr) => prev.isLoading != curr.isLoading,
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
                      'إنشاء حساب جديد',
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
                          TextFormField(
                            controller: _firstNameController,
                            decoration: _inputDecoration(
                              'الاسم كاملاً',
                              Icons.person_outline,
                              theme,
                              colorScheme,
                            ),
                            validator: (v) =>
                                (v ?? '').isEmpty ? 'الاسم مطلوب' : null,
                          ),

                          SizedBox(height: 12),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration(
                              'البريد الإلكتروني',
                              Icons.email_outlined,
                              theme,
                              colorScheme,
                            ),
                            validator: (v) =>
                                !RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(v ?? '')
                                ? 'البريد الإلكتروني غير صالح'
                                : null,
                          ),
                          SizedBox(height: 12),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration:
                                _inputDecoration(
                                  'رقم الهاتف',
                                  Icons.phone_android_outlined,
                                  theme,
                                  colorScheme,
                                ).copyWith(
                                  prefixIcon: SizedBox(
                                    width: 70,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.arrow_drop_down),
                                        Text('+20'),
                                      ],
                                    ),
                                  ),
                                ),
                            validator: (v) => !_phoneRegex.hasMatch(v ?? '')
                                ? 'رقم غير صالح (11 رقم، يبدأ بـ 010/011/012/015)'
                                : null,
                          ),
                          SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _hidePassword,
                            decoration:
                                _inputDecoration(
                                  'كلمة المرور',
                                  Icons.lock_outline,
                                  theme,
                                  colorScheme,
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _hidePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: theme.dividerColor,
                                    ),
                                    onPressed: () => setState(
                                      () => _hidePassword = !_hidePassword,
                                    ),
                                  ),
                                ),
                            validator: (v) {
                              if ((v ?? '').length < 6) {
                                return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                              }
                              if (!_passwordRegex.hasMatch(v ?? '')) {
                                return 'يجب أن تحتوي على رقم ورمز خاص (!@#...)';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 12),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _hidePassword,
                            decoration: _inputDecoration(
                              'تأكيد كلمة المرور',
                              Icons.lock_outline,
                              theme,
                              colorScheme,
                            ),
                            validator: (v) => v != _passwordController.text
                                ? 'كلمتا المرور غير متطابقتين'
                                : null,
                          ),
                          SizedBox(height: 24),
                          authState.isLoading
                              ? CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(
                                    primaryColor,
                                  ),
                                )
                              : SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      'إنشاء حساب جديد',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: theme.scaffoldBackgroundColor,
                                      ),
                                    ),
                                  ),
                                ),
                          SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: colorScheme.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                backgroundColor: theme.scaffoldBackgroundColor,
                              ),
                              icon: Icon(
                                Icons.g_mobiledata,
                                color: Colors.red,
                                size: 28,
                              ),
                              label: Text(
                                'تسجيل دخول بواسطة جوجل',
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('هل لديك حساب بالفعل؟'),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  'تسجيل الدخول',
                                  style: TextStyle(
                                    color: Color(0xFFFFA000),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
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
}
