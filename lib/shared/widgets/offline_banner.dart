import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        gradient: AppColors.offlineGradient,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, color: AppColors.textWhite, size: 18),
          const SizedBox(width: 8),
          Text(
            '📡 Offline Mode — Records saved locally',
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textWhite),
          ),
        ],
      ),
    ).animate().slideY(begin: -1, duration: 400.ms, curve: Curves.easeOut);
  }
}
