import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              // Header
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 40),
              ).animate().scale(
                    begin: const Offset(0.5, 0.5),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  ),
              const SizedBox(height: 20),
              Text(
                'Welcome to ArogyaLink',
                style: AppTextStyles.heading2,
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
              const SizedBox(height: 8),
              Text(
                'Select your role to continue',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
              const SizedBox(height: 36),

              // Role Cards
              _RoleCard(
                icon: Icons.medical_services_rounded,
                title: 'Doctor / Healthcare Provider',
                subtitle: 'Consult patients, manage appointments, access records',
                gradientColors: const [Color(0xFF0A6E4F), Color(0xFF00BFA5)],
                badge: 'Verification Required',
                badgeColor: AppColors.secondary,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  context.push('/register/doctor');
                },
                delay: 400,
              ),
              const SizedBox(height: 16),
              _RoleCard(
                icon: Icons.favorite_rounded,
                title: 'Individual User',
                subtitle: 'Book consultations, manage your health records',
                gradientColors: const [Color(0xFF43A047), Color(0xFF66BB6A)],
                onTap: () {
                  HapticFeedback.mediumImpact();
                  context.push('/register/patient');
                },
                delay: 550,
              ),
              const SizedBox(height: 16),
              _RoleCard(
                icon: Icons.family_restroom_rounded,
                title: 'ASHA / Family Account',
                subtitle: 'Manage health records for yourself and family members',
                gradientColors: const [Color(0xFFF5A623), Color(0xFFFFCC02)],
                badge: 'Multi-profile',
                badgeColor: AppColors.accent,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  context.push('/register/asha');
                },
                delay: 700,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback onTap;
  final int delay;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    this.badge,
    this.badgeColor,
    required this.onTap,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon circle
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[0].withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(title, style: AppTextStyles.bodyBold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (badge != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (badgeColor ?? AppColors.accent).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badge!,
                        style: AppTextStyles.caption.copyWith(
                          color: badgeColor ?? AppColors.accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textHint, size: 18),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms).slideX(begin: 0.15);
  }
}
