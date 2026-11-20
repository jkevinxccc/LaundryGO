import 'package:flutter/material.dart';
import '../app_logo.dart';

class TentangPage extends StatelessWidget {
  const TentangPage({super.key});

  static const Color kBg = Color(0xFFAFCBE2);
  static const Color kCard = Color(0xFFFDF4D2);
  static const Color kText = Color(0xFF111111);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // ===== Header =====
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 10, 16, 0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_rounded,
                                  color: kText, size: 24),
                              onPressed: () => Navigator.maybePop(context),
                            ),
                            const Text(
                              'Tentang',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: kText,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ===== Logo =====
                      const Center(
                        child: AppLogo(size: 90, fontSize: 18),
                      ),

                      const SizedBox(height: 24),

                      // ===== Deskripsi =====
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'LaundryGo merupakan aplikasi yang memudahkan pelanggan dalam memesan layanan laundry dan memantau status pesanan.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: kText,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ===== Card Fitur =====
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                          decoration: BoxDecoration(
                            color: kCard,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Judul Fitur + ikon
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Fitur',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: kText,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  CustomPaint(
                                    size: const Size(20, 18),
                                    painter: const _TrayIconPainter(color: kText),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const _FeatureItem('Pemesanan layanan'),
                              const SizedBox(height: 4),
                              const _FeatureItem('Keranjang'),
                              const SizedBox(height: 4),
                              const _FeatureItem('Riwayat pesanan'),
                              const SizedBox(height: 4),
                              const _FeatureItem('Status pesanan'),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // ===== Garis Putus-putus =====
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: const SizedBox(
                          width: double.infinity,
                          height: 2,
                          child: CustomPaint(painter: _DashedLinePainter(color: kText)),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ===== Versi =====
                      const Text(
                        'Versi 1.0.0',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: kText,
                        ),
                      ),

                      const Spacer(),

                      // ===== Copyright =====
                      const Padding(
                        padding: EdgeInsets.only(bottom: 28, top: 20),
                        child: Text(
                          '© 2026 LaundryGo',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: kText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String text;
  const _FeatureItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF111111),
        height: 1.5,
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const double dashWidth = 5.5;
    const double dashSpace = 4.5;
    const double period = dashWidth + dashSpace;

    final int dashCount = (size.width / period).floor();
    if (dashCount <= 0) return;

    final double totalWidth = dashCount * period;
    double x = (size.width - totalWidth) / 2 + dashSpace / 2;

    final paint = Paint()..color = color;
    for (int i = 0; i < dashCount; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, 0, dashWidth, size.height),
          const Radius.circular(1),
        ),
        paint,
      );
      x += period;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter old) => old.color != color;
}

class _TrayIconPainter extends CustomPainter {
  final Color color;
  const _TrayIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double w = size.width;
    final double h = size.height;

    final path = Path();
    path.moveTo(w * 0.12, h * 0.58);
    path.lineTo(w * 0.22, h * 0.90);
    path.lineTo(w * 0.38, h * 0.90);
    path.lineTo(w * 0.44, h * 0.74);
    path.lineTo(w * 0.56, h * 0.74);
    path.lineTo(w * 0.62, h * 0.90);
    path.lineTo(w * 0.78, h * 0.90);
    path.lineTo(w * 0.88, h * 0.58);
    canvas.drawPath(path, paint);

    canvas.drawLine(Offset(w * 0.50, h * 0.48), Offset(w * 0.50, h * 0.24), paint);
    canvas.drawLine(Offset(w * 0.38, h * 0.46), Offset(w * 0.26, h * 0.28), paint);
    canvas.drawLine(Offset(w * 0.62, h * 0.46), Offset(w * 0.74, h * 0.28), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}