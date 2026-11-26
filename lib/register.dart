import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'User/app_logo.dart';
import 'services/supabase_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _alamatController.dispose();
    _noHpController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final alamat = _alamatController.text.trim();
    final noHp = _noHpController.text.trim();

    if (username.isEmpty) {
      _showSnackBar('Username wajib diisi', isError: true);
      return;
    }

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Email dan Password wajib diisi', isError: true);
      return;
    }

    if (!email.contains('@')) {
      _showSnackBar('Format email tidak valid', isError: true);
      return;
    }

    if (password.length < 6) {
      _showSnackBar('Password minimal 6 karakter', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await SupabaseService.register(
        username: username,
        email: email,
        password: password,
        alamat: alamat.isEmpty ? 'Alamat Belum Diatur' : alamat,
        noTelp: noHp.isEmpty ? '-' : noHp,
      );

      if (!mounted) return;

      _showSnackBar('Akun berhasil dibuat! Silakan login.', isError: false);

      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/login');
      });
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceAll('Exception: ', '');
      _showSnackBar(msg, isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: isError ? Colors.redAccent : AppColors.rolePillInner,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Register',
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkText),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 12.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ===== Logo =====
                  const Center(
                    child: AppLogo(size: 78, fontSize: 18),
                  ),

                  const SizedBox(height: 36),

                  // ===== Role Pill (Users — hanya Users yang bisa daftar) =====
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.rolePillOuter,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: AppColors.rolePillInner,
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.public, size: 18, color: AppColors.darkText),
                            SizedBox(width: 8),
                            Text(
                              'Users',
                              style: TextStyle(
                                color: AppColors.darkText,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ===== Username =====
                  _buildInputField(
                    controller: _usernameController,
                    hintText: 'Username',
                    keyboardType: TextInputType.text,
                    leadingIcon: Icons.person_rounded,
                    leadingIconColor: AppColors.emailIcon,
                  ),

                  const SizedBox(height: 14),

                  // ===== Email =====
                  _buildInputField(
                    controller: _emailController,
                    hintText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    leadingIcon: Icons.email_rounded,
                    leadingIconColor: AppColors.emailIcon,
                  ),

                  const SizedBox(height: 14),

                  // ===== Password =====
                  _buildInputField(
                    controller: _passwordController,
                    hintText: 'Masukkan Password',
                    obscureText: _obscurePassword,
                    leadingIcon: Icons.lock_rounded,
                    leadingIconColor: AppColors.passwordIcon,
                    suffixWidget: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFF7A7A7A),
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ===== Alamat =====
                  _buildInputField(
                    controller: _alamatController,
                    hintText: 'Alamat',
                    keyboardType: TextInputType.streetAddress,
                    leadingIcon: Icons.location_on_rounded,
                    leadingIconColor: const Color(0xFFDB9558),
                  ),

                  const SizedBox(height: 14),

                  // ===== No Handphone =====
                  _buildInputField(
                    controller: _noHpController,
                    hintText: 'No Handphone',
                    keyboardType: TextInputType.phone,
                    leadingIcon: Icons.phone_rounded,
                    leadingIconColor: AppColors.emailIcon,
                  ),

                  const SizedBox(height: 28),

                  // ===== Tombol Daftar =====
                  _buildDaftarButton(),

                  const SizedBox(height: 20),

                  // ===== Link ke Login =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sudah Punya Akun? ',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.darkText,
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            Navigator.of(context).pushReplacementNamed('/login'),
                        child: const Text(
                          'LOGIN',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2F88FF),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData leadingIcon,
    required Color leadingIconColor,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixWidget,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(leadingIcon, color: leadingIconColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              style: const TextStyle(
                color: AppColors.darkText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              cursorColor: AppColors.darkText,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: AppColors.hintText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (suffixWidget != null) suffixWidget,
        ],
      ),
    );
  }

  Widget _buildDaftarButton() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.buttonPrimary,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: _isLoading ? null : _handleRegister,
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.darkText),
                    ),
                  )
                : const Text(
                    'Daftar',
                    style: TextStyle(
                      color: AppColors.darkText,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
