import 'package:flutter/material.dart';
import '../app_logo.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  static const Color kBg = Color(0xFFAFCBE2);
  static const Color kField = Color(0xFFFDF4D2);
  static const Color kOrange = Color(0xFFDB9558);

  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _noHpController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    _noHpController.dispose();
    super.dispose();
  }

  void _onEdit() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profil berhasil diperbarui'),
        backgroundColor: kOrange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Header =====
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  const Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ===== Logo =====
              const Center(
                child: AppLogo(size: 80, fontSize: 16),
              ),

              const SizedBox(height: 20),

              // ===== Judul =====
              const Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 16),

              // ===== Field Nama =====
              _buildField('Nama', _namaController),
              const SizedBox(height: 12),

              // ===== Field Alamat =====
              _buildField('Alamat', _alamatController),
              const SizedBox(height: 12),

              // ===== Field No Hp =====
              _buildField('No Hp', _noHpController,
                  keyboardType: TextInputType.phone),

              const SizedBox(height: 24),

              // ===== Tombol Edit =====
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _onEdit,
                  icon: const Icon(Icons.edit_rounded, size: 18, color: Colors.black87),
                  label: const Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kOrange,
                    elevation: 3,
                    shadowColor: Colors.black38,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String hint,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: kField,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 13, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: Colors.black45),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        ),
      ),
    );
  }
}