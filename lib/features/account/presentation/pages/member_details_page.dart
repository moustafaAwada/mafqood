import 'package:flutter/material.dart';
import 'package:mafqood/constants.dart';
import 'package:mafqood/features/account/presentation/pages/member_location_page.dart';
import 'package:mafqood/features/account/presentation/pages/member_movements_page.dart';
import 'package:mafqood/features/account/presentation/pages/member_emergency_page.dart';

class MemberDetailsPage extends StatelessWidget {
  final String memberName;
  final String memberImage;

  const MemberDetailsPage({
    super.key,
    required this.memberName,
    required this.memberImage,
  });

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
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Row(
                  children: [
                    Text(
                      memberName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: AssetImage(memberImage),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: kPrimaryColor,
                                width: 1.5,
                              ),
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MemberLocationPage(
                          memberName: memberName,
                          memberImage: memberImage,
                        ),
                      ),
                    );
                  },
                  title: const Text(
                    'الموقع الحالي',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F1FC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.location_on_outlined,
                        color: Colors.black87),
                  ),
                  leading: const Icon(Icons.arrow_back_ios, size: 16),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            MemberMovementsPage(memberName: memberName),
                      ),
                    );
                  },
                  title: const Text(
                    'اخر التحركات',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F1FC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        const Icon(Icons.swap_horiz, color: Colors.black87),
                  ),
                  leading: const Icon(Icons.arrow_back_ios, size: 16),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MemberEmergencyPage(
                          memberName: memberName,
                          memberImage: memberImage,
                        ),
                      ),
                    );
                  },
                  title: const Text(
                    'حالات الطوارئ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F1FC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.emergency, color: Colors.black87),
                  ),
                  leading: const Icon(Icons.arrow_back_ios, size: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
