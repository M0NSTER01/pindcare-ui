import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AnalyzingScreen extends StatefulWidget {
  const AnalyzingScreen({super.key});

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen> {
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _simulateAnalysis();
  }

  Future<void> _simulateAnalysis() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) setState(() => _currentStep = 1);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) setState(() => _currentStep = 2);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      context.pushReplacement('/ai-scan/result');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Stack(
        children: [
          // Blurred background placeholder
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.3),
                  const Color(0xFF1A1A2E),
                ],
              ),
            ),
          ),

          // Content
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Brain/scan icon animation
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.1),
                          AppColors.accent.withValues(alpha: 0.1),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.psychology_rounded,
                      size: 56,
                      color: AppColors.primary,
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        begin: const Offset(0.9, 0.9),
                        end: const Offset(1.1, 1.1),
                        duration: 1000.ms,
                      )
                      .shimmer(
                        duration: 1500.ms,
                        color: AppColors.accent.withValues(alpha: 0.3),
                      ),

                  const SizedBox(height: 24),

                  Text(
                    'AI is analyzing your image...',
                    style: AppTextStyles.heading4,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Progress Steps
                  _buildStep(0, 'Image captured', Icons.check_circle_rounded),
                  const SizedBox(height: 16),
                  _buildStep(1, 'Identifying condition...', Icons.search_rounded),
                  const SizedBox(height: 16),
                  _buildStep(2, 'Preparing report...', Icons.description_rounded),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9)),
        ],
      ),
    );
  }

  Widget _buildStep(int stepIndex, String label, IconData icon) {
    final isComplete = _currentStep > stepIndex;
    final isCurrent = _currentStep == stepIndex;

    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isComplete
                ? AppColors.success
                : isCurrent
                    ? AppColors.accent
                    : AppColors.surfaceVariant,
          ),
          child: Center(
            child: isComplete
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : isCurrent
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(icon, color: AppColors.textHint, size: 18),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isComplete || isCurrent
                  ? AppColors.textPrimary
                  : AppColors.textHint,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
