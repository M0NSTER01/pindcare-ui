import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class SyncStatusChip extends StatelessWidget {
  final bool isSynced;

  const SyncStatusChip({super.key, required this.isSynced});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSynced
            ? AppColors.successLight
            : AppColors.warningLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSynced ? AppColors.success : AppColors.warning,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isSynced ? 'Synced' : 'Offline',
            style: AppTextStyles.caption.copyWith(
              color: isSynced ? AppColors.success : AppColors.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
