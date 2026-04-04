import 'package:flutter/material.dart';

class MemberEmergencyPage extends StatefulWidget {
  final String memberName;
  final String memberImage;

  const MemberEmergencyPage({
    super.key,
    required this.memberName,
    required this.memberImage,
  });

  @override
  State<MemberEmergencyPage> createState() => _MemberEmergencyPageState();
}

class _MemberEmergencyPageState extends State<MemberEmergencyPage> {
  // Toggle this state to view the two different designs for demo purposes
  bool _isEmergency = false;

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
          leading: IconButton(
            icon: Icon(
              Icons.arrow_forward_ios,
              color: theme.scaffoldBackgroundColor,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'حالات الطوارئ',
            style: TextStyle(
              color: theme.scaffoldBackgroundColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            // A hidden debug button to toggle state
            IconButton(
              icon: Icon(
                Icons.swap_horiz,
                color: theme.scaffoldBackgroundColor,
              ),
              onPressed: () {
                setState(() {
                  _isEmergency = !_isEmergency;
                });
              },
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),

                // ── Central Icon ──
                if (_isEmergency) _buildEmergencyIcon() else _buildSafeIcon(),

                const SizedBox(height: 32),

                // ── Status Text ──
                Text(
                  _isEmergency ? 'هناك شئ ما يحدث؟' : 'كل شئ علي ما يرام ....',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 40),

                // ── Member Card ──
                Container(
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isEmergency ? Colors.red : Colors.green,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.onSurface.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Avatar
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: theme.dividerColor,
                            backgroundImage: AssetImage(widget.memberImage),
                            onBackgroundImageError: (_, __) {},
                            child: widget.memberImage.isEmpty
                                ? Icon(
                                    Icons.person,
                                    color: theme.scaffoldBackgroundColor,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.scaffoldBackgroundColor,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.memberName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'mostafaalfy@gmail.com', // Static for prototype
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSafeIcon() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage(
            'assets/images/everything _is_good.gif', // Safe GIF
          ),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildEmergencyIcon() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage(
            'assets/images/there\'s_something_goingon.gif', // Emergency GIF
          ),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
