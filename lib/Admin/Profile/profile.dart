import 'package:flutter/material.dart';
import '../Gantipassword/ganti_password.dart';
import '../Tentang/tentang.dart';
import '../../services/supabase_service.dart';

/// Warna sesuai desain
class AppColors {
  static const background = Color(0xFFB2CDE3);
  static const tile = Color(0xFFFFF4D1);
  static const orange = Color(0xFFDC9560);
  static const navBar = Color(0xFF9CA777);
  static const navActive = Color(0xFFE0914F);
  static const avatar = Color(0xFFD9D9D9);
  static const text = Color(0xFF111111);
}

class ProfilAdminPage extends StatefulWidget {
  const ProfilAdminPage({super.key});

  @override
  State<ProfilAdminPage> createState() => _ProfilAdminPageState();
}

class _ProfilAdminPageState extends State<ProfilAdminPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          const Text(
            'Profil Admin',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 24),

          // Avatar + info
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.avatar,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    SupabaseService.currentUser?.username ?? 'Admin',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    SupabaseService.currentUser?.email ?? 'admin@laundrygo.com',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Menu
          _MenuTile(
            icon: Icons.lock_outline,
            title: 'Ganti Password',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GantiPasswordPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          _MenuTile(
            icon: Icons.info_outline,
            title: 'Tentang Aplikasi',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TentangPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 14),

          // Tombol keluar
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () async {
                await SupabaseService.logout();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: AppColors.text,
                elevation: 4,
                shadowColor: Colors.black54,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              icon: const Icon(Icons.logout, size: 20),
              label: const Text(
                'Keluar',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.tile,
      borderRadius: BorderRadius.circular(6),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(icon, size: 22, color: AppColors.text),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
