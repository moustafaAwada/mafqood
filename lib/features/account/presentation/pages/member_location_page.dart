import 'package:flutter/material.dart';
import 'package:mafqood/constants.dart';

class MemberLocationPage extends StatelessWidget {
  final String memberName;
  final String memberImage;

  const MemberLocationPage({
    super.key,
    required this.memberName,
    required this.memberImage,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFD3D8DE), // Mock map background color
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: const Text(
            'الموقع الجغرافي',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(left: 16),
              child: Icon(
                Icons.workspace_premium,
                color: Color(0xFFFFA000),
                size: 28,
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            // ── Background Mock Map ──
            Positioned.fill(
              child: CustomPaint(
                painter: _MockMapPainter(),
              ),
            ),

            // ── User Avatar on Map ──
            Positioned(
              top: MediaQuery.of(context).size.height * 0.25,
              right: MediaQuery.of(context).size.width * 0.35,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: kPrimaryColor,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(memberImage),
                      backgroundColor: Colors.grey.shade300,
                      onBackgroundImageError: (_, __) {},
                      child: memberImage.isEmpty
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 16,
                      height: 16,
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
            ),

            // ── Bottom Card ──
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top row: Info and Refresh
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'اخر تحديث : منذ دقيقتين',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.refresh,
                            color: Color(0xFF2B9FE6),
                            size: 20,
                          ),
                          label: const Text(
                            'تحديث',
                            style: TextStyle(
                              color: Color(0xFF2B9FE6),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2B9FE6),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.explore, size: 24),
                        label: const Text(
                          'الحصول على الاتجاهات',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A simple painter to draw some lines simulating a map background
class _MockMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.square;

    // Draw some mock roads
    canvas.drawLine(const Offset(-100, 100), Offset(size.width + 100, size.height * 0.4), paint);
    canvas.drawLine(Offset(size.width * 0.2, -100), Offset(size.width * 0.8, size.height + 100), paint);
    paint.strokeWidth = 14;
    canvas.drawLine(Offset(size.width * 0.5, size.height * 0.3), Offset(size.width * 0.9, size.height + 100), paint);
    
    // Add a few placeholder location pins
    final pinPaint = Paint()..color = Colors.blueGrey;
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.5), 8, pinPaint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.2), 8, pinPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
