import 'package:flutter/material.dart';
import 'package:mafqood/constants.dart';

class SettingsChangePasswordPage extends StatelessWidget {
  const SettingsChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'تغير كلمه المرور',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Old password
              const Text(
                'ادخل كلمه المرور القديمه',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              _buildTextField('كلمه المرور القديمه'),

              const SizedBox(height: 24),

              // New password
              const Text(
                'ادخل كلمه المرور الجديده',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              _buildTextField('كلمه المرور الجديده'),

              const SizedBox(height: 16),

              // Confirm password
              _buildTextField('تاكيد كلمه المرور'),

              const SizedBox(height: 16),

              // Forgot password?
              const Align(
                alignment: Alignment.center,
                child: Text(
                  'نسيت كلمه المرور؟',
                  style: TextStyle(
                    color: Color(0xFFFFA000), // Orange
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Login / Submit Button (labeled 'تسجيل الدخول' in screenshot)
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم تغيير كلمة المرور بنجاح'),
                        backgroundColor: Color(0xFF4CAF50),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B9FE6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'تسجيل الدخول', // From screenshot
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

  Widget _buildTextField(String hint) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black87),
      ),
      child: TextField(
        obscureText: true,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black54),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: const Icon(Icons.remove_red_eye_outlined,
              color: Color(0xFF2B9FE6)),
        ),
      ),
    );
  }
}
