import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mafqood/features/auth/presentation/cubit/auth_cubit.dart';
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
  bool _isLoading = false;

  InputDecoration getInputDecoration(String hint, IconData iconData) {
    return InputDecoration(
      filled: true,
      // fillColor: kBackgroundColor,
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black54, fontSize: 14),
      prefixIcon: Icon(
        iconData,
        // color: kTextLowBlackColor
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authCubit = context.read<AuthCubit>();
      final success = await authCubit.forgetPassword(
        email: _emailController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        // CommonFunctions.showSuccessToast(
        //   AppLocalizations.of(context)!.emailSentSuccess,
        // );
        Navigator.pushReplacementNamed(context, ResetPasswordPage.routeName);
      } else {
        // CommonFunctions.showErrorDialog(
        //   authCubit.state.error ?? AppLocalizations.of(context)!.authFailed,
        //   context,
        // );
      }
    } catch (e) {
      // CommonFunctions.showErrorDialog(e.toString(), context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('forgotPasswordTitle'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.05),
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                // child: Image.asset(
                //   'assets/images/WhatsApp Image 2026-01-08 at 5.06.25 PM.jpeg',
                //   height: size.height * 0.30,
                //   width: double.infinity,
                //   fit: BoxFit.cover,
                //   alignment: Alignment.center,
                // ),
              ),

              SizedBox(height: size.height * 0.05),
              Text(
                'enterEmailForReset',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              SizedBox(height: size.height * 0.04),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _emailController,
                  decoration: getInputDecoration('email', Icons.email_outlined),
                  validator: (input) => !RegExp(r".+@.+\..+").hasMatch(input!)
                      ? 'invalidEmail'
                      : null,
                ),
              ),
              SizedBox(height: size.height * 0.04),
              SizedBox(
                width: double.infinity,
                height: size.height * 0.065,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _submit,
                        child: Text(
                          'sendCode',
                          style: const TextStyle(
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
  }
}
