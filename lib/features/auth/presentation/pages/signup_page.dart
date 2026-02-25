import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mafqood/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mafqood/features/auth/presentation/pages/confirmation_email_page.dart';

class SignUpPage extends StatefulWidget {
  static const routeName = '/signup';
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  bool _hidePassword = true;
  bool _isLoading = false;

  final Color primaryColor = const Color(0xFFF9C000);

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      final authCubit = context.read<AuthCubit>();

      final success = await authCubit.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phoneNumber: _phoneController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        // CommonFunctions.showSuccessToast(
        // AppLocalizations.of(context)!.signupSuccessful,
        // );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ConfirmationEmailPage(),
          ),
        );
      } else {
        // CommonFunctions.showErrorDialog(
        //   authCubit.state.error ?? AppLocalizations.of(context)!.couldNotRegister,
        //   context,
        // );
      }
    } catch (error) {
      // CommonFunctions.showErrorDialog(
      //   AppLocalizations.of(context)!.couldNotRegister,
      //   context,
      // );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon, color: primaryColor),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
      // Light border for clean look
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      // backgroundColor: kBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ClipPath(
              clipper: _HeaderClipper(),
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withOpacity(0.8)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'signUpTitle',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 10,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration(
                        'الاسم كاملاً',
                        Icons.person_outline,
                      ),
                      validator: (v) => v!.isEmpty ? 'firstNameRequired' : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _phoneController,
                      decoration: _inputDecoration(
                        'phone',
                        Icons.phone_android_outlined,
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (v) => v!.isEmpty ? 'phoneRequired' : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _emailController,
                      decoration: _inputDecoration(
                        'email',
                        Icons.email_outlined,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>
                          !RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(v!)
                          ? 'emailInvalid'
                          : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _hidePassword,
                      decoration:
                          _inputDecoration(
                            'password',
                            Icons.lock_outline,
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _hidePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(
                                () => _hidePassword = !_hidePassword,
                              ),
                            ),
                          ),
                      validator: (v) =>
                          v!.length < 6 ? 'passwordTooShortSignup' : null,
                    ),
                    const SizedBox(height: 30),
                    _isLoading
                        ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(primaryColor),
                          )
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                backgroundColor: primaryColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'signUp',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors
                                      .black87, // Darker text for better contrast on yellow
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('alreadyHaveAccount'),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'signIn',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
