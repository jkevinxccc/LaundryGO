import 'package:flutter/material.dart';
import '../../widgets/app_logo.dart';

class TentangPage extends StatelessWidget {
  const TentangPage({super.key});

  static const Color _background = Color(0xFFAFCBE2);
  static const Color _card = Color(0xFFFDF4D2);
  static const Color _text = Color(0xFF111111);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: _text,
                      size: 24,
                    ),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  const Text(
                    'Tentang',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _text,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const AppLogo(size: 90, fontSize: 18),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'LaundryGo membantu admin mengelola layanan laundry dan memantau pesanan pelanggan.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, height: 1.5, color: _text),
              ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fitur Admin',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _text,
                      ),
                    ),
                    SizedBox(height: 12),
                    _FeatureItem('Melihat dan mengelola pesanan'),
                    _FeatureItem('Memperbarui status pesanan'),
                    _FeatureItem('Melihat riwayat pesanan'),
                  ],
                ),
              ),
            ),
            const Spacer(),
            const Text(
              'Versi 1.0.0',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _text,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 28, top: 20),
              child: Text(
                '© 2026 LaundryGo',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          height: 1.5,
          color: Color(0xFF111111),
        ),
      ),
    );
  }
}
