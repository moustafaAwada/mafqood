import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mafqood/core/database/auth_storage.dart';
import 'package:mafqood/core/services/service_locator.dart';
import 'package:mafqood/features/account/presentation/pages/edit_profile_page.dart';

class ProfileCard extends StatefulWidget {
  const ProfileCard({super.key});

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  String _name = '';
  String _email = '';
  String? _profilePictureUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await getIt<AuthStorage>().getUserData();
    if (mounted) {
      setState(() {
        _name = userData?['name'] ?? '${userData?['firstName'] ?? ''} ${userData?['lastName'] ?? ''}'.trim();
        _email = userData?['email'] ?? '';
        _profilePictureUrl = userData?['profilePictureUrl'];
        _isLoading = false;
      });
    }
  }

  String get _initials {
    if (_name.isEmpty) return '?';
    final parts = _name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EditProfilePage()),
        ).then((_) => _loadUserData()); // Refresh data when returning
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: colorScheme.primaryContainer,
              backgroundImage: _profilePictureUrl != null && _profilePictureUrl!.isNotEmpty
                  ? CachedNetworkImageProvider(_profilePictureUrl!)
                  : null,
              child: _profilePictureUrl == null || _profilePictureUrl!.isEmpty
                  ? Text(
                      _initials,
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isLoading ? 'جاري التحميل...' : (_name.isNotEmpty ? _name : 'مستخدم'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _email.isNotEmpty ? _email : '',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}
