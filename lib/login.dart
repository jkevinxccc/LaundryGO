import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'User/app_logo.dart';
import 'services/supabase_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  String _selectedRole = 'Users';
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Basic validation check
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Silakan masukkan Email dan Password',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.logoOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 🔗 Terhubung langsung ke Backend Supabase
      final user = await SupabaseService.login(
        email: email,
        password: password,
        role: _selectedRole,
      );

      if (!mounted) return;

      // Notifikasi Sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Login Supabase berhasil sebagai ${user.role} (${user.email})',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.rolePillInner,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      // Navigasi ke Dashboard
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/dashboard');
      });
    } catch (e) {
      if (!mounted) return;
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMsg,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    // App Logo (Matching Figma size & position)
                    const Center(
                      child: AppLogo(
                        size: 78,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Role Selector Pill ("Users")
                    _buildRolePill(),

                    const SizedBox(height: 18),

                    // Email Input Field
                    _buildInputField(
                      controller: _emailController,
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      leadingIcon: Icons.email_rounded,
                      leadingIconColor: AppColors.emailIcon,
                    ),

                    const SizedBox(height: 16),

                    // Password Input Field
                    _buildInputField(
                      controller: _passwordController,
                      hintText: 'Password',
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
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 26),

                    // "Masuk" Button
                    _buildLoginButton(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Role selector badge matching the Figma pill design
  Widget _buildRolePill() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.rolePillOuter,
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.all(4.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: () {
            setState(() {
              if (_selectedRole == 'Users') {
                _selectedRole = 'Admin';
              } else {
                _selectedRole = 'Users';
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: AppColors.rolePillInner,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.public,
                  size: 18,
                  color: AppColors.darkText,
                ),
                const SizedBox(width: 8),
                Text(
                  _selectedRole,
                  style: const TextStyle(
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
    );
  }

  /// Reusable input field matching Figma cream rounded styling
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
          Icon(
            leadingIcon,
            color: leadingIconColor,
            size: 22,
          ),
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

  /// Login button with Figma terracotta color and subtle shadow
  Widget _buildLoginButton() {
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
          onTap: _isLoading ? null : _handleLogin,
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkText),
                    ),
                  )
                : const Text(
                    'Masuk',
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
