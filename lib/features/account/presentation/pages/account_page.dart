import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mafqood/features/account/presentation/cubit/account_cubit.dart';
import 'package:mafqood/features/account/presentation/cubit/account_state.dart';
import 'package:mafqood/features/account/presentation/pages/donation_page.dart';
import 'package:mafqood/features/account/presentation/pages/edit_profile_page.dart';
import 'package:mafqood/features/account/presentation/pages/family_care_page.dart';
import 'package:mafqood/features/account/presentation/pages/my_posts_page.dart';
import 'package:mafqood/features/account/presentation/pages/saved_posts_page.dart';
import 'package:mafqood/features/account/presentation/pages/settings_page.dart';
import 'package:mafqood/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mafqood/features/auth/presentation/pages/login_page.dart';
import 'package:mafqood/features/account/presentation/widgets/account_item.dart';
import 'package:mafqood/features/account/presentation/widgets/logout_button.dart';
import 'package:mafqood/features/account/presentation/widgets/profile_card.dart';
import 'package:mafqood/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:mafqood/core/services/service_locator.dart';
import 'package:mafqood/features/posts/data/services/post_interaction_hub_service.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  void initState() {
    super.initState();
    // Fetch fresh user profile from API when page opens
    context.read<AccountCubit>().fetchCurrentUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<AccountCubit, AccountState>(
      listener: (context, state) {
        if (state is UpdateProfileSuccess || state is AccountLoaded) {
          // Refresh ProfileCard when profile is updated
          // The ProfileCard will automatically reload from AuthStorage
        }
      },
      child: Scaffold(
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
            LogoutButton(
              onPressed: () async {
                // Disconnect SignalR hubs before logout
                await context.read<ChatCubit>().disconnectHub();
                await getIt<PostInteractionHubService>().disconnect();
                await context.read<AuthCubit>().logout();
                if (!context.mounted) return;
                Navigator.of(context).pushNamedAndRemoveUntil(
                  LoginPage.routeName,
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  );
  }
}
