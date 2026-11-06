import 'package:flutter/material.dart';
import 'pesan_layanan.dart';
import 'keranjang.dart';
import 'cart_state.dart';

void main() => runApp(const LaundryApp());

class LaundryApp extends StatelessWidget {
  const LaundryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LaundryGO',
      theme: ThemeData(useMaterial3: true),
      home: const MainPage(),
    );
  }
}

// Aliases for compatibility
typedef DashboardPage = MainPage;
typedef UserDashboardPage = MainPage;

// ================== WARNA SESUAI FIGMA ==================
const kBackground = Color(0xFFAFCBE2);
const kCard = Color(0xFFFDF3D0);
const kButton = Color(0xFFDB9558);
const kNavBar = Color(0xFF97A87A);
const kIconBox = Color(0xFFD9D9D9);
const kBlue = Color(0xFF2F88FF);

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _index = 0;

  final List<Widget> _pages = const [
    BerandaPage(),
    PesananPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      // Pada tab Beranda (index 0), tidak menggunakan AppBar hitam sesuai gambar Figma
      appBar: _index == 0
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                _index == 1 ? 'Pesanan Saya' : 'Profil Pengguna',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Colors.black87),
                  tooltip: 'Keluar ke Login',
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                ),
              ],
            ),
      body: SafeArea(child: _pages[_index]),
      bottomNavigationBar: Container(
        height: 68,
        decoration: const BoxDecoration(
          color: kNavBar,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(0, Icons.home_rounded, 'Beranda'),
            _navItem(1, Icons.description_rounded, 'Pesanan'),
            _navItem(2, Icons.person_rounded, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int i, IconData icon, String label) {
    final bool isSelected = _index == i;
    // Pada gambar: Tab Beranda aktif berwarna Oranye (kButton), lainnya Putih
    final Color itemColor = isSelected ? kButton : Colors.white;

    return InkWell(
      onTap: () => setState(() => _index = i),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: itemColor),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: itemColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================== SCREEN 1: BERANDA ==================
class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  void _navigateToPesanLayanan(BuildContext context, [String? category]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PesanLayananPage(initialCategory: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Teks
          const Text(
            'Halo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Layanan laundry cepat dan terpercaya',
            style: TextStyle(fontSize: 12, color: Colors.black87),
          ),
          const SizedBox(height: 18),

          // ===== Banner Cream Card =====
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(text: 'Tinggal '),
                            TextSpan(
                              text: 'Klik,',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: '\nBaju Bersih Kembali Nyentrik.'),
                          ],
                        ),
                      ),
                    ),
                    const Icon(Icons.waves_rounded, size: 42, color: Colors.black87),
                  ],
                ),
                const SizedBox(height: 14),

                // Tombol "Pesan Sekarang" -> Navigasi ke Pesan Layanan
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () => _navigateToPesanLayanan(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kButton,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Pesan Sekarang',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ===== 4 Ikon Menu Cepat -> Semuanya mengarah ke Pesan Layanan =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _QuickMenu(
                icon: Icons.checkroom_rounded,
                label: 'Cuci Kering',
                onTap: () => _navigateToPesanLayanan(context, 'cuci_kering'),
              ),
              _QuickMenu(
                icon: Icons.local_laundry_service_rounded,
                label: 'Cuci Setrika',
                onTap: () => _navigateToPesanLayanan(context, 'cuci_setrika'),
              ),
              _QuickMenu(
                icon: Icons.iron_rounded,
                label: 'Setrika Saja',
                onTap: () => _navigateToPesanLayanan(context, 'setrika_saja'),
              ),
              _QuickMenu(
                icon: Icons.thunderstorm_rounded,
                label: 'Express',
                onTap: () => _navigateToPesanLayanan(context, 'express'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ===== Kategori Layanan Cream Card =====
          const Text(
            'Kategori Layanan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _CategoryItem(
                  icon: Icons.checkroom_rounded,
                  iconBoxColor: kIconBox,
                  iconColor: Colors.black87,
                  title: 'Pakaian Harian',
                  subtitle: 'Kemeja, Kaos, Celana, dll',
                  onTap: () => _navigateToPesanLayanan(context),
                ),
                const SizedBox(height: 16),
                _CategoryItem(
                  icon: Icons.menu_book_rounded,
                  iconBoxColor: kIconBox,
                  iconColor: Colors.black87,
                  title: 'Bed Cover',
                  subtitle: 'Selimut, Sprei, Sarung Bantal',
                  onTap: () => _navigateToPesanLayanan(context),
                ),
                const SizedBox(height: 16),
                _CategoryItem(
                  icon: Icons.toys_rounded,
                  iconBoxColor: kIconBox,
                  iconColor: Colors.black87,
                  title: 'Boneka',
                  subtitle: 'Boneka Kesayangan',
                  onTap: () => _navigateToPesanLayanan(context),
                ),
                const SizedBox(height: 16),
                _CategoryItem(
                  icon: Icons.curtains_rounded,
                  iconBoxColor: kIconBox,
                  iconColor: Colors.black87,
                  title: 'Lainnya',
                  subtitle: 'Jas, Gorden, dll',
                  onTap: () => _navigateToPesanLayanan(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ================== SCREEN: PESANAN TAB ==================
class PesananPage extends StatelessWidget {
  const PesananPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Pesanan Aktif',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Order #LG-9821',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2DBC9E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Sedang Dicuci',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Layanan: Cuci Kering (2 kg) + Setrika Saja (1 kg)'),
              const Text('Estimasi Selesai: Hari ini, 17:00 WIB'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Riwayat Pesanan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #LG-9750',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text('Cuci Setrika - Selesai'),
                ],
              ),
              Text(
                'Rp 24.000',
                style: TextStyle(fontWeight: FontWeight.bold, color: kButton),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ================== SCREEN: PROFILE TAB ==================
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          const CircleAvatar(
            radius: 46,
            backgroundColor: kButton,
            child: Icon(Icons.person_rounded, size: 54, color: Colors.white),
          ),
          const SizedBox(height: 12),
          const Text(
            'Pelanggan LaundryGO',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'user@laundrygo.id',
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 28),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _profileItem(Icons.edit_outlined, 'Ubah Profil'),
                const Divider(height: 16, color: Colors.black12),
                _profileItem(Icons.location_on_outlined, 'Alamat Pengantaran'),
                const Divider(height: 16, color: Colors.black12),
                _profileItem(Icons.help_outline_rounded, 'Bantuan & FAQ'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/login');
              },
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              label: const Text(
                'Keluar / Logout',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black87),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 13)),
          ),
          const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.black38),
        ],
      ),
    );
  }
}

// ================== HELPER WIDGETS ==================
class _QuickMenu extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickMenu({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          children: [
            Icon(icon, size: 38, color: kBlue),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final Color iconBoxColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.icon,
    required this.iconBoxColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBoxColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 28, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
