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

  InputDecoration getInputDecoration(String hint, IconData iconData) {
    return InputDecoration(
      filled: true,
      // fillColor: kBackgroundColor,
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black54, fontSize: 14),
      prefixIcon: Icon(
        iconData,
        // color:
        //  kTextLowBlackColor
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.white, width: 2),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.white, width: 2),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.white, width: 2),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFFF65054), width: 2),
      ),
      focusedErrorBorder: const OutlineInputBorder(
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
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          final pendingEmail = authState.pendingEmail ?? '';
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: Colors.black,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height * 0.02),
                    Image.asset(
                      'assets/images/forgetPassword.png',
                      height: size.height * 0.26,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: size.height * 0.04),
                    const Text(
                      'إنشاء كلمة مرور جديدة',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'قم بإدخال كلمة المرور الجديدة',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: size.height * 0.02),
                    if (pendingEmail.isNotEmpty)
                      Text(
                        pendingEmail,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
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
                            validator: (input) =>
                                (input ?? '').length < 3
                                    ? 'كلمة المرور قصيرة جداً'
                                    : null,
                          ),
                          SizedBox(height: size.height * 0.02),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _hidePassword,
                            decoration: getInputDecoration(
                              'تأكيد كلمة المرور',
                              Icons.lock,
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
                        padding: const EdgeInsets.only(bottom: 12),
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
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00AEEF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: _submit,
                              child: const Text(
                                'حفظ',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
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
