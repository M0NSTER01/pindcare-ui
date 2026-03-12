import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/gradient_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String _selectedLanguage = 'English';

  final List<_OnboardingSlide> _slides = [
    _OnboardingSlide(
      icon: Icons.video_call_rounded,
      title: 'Consult Doctors Remotely',
      subtitle: 'Connect with qualified doctors through video, audio, or chat — right from your village.',
      color: AppColors.primary,
    ),
    _OnboardingSlide(
      icon: Icons.folder_shared_rounded,
      title: 'Your Records, Always Safe',
      subtitle: 'All your health records stored securely on your device. Works even without internet.',
      color: AppColors.accent,
    ),
    _OnboardingSlide(
      icon: Icons.camera_enhance_rounded,
      title: 'AI Diagnosis in Seconds',
      subtitle: 'Point your camera at any skin condition and get instant AI-powered analysis and advice.',
      color: AppColors.secondary,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Language Selector
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ['Hindi', 'Punjabi', 'English'].map((lang) {
                  final isSelected = _selectedLanguage == lang;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(
                        lang,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.cardBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onSelected: (_) {
                        HapticFeedback.lightImpact();
                        setState(() => _selectedLanguage = lang);
                      },
                    ),
                  );
                }).toList(),
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.3),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  HapticFeedback.selectionClick();
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Illustration circle
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                slide.color.withValues(alpha: 0.15),
                                slide.color.withValues(alpha: 0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: slide.color.withValues(alpha: 0.15),
                              ),
                              child: Icon(
                                slide.icon,
                                size: 64,
                                color: slide.color,
                              ),
                            ),
                          ),
                        )
                            .animate(key: ValueKey('icon_$index'))
                            .scale(
                              begin: const Offset(0.6, 0.6),
                              duration: 600.ms,
                              curve: Curves.elasticOut,
                            )
                            .fadeIn(duration: 400.ms),

                        const SizedBox(height: 48),

                        Text(
                          slide.title,
                          style: AppTextStyles.heading2,
                          textAlign: TextAlign.center,
                        )
                            .animate(key: ValueKey('title_$index'))
                            .fadeIn(delay: 200.ms, duration: 400.ms)
                            .slideX(begin: 0.1),

                        const SizedBox(height: 16),

                        Text(
                          slide.subtitle,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        )
                            .animate(key: ValueKey('subtitle_$index'))
                            .fadeIn(delay: 350.ms, duration: 400.ms)
                            .slideX(begin: 0.1),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dots + Button
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
              child: Column(
                children: [
                  // Page Indicator Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentPage == index
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Get Started / Next button
                  GradientButton(
                    text: _currentPage == _slides.length - 1 ? 'Get Started' : 'Next',
                    icon: _currentPage == _slides.length - 1
                        ? Icons.arrow_forward_rounded
                        : null,
                    onPressed: () {
                      if (_currentPage < _slides.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        context.go('/role-selection');
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Skip
                  if (_currentPage < _slides.length - 1)
                    TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        context.go('/role-selection');
                      },
                      child: Text(
                        'Skip',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}
