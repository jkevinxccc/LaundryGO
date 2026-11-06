import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: EditProfilePage(),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  static const Color bgColor = Color(0xFFB0CDE4);
  static const Color fieldColor = Color(0xFFFFF3D0);
  static const Color buttonColor = Color(0xFFDB9559);

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
    // TODO: simpan data profil ke server / database
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil berhasil diperbarui')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              // Logo
              Center(child: _buildLogo()),
              const SizedBox(height: 14),

              // Title
              const Padding(
                padding: EdgeInsets.only(left: 9),
                child: Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Form
              _buildField('Nama', _namaController),
              const SizedBox(height: 12),
              _buildField('Alamat', _alamatController),
              const SizedBox(height: 12),
              _buildField('No Hp', _noHpController,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 18),

              // Button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: _onEdit,
                  icon: const Icon(Icons.edit, size: 16, color: Colors.black),
                  label: const Text(
                    'Edit',
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    elevation: 4,
                    shadowColor: Colors.black54,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
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
      height: 46,
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12, color: Colors.black87),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        ),
      ),
    );
  }

  /// Pakai gambar logo dari assets. Jika belum ada, tampil logo pengganti.
  Widget _buildLogo() {
    return Column(
      children: [
        Image.asset(
          'assets/logoo.png',
          height: 90,
          errorBuilder: (context, error, stackTrace) => _fallbackLogo(),
        ),
      ],
    );
  }

  Widget _fallbackLogo() {
    Widget tile(Color c, IconData i, {Color iconColor = Colors.white}) =>
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: c,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(i, size: 16, color: iconColor),
        );

    return Column(
      children: [
        Wrap(
          spacing: 3,
          runSpacing: 3,
          children: [
            tile(const Color(0xFF7B8B6F), Icons.local_laundry_service),
            tile(const Color(0xFFDB9559), Icons.checkroom),
            tile(const Color(0xFFFFE6C7), Icons.wash,
                iconColor: const Color(0xFFDB9559)),
            tile(const Color(0xFF3FB1A6), Icons.delete_outline),
          ].map((w) => SizedBox(width: 26, height: 26, child: w)).toList(),
        ),
        const SizedBox(height: 6),
        const Text(
          'LOUNDRYGO',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Color(0xFF3F6FA6),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}