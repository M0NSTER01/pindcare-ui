import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/providers/connectivity_provider.dart';
import '../widgets/offline_banner.dart';

class DoctorShell extends ConsumerStatefulWidget {
  final Widget child;
  final GoRouterState state;

  const DoctorShell({super.key, required this.child, required this.state});

  @override
  ConsumerState<DoctorShell> createState() => _DoctorShellState();
}

class _DoctorShellState extends ConsumerState<DoctorShell> {
  int _getCurrentIndex(String location) {
    if (location.startsWith('/doctor/appointments')) return 1;
    if (location.startsWith('/doctor/patients')) return 2;
    if (location.startsWith('/doctor/messages')) return 3;
    if (location.startsWith('/doctor/profile')) return 4;
    return 0;
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
                _buildNavItem(0, Icons.dashboard_rounded, 'Dashboard', currentIndex),
                _buildNavItem(1, Icons.calendar_month_rounded, 'Appointments', currentIndex),
                _buildNavItem(2, Icons.people_rounded, 'Patients', currentIndex),
                _buildNavItem(3, Icons.chat_bubble_rounded, 'Messages', currentIndex),
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
            context.go('/doctor/dashboard');
            break;
          case 1:
            context.go('/doctor/appointments');
            break;
          case 2:
            context.go('/doctor/patients');
            break;
          case 3:
            context.go('/doctor/messages');
            break;
          case 4:
            context.go('/doctor/profile');
            break;
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textHint,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textHint,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
