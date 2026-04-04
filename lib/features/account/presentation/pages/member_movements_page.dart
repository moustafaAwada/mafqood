import 'package:flutter/material.dart';
import 'package:mafqood/constants.dart';

class MemberMovementsPage extends StatelessWidget {
  final String memberName;

  const MemberMovementsPage({
    super.key,
    required this.memberName,
  });

  final List<Map<String, String>> _movements = const [
    {'loc': 'قنا-قفط -البراهمه', 'time': 'منذ 1 دقيقه'},
    {'loc': 'قنا -بندر قنا -المحطه', 'time': 'منذ 1 ساعه'},
    {'loc': 'قنا-بندر قنا -حوض عشره', 'time': 'منذ 2 ساعه'},
    {'loc': 'قنا-بندر قنا -الشؤؤن', 'time': 'منذ 3 ساعه'},
    {'loc': 'قنا-بندر قنا -عمر افندي', 'time': 'منذ 4 ساعه'},
    {'loc': 'قنا-بندر قنا -التجنيد', 'time': 'منذ 5 ساعه'},
    {'loc': 'قنا-بندر قنا -المعبر', 'time': 'منذ 6 ساعه'},
    {'loc': 'قنا-قفط -البراهمه', 'time': 'منذ 7 ساعه'},
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
            'اخر التحركات',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _movements.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final mov = _movements[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F1FC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.location_on_outlined,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      mov['loc']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Text(
                    mov['time']!,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
