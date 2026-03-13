import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/widgets/gradient_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _loading    = false;
  bool _showPass   = false;
  String? _error;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    setState(() { _loading = true; _error = null; });

    try {
      final user = await ref.read(authProvider.notifier)
          .login(_phoneCtrl.text.trim(), _passCtrl.text.trim());

      if (!mounted) return;

      // Route based on role
      switch (user.role) {
        case 'doctor':   context.go('/doctor/dashboard'); break;
        case 'asha':     context.go('/home'); break;
        case 'pharmacy': context.go('/home'); break;
        default:         context.go('/home');
      }
    } catch (e) {
      setState(() {
        _error = 'Incorrect phone or password. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Logo
                Center(
                  child: Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    child: const Icon(Icons.medical_services_rounded, color: Colors.white, size: 44),
                  ).animate().scale(begin: const Offset(0.5, 0.5), duration: 600.ms, curve: Curves.elasticOut),
                ),

                const SizedBox(height: 28),

                // Title
                Center(
                  child: Column(children: [
                    Text('Welcome Back', style: AppTextStyles.heading2.copyWith(fontSize: 28)),
                    const SizedBox(height: 6),
                    Text('Log in to PindCare', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  ]),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 40),

                // Error banner
                if (_error != null) Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_error!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.error))),
                  ]),
                ).animate().fadeIn().shake(),

                // Phone field
                Text('Phone Number', style: AppTextStyles.label),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: AppTextStyles.bodyMedium,
                  decoration: InputDecoration(
                    hintText: '9876543210',
                    prefixIcon: const Icon(Icons.phone_rounded, color: AppColors.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.divider)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.primary, width: 2)),
                  ),
                  validator: (v) => (v == null || v.trim().length < 10) ? 'Enter valid phone number' : null,
                ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),

                const SizedBox(height: 20),

                // Password field
                Text('Password', style: AppTextStyles.label),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: !_showPass,
                  style: AppTextStyles.bodyMedium,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.primary),
                    suffixIcon: IconButton(
                      icon: Icon(_showPass ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: AppColors.textHint),
                      onPressed: () => setState(() => _showPass = !_showPass),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.divider)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.primary, width: 2)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your password' : null,
                ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),

                const SizedBox(height: 32),

                // Login button
                GradientButton(
                  text: _loading ? 'Logging in...' : 'Log In',
                  icon: Icons.login_rounded,
                  onPressed: _loading ? null : _login,
                ).animate().fadeIn(delay: 500.ms),

                const SizedBox(height: 20),

                // Divider
                Row(children: [
                  const Expanded(child: Divider()),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or', style: AppTextStyles.caption.copyWith(color: AppColors.textHint))),
                  const Expanded(child: Divider()),
                ]),

                const SizedBox(height: 20),

                // Register link
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/role-selection'),
                    child: RichText(text: TextSpan(
                      text: "Don't have an account? ",
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      children: [TextSpan(text: 'Register', style: AppTextStyles.bodyBold.copyWith(color: AppColors.primary))],
                    )),
                  ),
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 16),

                // Quick test creds box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 16),
                      const SizedBox(width: 6),
                      Text('Test Credentials (password: pindcare123)', style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                    ]),
                    const SizedBox(height: 8),
                    _credRow('Doctor:', '9876543210'),
                    _credRow('Patient:', '9000000001'),
                    _credRow('ASHA:', '9100000001'),
                    _credRow('Pharmacy:', '9200000001'),
                  ]),
                ).animate().fadeIn(delay: 700.ms),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _credRow(String role, String phone) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(children: [
      SizedBox(width: 80, child: Text(role, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary))),
      GestureDetector(
        onTap: () => setState(() => _phoneCtrl.text = phone),
        child: Text(phone, style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600, decoration: TextDecoration.underline)),
      ),
      const SizedBox(width: 4),
      const Icon(Icons.touch_app_rounded, size: 13, color: AppColors.textHint),
    ]),
  );
}
