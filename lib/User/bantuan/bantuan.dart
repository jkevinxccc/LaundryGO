import 'package:flutter/material.dart';
import '../tentang/tentang.dart';

class BantuanPage extends StatelessWidget {
  const BantuanPage({super.key});

  static const Color kBg = Color(0xFFAFCBE2);
  static const Color kCard = Color(0xFFFDF4D2);
  static const Color kBorder = Color(0xFFDB9558);
  static const Color kOrange = Color(0xFFDB9558);
  static const Color kText = Color(0xFF111111);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // ===== Header =====
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: kText, size: 24),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Bantuan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kText,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ===== Judul Pusat Bantuan =====
              const Text(
                'Pusat Bantuan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kText,
                ),
              ),

              const SizedBox(height: 16),

              // ===== Card FAQ 1 =====
              _buildFaqCard(
                title: 'Bagaimana cara memesan?',
                content:
                    'Klik atau pilih layanan → Pilih kategori masukkan jumlah berat → Klik keranjang → Cek pesanan anda, jika sesuai klik checkout',
              ),

              const SizedBox(height: 16),

              // ===== Card FAQ 2 =====
              _buildFaqCard(
                title: 'Bagaimana cara melihat pesanan?',
                content:
                    'Untuk melihat pesanan anda dapat klik tombol pesanan di bawah halaman. Semua pesanan anda akan tersimpan pada halaman pesanan.',
              ),

              const SizedBox(height: 44),

              // ===== Masih butuh bantuan? =====
              const Center(
                child: Text(
                  'Masih membutuhkan bantuan?',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: kText,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ===== Tombol Tentang Aplikasi =====
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TentangPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.headset_mic_rounded,
                      color: Colors.black87, size: 22),
                  label: const Text(
                    'Hubungi Kami',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kOrange,
                    elevation: 4,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqCard({required String title, required String content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: kText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }
}
