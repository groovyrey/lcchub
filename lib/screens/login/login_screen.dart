import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

import 'package:phosphor_flutter/phosphor_flutter.dart';
class LoginScreen extends StatefulWidget {
  final bool isLoading;
  final String? error;
  final Function(String, String) onLogin;
  final VoidCallback onClearError;

  const LoginScreen({
    super.key,
    required this.isLoading,
    required this.error,
    required this.onLogin,
    required this.onClearError,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/logo.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('LCC Hub', style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Student Portal', style: GoogleFonts.poppins(fontSize: 16, color: Colors.white.withValues(alpha: 0.8))),
                  const SizedBox(height: 48),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Column(
                      children: [
                        Text('Sign In', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _userIdController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Student ID',
                            prefixIcon: Icon(PhosphorIcons.user()),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(PhosphorIcons.lock()),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? PhosphorIcons.eyeSlash() : PhosphorIcons.eye()),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary)),
                          ),
                          onSubmitted: (_) => _login(),
                        ),
                        if (widget.error != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              children: [
                                Icon(PhosphorIcons.warningCircle(), color: AppColors.error, size: 20),
                                const SizedBox(width: 8),
                                Expanded(child: Text(widget.error!, style: GoogleFonts.poppins(color: AppColors.error, fontSize: 13))),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: widget.isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: widget.isLoading
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text('Sign In', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _login() {
    widget.onClearError();
    final userId = _userIdController.text.trim();
    final password = _passwordController.text.trim();
    if (userId.isNotEmpty && password.isNotEmpty) {
      widget.onLogin(userId, password);
    }
  }
}
