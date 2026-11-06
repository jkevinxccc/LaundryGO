import 'package:flutter/material.dart';
import 'user/tentang/tentang.dart';

void main() => runApp(const BantuanApp());

class BantuanApp extends StatelessWidget {
  const BantuanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pusat Bantuan LaundryGo',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'AfacadFlux',
      ),
      home: const BantuanPage(),
    );
  }
}

class BantuanPage extends StatelessWidget {
  const BantuanPage({super.key});

  static const Color kBackgroundColor = Color(0xFFAFCBE3);
  static const Color kCardColor = Color(0xFFFFF3D0);
  static const Color kBorderColor = Color(0xFFDB9558);
  static const Color kButtonColor = Color(0xFFDB9558);
  static const Color kTextColor = Color(0xFF111111);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Top Bar: Tombol Kembali & Judul "Bantuan"
                Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => Navigator.maybePop(context),
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.arrow_back,
                          color: kTextColor,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Bantuan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kTextColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Judul Bagian: "Pusat Bantuan"
                const Text(
                  'Pusat Bantuan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kTextColor,
                  ),
                ),

                const SizedBox(height: 18),

                // Card 1: "Bagaimana cara memesan?"
                _buildHelpCard(
                  title: 'Bagaimana cara memesan?',
                  content:
                      'Klik atau pilih layanan → Pilih kategori masukkan jumlah berat → Klik keranjang → Cek pesanan anda, jika sesuai klik checkout',
                ),

                const SizedBox(height: 18),

                // Card 2: "Bagaimana cara melihat pesanan?"
                _buildHelpCard(
                  title: 'Bagaimana cara melihat pesanan?',
                  content:
                      'Untuk melihat pesanan anda dapat klik tombol pesanan di bawah halaman. Semua pesanan anda akan tersimpan pada halaman pesanan.',
                ),

                const SizedBox(height: 48),

                // Bagian "Masih membutuhkan bantuan?"
                const Center(
                  child: Text(
                    'Masih membutuhkan bantuan?',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      color: kTextColor,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Tombol "Tentang Aplikasi"
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TentangPage(),
                        ),
                      );
                    },
                    child: Ink(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: kButtonColor,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.headset_mic_rounded,
                            color: Colors.black,
                            size: 22,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Tentang Aplikasi',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Widget kartu bantuan seragam dengan border oranye dan bayangan lembut
  Widget _buildHelpCard({
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: kBorderColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w600,
              color: kTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: Color(0xFF222222),
            ),
          ),
        ],
      ),
    );
  }
}
