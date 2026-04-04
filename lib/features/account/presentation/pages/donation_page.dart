import 'package:flutter/material.dart';
import 'package:mafqood/constants.dart';

class DonationPage extends StatefulWidget {
  const DonationPage({super.key});

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  int _selectedIndex = -1;

  final List<String> _amounts = [
    '10 ج.م',
    '50 ج.م',
    '100 ج.م',
    '200 ج.م',
    '500 ج.م',
    'مبلغ اخر',
  ];

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
            'التبرع',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              // ── Top Icon ──
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F1FC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.volunteer_activism,
                  size: 50,
                  color: kPrimaryColor,
                ),
              ),

              const SizedBox(height: 16),

              // ── Titles ──
              const Text(
                'ساهم في اعاده المفقودين',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'تبرعك يساعدنا في تطوير المنصه والوصول لاكبر عدد من الناس',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 24),

              // ── Grid of Amounts ──
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _amounts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.2,
                ),
                itemBuilder: (context, index) {
                  final isSelected = _selectedIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIndex = index),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? kPrimaryColor
                              : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          if (!isSelected)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                        ],
                      ),
                      child: Text(
                        _amounts[index],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? kPrimaryColor : Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // ── Submit Button ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('شكرًا لتبرعك!'),
                        backgroundColor: Color(0xFF4CAF50),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'إتمام التبرع',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Impact Section ──
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'اثر تبرعك',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const _ImpactItem(
                amount: '10 ج.م',
                desc: 'نساعد في نشر بلاغ واحد',
                icon: Icons.search,
              ),
              const _ImpactItem(
                amount: '50 ج.م',
                desc: 'ترسل تنبيهات ل 1000 شخص',
                icon: Icons.notifications_none,
              ),
              const _ImpactItem(
                amount: '100 ج.م',
                desc: 'تفعل خاصيه البحث بالذكاء الاصطناعي',
                icon: Icons.psychology,
              ),
              const _ImpactItem(
                amount: '500 ج.م',
                desc: 'ندعم عائله كامله لمده شهر',
                icon: Icons.groups_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImpactItem extends StatelessWidget {
  final String amount;
  final String desc;
  final IconData icon;

  const _ImpactItem({
    required this.amount,
    required this.desc,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1FC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: kPrimaryColor,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
