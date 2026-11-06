import 'package:flutter/material.dart';

void main() => runApp(const TentangApp());

class TentangApp extends StatelessWidget {
  const TentangApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tentang LaundryGo',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'AfacadFlux',
      ),
      home: const TentangPage(),
    );
  }
}

class TentangPage extends StatelessWidget {
  const TentangPage({super.key});

  static const Color kBackgroundColor = Color(0xFFAFCBE3);
  static const Color kCardColor = Color(0xFFFFF3D0);
  static const Color kTextColor = Color(0xFF111111);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Top Bar
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 8,
                          right: 16,
                          top: 8,
                          bottom: 4,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: kTextColor,
                                size: 24,
                              ),
                              onPressed: () => Navigator.maybePop(context),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Tentang',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: kTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Logo LaundryGo
                      Center(
                        child: Image.asset(
                          'assets/logoo.png',
                          width: 125,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildFallbackLogo(),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Deskripsi Aplikasi
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            style: TextStyle(
                              fontFamily: 'AfacadFlux',
                              fontSize: 14.5,
                              height: 1.45,
                              color: kTextColor,
                            ),
                            children: [
                              TextSpan(
                                text: 'LaundryGo',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text:
                                    ' merupakan aplikasi yang memudahkan pelanggan dalam memesan layanan laundry dan memantau status pesanan.',
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Card Fitur
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 36),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            color: kCardColor,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Judul Fitur + Icon
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Fitur',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: kTextColor,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  CustomPaint(
                                    size: const Size(20, 18),
                                    painter: const FeatureTrayIconPainter(
                                      color: kTextColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              // Daftar Fitur
                              const Text(
                                'Pemesanan layanan',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: kTextColor,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'Keranjang',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: kTextColor,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'Riwayat pesanan',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: kTextColor,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'Status pesanan',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: kTextColor,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Garis Putus-putus
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 36),
                        child: _buildDashedLine(),
                      ),

                      const SizedBox(height: 14),

                      // Versi
                      const Text(
                        'Versi 1.0.0',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: kTextColor,
                        ),
                      ),

                      const Spacer(),

                      // Copyright Footer
                      const Padding(
                        padding: EdgeInsets.only(bottom: 28, top: 20),
                        child: Text(
                          '© 2026 LaundryGo',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: kTextColor,
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

  /// Garis putus-putus mendatar.
  /// Memakai CustomPaint (bukan LayoutBuilder) supaya aman di dalam IntrinsicHeight.
  static Widget _buildDashedLine() {
    return const SizedBox(
      width: double.infinity,
      height: 1.6,
      child: CustomPaint(
        painter: DashedLinePainter(color: kTextColor),
      ),
    );
  }

  /// Logo fallback jika assets/logoo.png belum dimuat
  static Widget _buildFallbackLogo() {
    Widget tile(Color c, IconData i, {Color iconColor = Colors.white}) =>
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: c,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(i, size: 18, color: iconColor),
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 3.5,
          runSpacing: 3.5,
          children: [
            tile(const Color(0xFF7B8B6F), Icons.local_laundry_service),
            tile(const Color(0xFFDB9559), Icons.checkroom),
            tile(const Color(0xFFFFE6C7), Icons.waves,
                iconColor: const Color(0xFFDB9559)),
            tile(const Color(0xFF3FB1A6), Icons.shopping_basket_outlined),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'LOUNDRYGO',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF3F6FA6),
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}

/// Painter garis putus-putus mendatar (pengganti LayoutBuilder + Row)
class DashedLinePainter extends CustomPainter {
  final Color color;

  const DashedLinePainter({required this.color});

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
  bool shouldRepaint(covariant DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Custom painter untuk icon baki/inbox dengan 3 pancaran kilau (sparkles) di atasnya
class FeatureTrayIconPainter extends CustomPainter {
  final Color color;

  const FeatureTrayIconPainter({required this.color});

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

    // Gambar nampan/inbox dengan lekukan di bagian tengah depan
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

    // 3 sinar kilau di atas nampan (sparkles)
    canvas.drawLine(
      Offset(w * 0.50, h * 0.48),
      Offset(w * 0.50, h * 0.24),
      paint,
    );
    canvas.drawLine(
      Offset(w * 0.38, h * 0.46),
      Offset(w * 0.26, h * 0.28),
      paint,
    );
    canvas.drawLine(
      Offset(w * 0.62, h * 0.46),
      Offset(w * 0.74, h * 0.28),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}