import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mafqood/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mafqood/features/auth/presentation/cubit/auth_state.dart';

class ResetPasswordPage extends StatefulWidget {
  static const routeName = '/reset-password';
  const ResetPasswordPage({super.key});

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _hidePassword = true;

  InputDecoration getInputDecoration(
    String hint,
    IconData iconData,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return InputDecoration(
      filled: true,
      hintText: hint,
      hintStyle: TextStyle(
        color: colorScheme.onSurface.withOpacity(0.6),
        fontSize: 14,
      ),
      prefixIcon: Icon(iconData, color: colorScheme.primary),
      contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: theme.dividerColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: theme.dividerColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFFF65054), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFFF65054), width: 2),
      ),
    );
  }

  Future<void> _submit() async {
    final authCubit = context.read<AuthCubit>();
    if (authCubit.state.isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    final success = await authCubit.resetPassword(
      code: _otpController.text.trim(),
      newPassword: _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          final pendingEmail = authState.pendingEmail ?? '';
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: colorScheme.onSurface,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height * 0.02),
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock_reset_outlined,
                          size: 56,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.04),
                    Text(
                      'إنشاء كلمة مرور جديدة',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'قم بإدخال كلمة المرور الجديدة',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: size.height * 0.02),
                    if (pendingEmail.isNotEmpty)
                      Text(
                        pendingEmail,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14),
                      ),
                    SizedBox(height: size.height * 0.03),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            decoration: getInputDecoration(
                              'الرمز المرسل إليك',
                              Icons.security,
                              theme,
                              colorScheme,
                            ),
                            validator: (input) =>
                                (input ?? '').isEmpty ? 'أدخل الرمز' : null,
                          ),
                          SizedBox(height: size.height * 0.02),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _hidePassword,
                            decoration:
                                getInputDecoration(
                                  'كلمة المرور الجديدة',
                                  Icons.lock,
                                  theme,
                                  colorScheme,
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _hidePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () => setState(
                                      () => _hidePassword = !_hidePassword,
                                    ),
                                  ),
                                ),
                            validator: (input) => (input ?? '').length < 6
                                ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'
                                : null,
                          ),
                          SizedBox(height: size.height * 0.02),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _hidePassword,
                            decoration: getInputDecoration(
                              'تأكيد كلمة المرور',
                              Icons.lock,
                              theme,
                              colorScheme,
                            ),
                            validator: (input) {
                              if (input != _passwordController.text) {
                                return 'كلمتا المرور غير متطابقتين';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
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
                    SizedBox(height: size.height * 0.04),
                    SizedBox(
                      width: double.infinity,
                      height: size.height * 0.065,
                      child: authState.isLoading
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: _submit,
                              child: Text(
                                'حفظ',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: theme.scaffoldBackgroundColor,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
