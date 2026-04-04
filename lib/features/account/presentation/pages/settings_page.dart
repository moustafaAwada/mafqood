import 'package:flutter/material.dart';
import 'package:mafqood/constants.dart';
import 'package:mafqood/features/account/presentation/pages/settings_change_password_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;

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
            'الاعدادات',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
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
                // Change Password
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsChangePasswordPage(),
                      ),
                    );
                  },
                  title: const Text(
                    'تغير كلمه المرور',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F1FC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('**|',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  leading: const Icon(Icons.arrow_back_ios, size: 16),
                ),
                const Divider(height: 1),

                // Language
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  onTap: () {},
                  title: const Text(
                    'اللغه',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F1FC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.translate, color: Colors.black87),
                  ),
                  leading: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: kPrimaryColor),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          color: Colors.transparent,
                          child: const Text('AR',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          color: Colors.transparent,
                          child: const Text('EN',
                              style: TextStyle(color: Colors.black54)),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),

                // Dark Mode
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: const Text(
                    'Dark mode',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F1FC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.dark_mode_outlined,
                        color: Colors.black87),
                  ),
                  leading: IgnorePointer(
                    child: Switch(
                      value: _isDarkMode,
                      onChanged: (val) {
                        setState(() {
                          _isDarkMode = val;
                        });
                      },
                      activeColor: Colors.black,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _isDarkMode = !_isDarkMode;
                    });
                  },
                ),
                const Divider(height: 1),

                // Notifications
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: const Text(
                    'الاشعارات',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F1FC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.notifications_none,
                        color: Colors.black87),
                  ),
                  leading: IgnorePointer(
                    child: Switch(
                      value: _notificationsEnabled,
                      onChanged: (val) {
                        setState(() {
                          _notificationsEnabled = val;
                        });
                      },
                      activeColor: Colors.black,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _notificationsEnabled = !_notificationsEnabled;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
