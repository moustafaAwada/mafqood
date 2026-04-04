import 'package:flutter/material.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          elevation: 0,
          centerTitle: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_forward_ios, color: colorScheme.onPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: colorScheme.onPrimary.withOpacity(0.2),
                    child: Text(
                      memberName.substring(0, 1),
                      style: TextStyle(color: colorScheme.onPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
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
                        border: Border.all(color: colorScheme.primary, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  memberName,
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(title: 'التحكم والمتابعة'),
              const SizedBox(height: 12),
              _DetailsContainer(
                children: [
                  _DetailsItem(
                    title: 'الموقع الحالي المباشر',
                    icon: Icons.location_on_outlined,
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
                  ),
                  _divider(theme),
                  _DetailsItem(
                    title: 'سجل تحركات العضو',
                    icon: Icons.route_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MemberMovementsPage(memberName: memberName),
                        ),
                      );
                    },
                  ),
                  _divider(theme),
                  _DetailsItem(
                    title: 'تنبيهات الطوارئ',
                    icon: Icons.emergency_outlined,
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
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              _SectionHeader(title: 'إعدادات العضو'),
              const SizedBox(height: 12),
              _DetailsContainer(
                children: [
                  _DetailsItem(
                    title: 'تخصيص المناطق الآمنة',
                    icon: Icons.shield_outlined,
                    onTap: () {
                      // TODO: Safe zones feature
                    },
                  ),
                  _divider(theme),
                  _DetailsItem(
                    title: 'إيقاف المتابعة المؤقت',
                    icon: Icons.pause_circle_outline,
                    onTap: () {
                      // TODO: Pause tracking feature
                    },
                  ),
                  _divider(theme),
                  _DetailsItem(
                    title: 'إزالة العضو من العائلة',
                    icon: Icons.person_remove_outlined,
                    isDanger: true,
                    onTap: () {
                      // TODO: Remove member feature
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider(ThemeData theme) => Divider(
        height: 1,
        indent: 52,
        color: theme.dividerColor.withOpacity(0.05),
      );
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _DetailsContainer extends StatelessWidget {
  final List<Widget> children;
  const _DetailsContainer({required this.children});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _DetailsItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDanger;

  const _DetailsItem({
    required this.title,
    required this.icon,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final itemColor = isDanger ? colorScheme.error : colorScheme.primary;
    
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: itemColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: itemColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isDanger ? colorScheme.error : colorScheme.onSurface,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: colorScheme.onSurface.withOpacity(0.2),
      ),
    );
  }
}
