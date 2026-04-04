import 'package:flutter/material.dart';

class MemberMovementsPage extends StatelessWidget {
  final String memberName;

  const MemberMovementsPage({
    super.key,
    required this.memberName,
  });

  final List<Map<String, String>> _movements = const [
    {'loc': 'قنا - قفط - البراهمة', 'time': '12:45 م', 'date': 'اليوم'},
    {'loc': 'قنا - بندر قنا - المحطة', 'time': '11:20 ص', 'date': 'اليوم'},
    {'loc': 'قنا - بندر قنا - حوض عشرة', 'time': '09:15 ص', 'date': 'اليوم'},
    {'loc': 'قنا - بندر قنا - الشؤون', 'time': '08:00 ص', 'date': 'اليوم'},
    {'loc': 'قنا - بندر قنا - عمر أفندي', 'time': '11:30 م', 'date': 'أمس'},
    {'loc': 'قنا - بندر قنا - التجنيد', 'time': '10:00 م', 'date': 'أمس'},
    {'loc': 'قنا - بندر قنا - المعبر', 'time': '08:45 م', 'date': 'أمس'},
  ];

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
          centerTitle: true,
          title: Text(
            'سجل التحركات',
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_forward_ios, color: colorScheme.onPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          itemCount: _movements.length,
          itemBuilder: (context, index) {
            final mov = _movements[index];
            final isFirst = index == 0;
            final isLast = index == _movements.length - 1;
            
            return IntrinsicHeight(
              child: Row(
                children: [
                  // ── Timeline indicator ──
                  SizedBox(
                    width: 40,
                    child: Column(
                      children: [
                        Container(
                          width: 2,
                          height: 12,
                          color: isFirst ? Colors.transparent : colorScheme.primary.withOpacity(0.2),
                        ),
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: isFirst ? colorScheme.primary : colorScheme.surface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isFirst ? colorScheme.primary : colorScheme.primary.withOpacity(0.5),
                              width: 3,
                            ),
                            boxShadow: isFirst ? [
                              BoxShadow(
                                color: colorScheme.primary.withOpacity(0.3),
                                blurRadius: 6,
                                spreadRadius: 2,
                              ),
                            ] : null,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            width: 2,
                            color: isLast ? Colors.transparent : colorScheme.primary.withOpacity(0.2),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // ── Content card ──
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isFirst 
                              ? colorScheme.primary.withOpacity(0.1) 
                              : theme.dividerColor.withOpacity(0.05),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.01),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  mov['date']!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary.withOpacity(0.7),
                                  ),
                                ),
                                Text(
                                  mov['time']!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colorScheme.onSurface.withOpacity(0.4),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              mov['loc']!,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            if (isFirst) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle, size: 12, color: Colors.green),
                                    SizedBox(width: 4),
                                    Text(
                                      'الموقع الحالي المستقر',
                                      style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
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
