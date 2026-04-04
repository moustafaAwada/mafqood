import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mafqood/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mafqood/features/auth/presentation/cubit/auth_state.dart';
import 'package:mafqood/features/auth/presentation/pages/reset_password_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  static const routeName = '/forgot-password';
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  InputDecoration getInputDecoration(
    String hint,
    IconData iconData,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return InputDecoration(
      filled: true,
      // fillColor: kBackgroundColor,
      hintText: hint,
      hintStyle: TextStyle(
        color: colorScheme.onSurface.withOpacity(0.6),
        fontSize: 14,
      ),
      prefixIcon: Icon(
        iconData,
        // color: kTextLowBlackColor
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: theme.scaffoldBackgroundColor, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: theme.scaffoldBackgroundColor, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: theme.scaffoldBackgroundColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFFF65054), width: 2),
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

    final success = await authCubit.forgetPassword(
      email: _emailController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, ResetPasswordPage.routeName);
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
        buildWhen: (prev, curr) =>
            prev.isLoading != curr.isLoading || prev.error != curr.error,
        builder: (context, authState) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: colorScheme.onSurface,
              title: Text('نسيت كلمة المرور'),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height * 0.04),
                    Image.asset(
                      'assets/images/forgetPassword.png',
                      height: size.height * 0.26,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: size.height * 0.05),
                    Text(
                      'ادخل البريد الإلكتروني المسجل ليتم إرسال رمز إعادة تعيين كلمة المرور.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: size.height * 0.04),
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _emailController,
                        decoration: getInputDecoration(
                          'البريد الإلكتروني',
                          Icons.email_outlined,
                          theme,
                          colorScheme,
                        ),
                        validator: (input) =>
                            !RegExp(r".+@.+\..+").hasMatch(input ?? '')
                            ? 'بريد إلكتروني غير صالح'
                            : null,
                      ),
                    ),
                    SizedBox(height: size.height * 0.04),
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
                                'إرسال الرمز',
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
