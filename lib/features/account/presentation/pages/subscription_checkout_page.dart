import 'package:flutter/material.dart';
import 'package:mafqood/constants.dart';
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

  final _paymentMethods = const [
    _PaymentMethod(icon: Icons.credit_card, label: 'بطاقة ائتمان'),
    _PaymentMethod(icon: Icons.phone_android, label: 'فودافون كاش'),
    _PaymentMethod(icon: Icons.language, label: 'فوري'),
    _PaymentMethod(icon: Icons.account_balance, label: 'انستاباي'),
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
      const SnackBar(
        content: Text('تم إتمام الاشتراك بنجاح'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
    
    // Pop the checkout, subscription info, and intro pages, 
    // then push the active family dashboard.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const ActiveFamilyCarePage(),
      ),
      (route) => route.isFirst, // Keep the root (which includes AccountPage/HomePage)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'إتمام الاشتراك',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Subscription amount ──
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'مبلغ الاشتراك',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            '${widget.amount} ج.م',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Payment method title ──
                    const Text(
                      'اختر طريقة الدفع',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Payment options ──
                    ...List.generate(_paymentMethods.length, (index) {
                      final method = _paymentMethods[index];
                      final isSelected = _selectedPayment == index;

                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedPayment = index),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? kPrimaryColor
                                  : Colors.grey.shade200,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                method.icon,
                                color: isSelected
                                    ? kPrimaryColor
                                    : Colors.black54,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                method.label,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 20),

                    // ── Dynamic form fields based on selection ──
                    _buildFormForPayment(),
                  ],
                ),
              ),
            ),

            // ── Submit button ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'إتمام الاشتراك',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  /// Builds different form fields based on the selected payment method.
  Widget _buildFormForPayment() {
    switch (_selectedPayment) {
      case 0: // بطاقة ائتمان
        return _buildCardFields(title: 'بيانات البطاقه');

      case 1: // فودافون كاش
        return _buildWalletFields();

      case 2: // فوري
        return _buildCardFields(title: 'بيانات البطاقه');

      case 3: // انستاباي
        return _buildInstaPayFields();

      default:
        return const SizedBox.shrink();
    }
  }

  /// Card number + expiry + CVV
  Widget _buildCardFields({required String title}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 6),
        const Text(
          'رقم البطاقه',
          style: TextStyle(color: Colors.black54, fontSize: 13),
        ),
        const SizedBox(height: 8),
        _inputField(
          controller: _cardNumberController,
          hint: '1254 2345 3551 7586',
          keyboardType: TextInputType.number,
          textDirection: TextDirection.ltr,
          prefixIcon: Icons.credit_card,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'تاريخ الانتهاء',
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  _inputField(
                    controller: _expiryController,
                    hint: 'MM/YY',
                    keyboardType: TextInputType.datetime,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'CVV',
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  _inputField(
                    controller: _cvvController,
                    hint: '123',
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                    obscure: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Vodafone Cash — wallet number
  Widget _buildWalletFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'بيانات المحفظه',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 6),
        const Text(
          'رقم المحفظه',
          style: TextStyle(color: Colors.black54, fontSize: 13),
        ),
        const SizedBox(height: 8),
        _inputField(
          controller: _walletNumberController,
          hint: '01095914790',
          keyboardType: TextInputType.phone,
          textDirection: TextDirection.ltr,
          prefixIcon: Icons.phone_android,
        ),
      ],
    );
  }

  /// InstaPay — card fields + OR + phone
  Widget _buildInstaPayFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'بيانات الحساب',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 6),
        const Text(
          'رقم البطاقه',
          style: TextStyle(color: Colors.black54, fontSize: 13),
        ),
        const SizedBox(height: 8),
        _inputField(
          controller: _cardNumberController,
          hint: '1254 2345 3551 7586',
          keyboardType: TextInputType.number,
          textDirection: TextDirection.ltr,
          prefixIcon: Icons.credit_card,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'تاريخ الانتهاء',
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  _inputField(
                    controller: _expiryController,
                    hint: 'MM/YY',
                    keyboardType: TextInputType.datetime,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'CVV',
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  _inputField(
                    controller: _cvvController,
                    hint: '123',
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                    obscure: true,
                  ),
                ],
              ),
            ),
          ],
        ),

        // OR separator
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Text(
              'OR',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
        ),

        const Text(
          'رقم الهاتف الخاص بالحساب',
          style: TextStyle(color: Colors.black54, fontSize: 13),
        ),
        const SizedBox(height: 8),
        _inputField(
          controller: _phoneController,
          hint: '01095914790',
          keyboardType: TextInputType.phone,
          textDirection: TextDirection.ltr,
          prefixIcon: Icons.phone_android,
        ),
      ],
    );
  }

  /// Reusable input field
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    TextDirection textDirection = TextDirection.rtl,
    TextAlign textAlign = TextAlign.start,
    IconData? prefixIcon,
    bool obscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textDirection: textDirection,
        textAlign: textAlign,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.black38,
            fontSize: 14,
            letterSpacing: 1.2,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: Colors.black38)
              : null,
        ),
      ),
    );
  }
}

class _PaymentMethod {
  final IconData icon;
  final String label;

  const _PaymentMethod({required this.icon, required this.label});
}
