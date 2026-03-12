import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock_data.dart';
import '../../shared/widgets/gradient_button.dart';
import 'share_with_doctor_sheet.dart';

class DiagnosisResultScreen extends StatelessWidget {
  const DiagnosisResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scan = MockData.aiScans.first;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            HapticFeedback.lightImpact();
            context.go('/home');
          },
        ),
        title: const Text('Diagnosis Report'),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Thumbnail + Badge
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.divider, width: 2),
                    ),
                    child: const Icon(
                      Icons.image_rounded,
                      size: 48,
                      color: AppColors.textHint,
                    ),
                  ),
                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _getSeverityColor(scan.severity),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        _getSeverityIcon(scan.severity),
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8)),

            const SizedBox(height: 24),

            // Condition Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          _getConditionIcon(scan.conditionType),
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(scan.conditionName, style: AppTextStyles.heading4),
                            const SizedBox(height: 4),
                            // Confidence badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getConfidenceColor(scan.confidence).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${(scan.confidence * 100).toInt()}% confidence',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: _getConfidenceColor(scan.confidence),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Severity pill
                  _buildSeverityPill(scan.severity),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1),

            const SizedBox(height: 20),

            // Description
            _buildSection(
              'About this Condition',
              scan.description,
              Icons.info_outline_rounded,
              delay: 300,
            ),

            const SizedBox(height: 20),

            // First Aid Steps
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.healing_rounded, color: AppColors.accent, size: 22),
                      const SizedBox(width: 8),
                      Text('What to Do', style: AppTextStyles.heading4),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ...scan.firstAidSteps.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${entry.key + 1}',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(entry.value, style: AppTextStyles.bodyMedium),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.1),

            const SizedBox(height: 20),

            // Should See Doctor
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: scan.shouldSeeDoctor ? AppColors.errorLight : AppColors.successLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: (scan.shouldSeeDoctor ? AppColors.error : AppColors.success)
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        scan.shouldSeeDoctor
                            ? Icons.warning_amber_rounded
                            : Icons.check_circle_rounded,
                        color: scan.shouldSeeDoctor ? AppColors.error : AppColors.success,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        scan.shouldSeeDoctor ? 'Yes, See a Doctor' : 'No Doctor Visit Needed',
                        style: AppTextStyles.heading4.copyWith(
                          color: scan.shouldSeeDoctor ? AppColors.error : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(scan.doctorReasoning, style: AppTextStyles.bodyMedium),
                ],
              ),
            ).animate().fadeIn(delay: 500.ms, duration: 400.ms).slideY(begin: 0.1),

            const SizedBox(height: 28),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: GradientButton(
                    text: 'Share with Doctor',
                    icon: Icons.share_rounded,
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => ShareWithDoctorSheet(scan: scan),
                      );
                    },
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 600.ms, duration: 400.ms),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                    },
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Save'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      context.go('/ai-scan');
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Scan Again'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 700.ms, duration: 400.ms),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String body, IconData icon, {int delay = 0}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.heading4),
            ],
          ),
          const SizedBox(height: 10),
          Text(body, style: AppTextStyles.bodyMedium),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildSeverityPill(String severity) {
    String emoji;
    Color color;
    switch (severity) {
      case 'severe':
        emoji = '🔴 Severe';
        color = AppColors.error;
        break;
      case 'moderate':
        emoji = '🟡 Moderate';
        color = AppColors.warning;
        break;
      default:
        emoji = '🟢 Mild';
        color = AppColors.success;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        emoji,
        style: AppTextStyles.label.copyWith(color: color),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return AppColors.success;
    if (confidence >= 0.6) return AppColors.warning;
    return AppColors.error;
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'severe':
        return AppColors.error;
      case 'moderate':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity) {
      case 'severe':
        return Icons.warning_rounded;
      case 'moderate':
        return Icons.info_rounded;
      default:
        return Icons.check_rounded;
    }
  }

  IconData _getConditionIcon(String type) {
    switch (type) {
      case 'fungal':
        return Icons.bug_report_rounded;
      case 'wound':
        return Icons.healing_rounded;
      case 'rash':
        return Icons.grain_rounded;
      case 'bite':
        return Icons.pest_control_rounded;
      default:
        return Icons.medical_information_rounded;
    }
  }
}
