import 'package:flutter/material.dart';
import 'package:mafqood/features/account/presentation/pages/subscription_checkout_page.dart';

class FamilyCareSubscriptionPage extends StatefulWidget {
  const FamilyCareSubscriptionPage({super.key});

  @override
  State<FamilyCareSubscriptionPage> createState() =>
      _FamilyCareSubscriptionPageState();
}

class _FamilyCareSubscriptionPageState
    extends State<FamilyCareSubscriptionPage> {
  int _selectedPlan = 0; // 0 = monthly, 1 = yearly

  void _navigateToCheckout() {
    final isMonthly = _selectedPlan == 0;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubscriptionCheckoutPage(
          planName: isMonthly ? 'شهري' : 'سنوي',
          amount: isMonthly ? '30' : '300',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // ── Close button ──
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // ── Crown icon ──
                      Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFF3E0),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.workspace_premium,
                          size: 60,
                          color: Color(0xFFFFA000),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Title ──
                      const Text(
                        'العناية بالعائلة',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ── Subtitle ──
                      const Text(
                        'احصل علي حمايه كامله لعائلتك وميزات حصريه',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Features list ──
                      const _FeatureItem(
                        icon: Icons.groups_outlined,
                        text: 'اضافه 3 ممن افراد العائله',
                      ),
                      const SizedBox(height: 14),
                      const _FeatureItem(
                        icon: Icons.location_on_outlined,
                        text: 'متابعه للموقع الجغرافي لافراد العائله',
                      ),
                      const SizedBox(height: 14),
                      const _FeatureItem(
                        icon: Icons.history,
                        text: 'سجل تحركات لمده 7 يوم',
                      ),
                      const SizedBox(height: 14),
                      const _FeatureItem(
                        icon: Icons.notifications_outlined,
                        text: 'تنبيهات المناطق الآمنه',
                      ),

                      const SizedBox(height: 32),

                      // ── Pricing cards ──
                      Row(
                        children: [
                          // Monthly plan
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedPlan = 0),
                              child: _PricingCard(
                                title: 'شهري',
                                price: '30',
                                isBestValue: false,
                                isSelected: _selectedPlan == 0,
                                onSubscribe: () {
                                  setState(() => _selectedPlan = 0);
                                  _navigateToCheckout();
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Yearly plan
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedPlan = 1),
                              child: _PricingCard(
                                title: 'سنوي',
                                price: '300',
                                isBestValue: true,
                                isSelected: _selectedPlan == 1,
                                onSubscribe: () {
                                  setState(() => _selectedPlan = 1);
                                  _navigateToCheckout();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                    ],
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

// ── Feature list item ──
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
        const SizedBox(width: 12),
        Icon(icon, color: const Color(0xFFFFA000), size: 28),
      ],
    );
  }
}

// ── Pricing card ──
class _PricingCard extends StatelessWidget {
  final String title;
  final String price;
  final bool isBestValue;
  final bool isSelected;
  final VoidCallback onSubscribe;

  const _PricingCard({
    required this.title,
    required this.price,
    required this.isBestValue,
    required this.isSelected,
    required this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFF8E1) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? const Color(0xFFFFA000)
              : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Best value badge
          if (isBestValue)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'الاكثر توفيرا',
                style: TextStyle(
                  color: Color(0xFFFFA000),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (!isBestValue) const SizedBox(height: 20),

          const SizedBox(height: 8),

          // Plan title
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.black87 : Colors.black54,
            ),
          ),

          const SizedBox(height: 6),

          // Price
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'ج.م',
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected ? Colors.black87 : Colors.black54,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                price,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.black87 : Colors.black54,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Subscribe button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSubscribe,
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected
                    ? const Color(0xFFFFA000)
                    : Colors.white,
                foregroundColor: isSelected
                    ? Colors.white
                    : Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: isSelected
                      ? BorderSide.none
                      : BorderSide(color: Colors.grey.shade400),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: const Text(
                'اشتراك',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
