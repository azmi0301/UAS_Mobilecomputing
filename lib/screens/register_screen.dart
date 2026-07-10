import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulate small loading delay for premium feel
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    final error = context.read<AuthProvider>().register(
          name: _nameCtrl.text,
          email: _emailCtrl.text,
          password: _passwordCtrl.text,
        );

    setState(() {
      _isLoading = false;
      _errorMessage = error;
    });

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akun berhasil dibuat!'),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Navigate to Home and clear navigation stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient matching LoginScreen
          Container(
            height: size.height,
            width: size.width,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary,
                  AppColors.secondary,
                ],
              ),
            ),
          ),

          // Decorative Background Circles
          Positioned(
            top: -40,
            left: -40,
            child: Opacity(
              opacity: 0.15,
              child: Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Opacity(
              opacity: 0.1,
              child: Container(
                width: 220,
                height: 220,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          // Back Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0, top: 8.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Register Form
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24.0, 48.0, 24.0, 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Buat Akun',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Daftar untuk mulai menyimpan resep favorit Anda',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Card Form
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.pink.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.pink.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline,
                                        color: AppColors.pink, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: const TextStyle(
                                          color: AppColors.pink,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Input Nama
                            TextFormField(
                              controller: _nameCtrl,
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.next,
                              style: const TextStyle(
                                  color: AppColors.textPrimary, fontSize: 15),
                              decoration: InputDecoration(
                                hintText: 'Nama Lengkap',
                                prefixIcon: const Icon(Icons.person_outline,
                                    color: AppColors.primary),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 16),
                                fillColor: AppColors.bgSecondary.withOpacity(0.7),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Nama tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Input Email
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              style: const TextStyle(
                                  color: AppColors.textPrimary, fontSize: 15),
                              decoration: InputDecoration(
                                hintText: 'Email',
                                prefixIcon: const Icon(Icons.email_outlined,
                                    color: AppColors.primary),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 16),
                                fillColor: AppColors.bgSecondary.withOpacity(0.7),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Email tidak boleh kosong';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(val.trim())) {
                                  return 'Format email tidak valid';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Input Password
                            TextFormField(
                              controller: _passwordCtrl,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.next,
                              style: const TextStyle(
                                  color: AppColors.textPrimary, fontSize: 15),
                              decoration: InputDecoration(
                                hintText: 'Password (min. 6 karakter)',
                                prefixIcon: const Icon(Icons.lock_outlined,
                                    color: AppColors.primary),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 16),
                                fillColor: AppColors.bgSecondary.withOpacity(0.7),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Password tidak boleh kosong';
                                }
                                if (val.length < 6) {
                                  return 'Password minimal 6 karakter';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Input Confirm Password
                            TextFormField(
                              controller: _confirmPasswordCtrl,
                              obscureText: _obscureConfirmPassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _handleRegister(),
                              style: const TextStyle(
                                  color: AppColors.textPrimary, fontSize: 15),
                              decoration: InputDecoration(
                                hintText: 'Ulangi Password',
                                prefixIcon: const Icon(Icons.lock_clock_outlined,
                                    color: AppColors.primary),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 16),
                                fillColor: AppColors.bgSecondary.withOpacity(0.7),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Konfirmasi password tidak boleh kosong';
                                }
                                if (val != _passwordCtrl.text) {
                                  return 'Password tidak cocok';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Tombol Daftar
                            ElevatedButton(
                              onPressed: _isLoading ? null : _handleRegister,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 2,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'Daftar Sekarang',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sudah punya akun
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Sudah punya akun? ',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            'Masuk',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
