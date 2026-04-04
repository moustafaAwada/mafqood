import 'package:flutter/material.dart';
import 'package:mafqood/features/account/presentation/pages/donation_page.dart';
import 'package:mafqood/features/account/presentation/pages/edit_profile_page.dart';
import 'package:mafqood/features/account/presentation/pages/family_care_page.dart';
import 'package:mafqood/features/account/presentation/pages/my_posts_page.dart';
import 'package:mafqood/features/account/presentation/pages/saved_posts_page.dart';
import 'package:mafqood/features/account/presentation/pages/settings_page.dart';
import 'package:mafqood/features/account/presentation/widgets/account_item.dart';
import 'package:mafqood/features/account/presentation/widgets/logout_button.dart';
import 'package:mafqood/features/account/presentation/widgets/profile_card.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'الحساب',
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: colorScheme.onPrimary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── User profile card ──
            const ProfileCard(),

            const SizedBox(height: 24),

            // ── Menu list ──
            AccountItem(
              icon: Icons.person_outline,
              label: 'تعديل الحساب',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              ),
            ),
            AccountItem(
              icon: Icons.bookmark_outline,
              label: 'المنشورات المحفوظة',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SavedPostsPage()),
              ),
            ),
            AccountItem(
              icon: Icons.list_alt_outlined,
              label: 'منشوراتي',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyPostsPage()),
              ),
            ),
            AccountItem(
              icon: Icons.family_restroom_outlined,
              label: 'العناية بالعائلة',
              badge: 'جديد',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FamilyCarePage()),
              ),
            ),
            AccountItem(
              icon: Icons.settings_outlined,
              label: 'الإعدادات',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              ),
            ),
            AccountItem(
              icon: Icons.volunteer_activism_outlined,
              label: 'التبرع',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DonationPage()),
              ),
            ),

            const SizedBox(height: 32),

            // ── Logout ──
            LogoutButton(onPressed: () {}),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
