import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Color(0xFFF9C000),
        elevation: 0,
        centerTitle: true,
        title: Text(
          // l10n.changePassword,
          'تغير كلمة المرور',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),

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
              theme: theme,
              colorScheme: colorScheme,
            ),

            SizedBox(height: 25),

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
              theme: theme,
              colorScheme: colorScheme,
            ),

            SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () {
                        // _handlePasswordChange();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE67E22),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'saveChanges',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.scaffoldBackgroundColor,
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
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: colorScheme.onSurface.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isObscured,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: theme.dividerColor, fontSize: 14),
              prefixIcon: IconButton(
                icon: Icon(
                  isObscured
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: theme.dividerColor,
                  size: 20,
                ),
                onPressed: onToggle,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
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
