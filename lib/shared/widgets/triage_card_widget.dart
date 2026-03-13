import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Shown at the top of ChatDetailScreen when an AI scan is linked to the consultation.
class TriageCardWidget extends StatelessWidget {
  final String scanId;
  const TriageCardWidget({super.key, required this.scanId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Loading AI pre-diagnosis...'),
        ));
        // TODO: navigate to diagnosis result or show bottom sheet
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
        ),
        child: Row(children: [
          const Icon(Icons.auto_awesome_rounded, color: AppColors.accent, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('AI Pre-diagnosis available', style: AppTextStyles.bodyBold.copyWith(
              fontSize: 13, color: AppColors.accent)),
            Text('Tap to view the automated health assessment', style: AppTextStyles.caption),
          ])),
          const Icon(Icons.chevron_right_rounded, color: AppColors.accent, size: 20),
        ]),
      ),
    );
  }
}
