import 'package:flutter/material.dart';

/// Logo widget for LaundryGO app matching Figma design.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final double? fontSize;
  final Color? textColor;

  const AppLogo({
    super.key,
    this.size = 90,
    this.showText = true,
    this.fontSize,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final double iconSize = size * 0.28;
    final double effectiveFontSize = fontSize ?? (size * 0.24);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 4 Quadrants Container
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer rounded container holding 4 quadrants
              ClipRRect(
                borderRadius: BorderRadius.circular(size * 0.24),
                child: SizedBox(
                  width: size,
                  height: size,
                  child: Column(
                    children: [
                      // Top Row (Top-Left & Top-Right)
                      Expanded(
                        child: Row(
                          children: [
                            // Top-Left: Sage green with washing machine
                            Expanded(
                              child: Container(
                                color: const Color(0xFF98A185),
                                child: Center(
                                  child: Icon(
                                    Icons.local_laundry_service_outlined,
                                    color: Colors.white,
                                    size: iconSize,
                                  ),
                                ),
                              ),
                            ),
                            // Top-Right: Coral orange with folded clothes / t-shirt
                            Expanded(
                              child: Container(
                                color: const Color(0xFFD68449),
                                child: Center(
                                  child: Icon(
                                    Icons.checkroom_rounded,
                                    color: Colors.white,
                                    size: iconSize,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Bottom Row (Bottom-Left & Bottom-Right)
                      Expanded(
                        child: Row(
                          children: [
                            // Bottom-Left: Cream with steaming iron
                            Expanded(
                              child: Container(
                                color: const Color(0xFFFAE2C1),
                                child: Center(
                                  child: Icon(
                                    Icons.iron_outlined,
                                    color: const Color(0xFFD68449),
                                    size: iconSize,
                                  ),
                                ),
                              ),
                            ),
                            // Bottom-Right: Teal with laundry basket/detergent
                            Expanded(
                              child: Container(
                                color: const Color(0xFF3BAEA3),
                                child: Center(
                                  child: Icon(
                                    Icons.cleaning_services_outlined,
                                    color: Colors.white,
                                    size: iconSize,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Sparkle star divider in center
              CustomPaint(
                size: Size(size * 0.38, size * 0.38),
                painter: _SparkleStarPainter(
                  color: const Color(0xFFAFCBE2), // Matches background sky blue
                ),
              ),
            ],
          ),
        ),

        if (showText) ...[
          SizedBox(height: size * 0.14),
          Text(
            'LOUNDRYGO',
            style: TextStyle(
              fontSize: effectiveFontSize,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: textColor ?? const Color(0xFF4A76A2),
            ),
          ),
        ],
      ],
    );
  }
}

/// Custom painter for the 4-pointed concave sparkle star in the center of the logo.
class _SparkleStarPainter extends CustomPainter {
  final Color color;

  const _SparkleStarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;

    path.moveTo(cx, 0);
    path.quadraticBezierTo(cx, cy, w, cy);
    path.quadraticBezierTo(cx, cy, cx, h);
    path.quadraticBezierTo(cx, cy, 0, cy);
    path.quadraticBezierTo(cx, cy, cx, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparkleStarPainter oldDelegate) =>
      oldDelegate.color != color;
}
