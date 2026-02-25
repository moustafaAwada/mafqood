import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mafqood/features/auth/presentation/cubit/auth_cubit.dart';
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
  bool _isLoading = false;
  bool hidePassword = true;

  final Map<String, String> _authData = {'email': '', 'password': ''};

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _submit() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      final authCubit = context.read<AuthCubit>();
      final success = await authCubit.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        final user = authCubit.state.user;
        // Navigator.pushNamedAndRemoveUntil(
        //   context,
        //   MainScreen.routeName,
        //   (r) => false,
        // );
        // CommonFunctions.showSuccessToast('  اهلاً ${user.name} ');
      } else {
        // CommonFunctions.showErrorDialog(
        //   authCubit.state.error ?? "فشل تسجيل الدخول",
        //   context,
        // );
      }
    } catch (error) {
      if (!mounted) return;
      // CommonFunctions.showErrorDialog("حدث خطأ غير متوقع", context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Curved Background
                Container(
                  height: size.height * 0.35,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFF9C000), Color(0xFFF5B000)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.elliptical(500, 50),
                    ),
                  ),
                ),
                // Logo
                Positioned(
                  top: size.height * 0.1,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    // child: Image.asset(
                    //   'assets/images/edited-photo.png',
                    //   height: 80,
                    //   width: 80,
                    //   fit: BoxFit.contain,
                    // ),
                  ),
                ),
                // Title
                Positioned(
                  bottom: 30,
                  child: Text(
                    'login',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 4,
                          color: Colors.black12,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Form Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildModernInput(
                      controller: _emailController,
                      label: 'email',
                      icon: Icons.email_outlined,
                      validator: (input) =>
                          !RegExp(r".+@.+\..+").hasMatch(input!)
                          ? 'invalidEmail'
                          : null,
                      onSaved: (value) => _authData['email'] = value!,
                    ),
                    const SizedBox(height: 20),
                    _buildModernInput(
                      controller: _passwordController,
                      label: 'password',
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                      hidePassword: hidePassword,
                      onTogglePassword: () =>
                          setState(() => hidePassword = !hidePassword),
                      validator: (input) =>
                          input!.length < 3 ? 'passwordTooShort' : null,
                      onSaved: (value) => _authData['password'] = value!,
                    ),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          ForgotPasswordPage.routeName,
                        ),
                        child: Text(
                          'forgotPassword',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFF9C000),
                              ),
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF9C000),
                                elevation: 4,
                                shadowColor: const Color(
                                  0xFFF9C000,
                                ).withOpacity(0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              onPressed: _submit,
                              child: Text(
                                'login',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ),

                    const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'dontHaveAccount',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            SignUpPage.routeName,
                          ),
                          child: Text(
                            'signUp',
                            style: const TextStyle(
                              color: Color(0xFFF9C000),
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

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool hidePassword = false,
    VoidCallback? onTogglePassword,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && hidePassword,
        validator: validator,
        onSaved: onSaved,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: Icon(icon, color: const Color(0xFFF9C000)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    hidePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey.shade400,
                  ),
                  onPressed: onTogglePassword,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
