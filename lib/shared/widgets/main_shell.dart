import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/home/home_screen.dart';
import '../../features/health_records/health_records_screen.dart';
import '../../features/medicines/medicines_screen.dart';
import '../../features/profile/profile_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/connectivity_provider.dart';
import 'offline_banner.dart';

class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  final GoRouterState state;

  const MainShell({
    super.key,
    required this.child,
    required this.state,
  });

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabPulseController;

  int _getCurrentIndex(String location) {
    if (location.startsWith('/health-records')) return 1;
    if (location.startsWith('/medicines')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  void initState() {
    super.initState();
    _fabPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _fabPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(connectivityProvider);
    final currentIndex = _getCurrentIndex(widget.state.uri.toString());

    return Scaffold(
      body: Column(
        children: [
          if (!isOnline) const OfflineBanner(),
          Expanded(child: widget.child),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'Home', currentIndex),
                _buildNavItem(1, Icons.description_rounded, 'Records', currentIndex),
                // Center FAB
                _buildFab(context),
                _buildNavItem(3, Icons.medication_rounded, 'Medicines', currentIndex),
                _buildNavItem(4, Icons.person_rounded, 'Profile', currentIndex),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, int currentIndex) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        switch (index) {
          case 0:
            context.go('/home');
            break;
          case 1:
            context.go('/health-records');
            break;
          case 3:
            context.go('/medicines');
            break;
          case 4:
            context.go('/profile');
            break;
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textHint,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textHint,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        context.push('/ai-scan');
      },
      child: AnimatedBuilder(
        animation: _fabPulseController,
        builder: (context, child) {
          return Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(
                    alpha: 0.3 + (_fabPulseController.value * 0.2),
                  ),
                  blurRadius: 16 + (_fabPulseController.value * 8),
                  spreadRadius: 1 + (_fabPulseController.value * 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.camera_enhance_rounded,
              color: Colors.white,
              size: 28,
            ),
          );
        },
      ),
    );
  }
}
