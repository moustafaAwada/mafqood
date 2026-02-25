import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  bool _isOldPasswordObscured = true;
  bool _isNewPasswordObscured = true;
  final bool _isLoading = false;

  final TextEditingController _oldPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();

  @override
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9C000),
        elevation: 0,
        centerTitle: true,
        title: Text(
          // l10n.changePassword,
          'تغير كلمة المرور',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            _buildPasswordInput(
              label: 'oldPassword',
              hint: 'enterOldPassword',
              controller: _oldPassController,
              isObscured: _isOldPasswordObscured,
              onToggle: () {
                setState(
                  () => _isOldPasswordObscured = !_isOldPasswordObscured,
                );
              },
            ),

            const SizedBox(height: 25),

            _buildPasswordInput(
              label: 'newPassword',
              hint: 'enterNewPassword',
              controller: _newPassController,
              isObscured: _isNewPasswordObscured,
              onToggle: () {
                setState(
                  () => _isNewPasswordObscured = !_isNewPasswordObscured,
                );
              },
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () {
                        // _handlePasswordChange();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE67E22),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'saveChanges',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordInput({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isObscured,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isObscured,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: IconButton(
                icon: Icon(
                  isObscured
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: onToggle,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Future<void> _handlePasswordChange() async {
  //   if (_oldPassController.text.isEmpty || _newPassController.text.isEmpty) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('allFieldsRequired')));
  //     return;
  //   }

  //   setState(() => _isLoading = true);

  //   try {
  //     final profileProvider = context.read<ProfileProvider>();
  //     // final success = await profileProvider.changePassword(
  //     //   currentPassword: _oldPassController.text,
  //     //   newPassword: _newPassController.text,
  //     // );

  //     if (!mounted) return;

  //     if (success) {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text(l10n.passwordChangedSuccess)));
  //       Navigator.pop(context);
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             profileProvider.errorState?.message ??
  //                 l10n.passwordChangeFailed(''),
  //           ),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(l10n.passwordChangeFailed(e.toString()))),
  //     );
  //   } finally {
  //     if (mounted) setState(() => _isLoading = false);
  //   }
  // }
}
