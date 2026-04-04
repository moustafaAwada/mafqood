import 'package:flutter/material.dart';
import 'package:mafqood/constants.dart';

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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF2B9FE6), // Blue from screenshot
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'حالات الطوارئ',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            // A hidden debug button to toggle state
            IconButton(
              icon: const Icon(Icons.swap_horiz, color: Colors.white54),
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
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 40),

                // ── Member Card ──
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isEmergency ? Colors.red : Colors.green,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
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
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: AssetImage(widget.memberImage),
                            onBackgroundImageError: (_, __) {},
                            child: widget.memberImage.isEmpty
                                ? const Icon(Icons.person, color: Colors.white)
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
                                  color: Colors.white,
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
                            const SizedBox(height: 4),
                            const Text(
                              'mostafaalfy@gmail.com', // Static for prototype
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
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
    return Image.asset(
      'assets/images/everything _is_good.gif', // Safe GIF
      width: 200,
      height: 200,
      fit: BoxFit.contain,
    );
  }

  Widget _buildEmergencyIcon() {
    return Image.asset(
      'assets/images/there\'s_something_goingon.gif', // Emergency GIF
      width: 200,
      height: 200,
      fit: BoxFit.contain,
    );
  }
}
