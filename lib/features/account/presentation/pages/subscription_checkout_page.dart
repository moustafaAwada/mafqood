import 'package:flutter/material.dart';
import 'package:mafqood/features/account/presentation/pages/active_family_care_page.dart';

class SubscriptionCheckoutPage extends StatefulWidget {
  final String planName;
  final String amount;

  const SubscriptionCheckoutPage({
    super.key,
    required this.planName,
    required this.amount,
  });

  @override
  State<SubscriptionCheckoutPage> createState() =>
      _SubscriptionCheckoutPageState();
}

class _SubscriptionCheckoutPageState extends State<SubscriptionCheckoutPage> {
  int _selectedPayment = 0; // 0=credit, 1=vodafone, 2=fawry, 3=instapay
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _walletNumberController = TextEditingController();
  final _phoneController = TextEditingController();

  final _paymentMethods = [
    _PaymentMethod(icon: Icons.credit_card, label: 'بطاقة ائتمان'),
    _PaymentMethod(icon: Icons.account_balance_wallet_outlined, label: 'محفظة إلكترونية'),
    _PaymentMethod(icon: Icons.qr_code_scanner, label: 'فوري / أمان'),
    _PaymentMethod(icon: Icons.account_balance_outlined, label: 'انستاباي'),
  ];

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _walletNumberController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم إتمام الاشتراك بنجاح', style: TextStyle(fontFamily: 'Cairo')),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const ActiveFamilyCarePage(),
      ),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'الدفع والاشتراك',
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_forward_ios, color: colorScheme.onPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Summary Card ──
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'خطة الاشتراك:',
                                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 13),
                              ),
                              Text(
                                '${widget.planName} - العناية بالعائلة',
                                style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface, fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'إجمالي المبلغ:',
                                style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface, fontSize: 15),
                              ),
                              Text(
                                '${widget.amount} ج.م',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Payment methods ──
                    Text(
                      'اختر وسيلة الدفع المناسبة',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _paymentMethods.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final method = _paymentMethods[index];
                          final isSelected = _selectedPayment == index;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedPayment = index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 110,
                              decoration: BoxDecoration(
                                color: isSelected ? colorScheme.primary.withOpacity(0.05) : colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? colorScheme.primary : theme.dividerColor.withOpacity(0.1),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    method.icon,
                                    color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.4),
                                    size: 28,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    method.label,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Payment Form ──
                    _buildPaymentForm(colorScheme, theme),
                  ],
                ),
              ),
            ),

            // ── Pay button ──
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'تأكيد الدفع والاستمتاع بالخدمة',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentForm(ColorScheme colorScheme, ThemeData theme) {
    if (_selectedPayment == 0 || _selectedPayment == 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputLabel(colorScheme, 'رقم البطاقة'),
          _buildTextField(
            controller: _cardNumberController,
            hint: 'xxxx xxxx xxxx xxxx',
            icon: Icons.credit_card,
            colorScheme: colorScheme,
            theme: theme,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputLabel(colorScheme, 'تاريخ الانتهاء'),
                    _buildTextField(
                      controller: _expiryController,
                      hint: 'MM/YY',
                      colorScheme: colorScheme,
                      theme: theme,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputLabel(colorScheme, 'CVV'),
                    _buildTextField(
                      controller: _cvvController,
                      hint: '***',
                      isObscure: true,
                      colorScheme: colorScheme,
                      theme: theme,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputLabel(colorScheme, 'رقم الموبايل المسجل'),
          _buildTextField(
            controller: _phoneController,
            hint: '01xxxxxxxxx',
            icon: Icons.phone_android,
            colorScheme: colorScheme,
            theme: theme,
          ),
          const SizedBox(height: 12),
          Text(
            'سيتم إرسال رمز تأكيد لمرة واحدة على هذا الرقم لإتمام العملية.',
            style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.4)),
          ),
        ],
      );
    }
  }

  Widget _buildInputLabel(ColorScheme colorScheme, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 4, bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required ColorScheme colorScheme,
    required ThemeData theme,
    IconData? icon,
    bool isObscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        textDirection: TextDirection.ltr,
        textAlign: icon != null ? TextAlign.right : TextAlign.center,
        style: TextStyle(color: colorScheme.onSurface, fontSize: 15, letterSpacing: 1.5),
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: colorScheme.primary, size: 20) : null,
          hintText: hint,
          hintStyle: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.2),
            fontSize: 14,
            letterSpacing: 1.5,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

class _PaymentMethod {
  final IconData icon;
  final String label;
  _PaymentMethod({required this.icon, required this.label});
}
