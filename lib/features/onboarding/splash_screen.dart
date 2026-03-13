import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      // Check for saved session
      final box   = Hive.box('user_box');
      final token = box.get('token');
      final role  = box.get('role') as String? ?? 'patient';
      if (token != null && token.toString().isNotEmpty) {
        // Already logged in — go to the right dashboard
        switch (role) {
          case 'doctor':   context.go('/doctor/dashboard'); break;
          default:         context.go('/home');
        }
      } else {
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.accent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo: Stethoscope + Leaf
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.medical_services_rounded,
                    size: 56,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  Positioned(
                    top: 18,
                    right: 20,
                    child: Icon(
                      Icons.eco_rounded,
                      size: 28,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.3, 0.3),
                  end: const Offset(1.0, 1.0),
                  duration: 800.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 500.ms),

            const SizedBox(height: 28),

            // App Name
            Text(
              'ArogyaLink',
              style: AppTextStyles.heading1.copyWith(
                color: Colors.white,
                fontSize: 38,
                letterSpacing: 1.2,
              ),
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideY(begin: 0.3, duration: 600.ms),

            const SizedBox(height: 12),

            // Tagline
            Text(
              'आपका स्वास्थ्य, हमारी प्राथमिकता',
              style: AppTextStyles.tagline.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 17,
              ),
            )
                .animate()
                .fadeIn(delay: 700.ms, duration: 600.ms)
                .slideY(begin: 0.3, duration: 600.ms),

            const SizedBox(height: 8),

            Text(
              'Your Health, Our Priority',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            )
                .animate()
                .fadeIn(delay: 900.ms, duration: 600.ms),

            const SizedBox(height: 60),

            // Loading indicator
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: Colors.white.withValues(alpha: 0.7),
                strokeWidth: 2.5,
              ),
            ).animate().fadeIn(delay: 1200.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
