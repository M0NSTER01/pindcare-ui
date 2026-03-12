import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AiScanScreen extends StatefulWidget {
  const AiScanScreen({super.key});

  @override
  State<AiScanScreen> createState() => _AiScanScreenState();
}

class _AiScanScreenState extends State<AiScanScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _torchOn = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    HapticFeedback.heavyImpact();
    // Simulate capturing — go to analyzing screen
    if (mounted) context.push('/ai-scan/analyzing');
  }

  Future<void> _pickFromGallery() async {
    HapticFeedback.mediumImpact();
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      context.push('/ai-scan/analyzing');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview placeholder
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFF1A1A2E),
            child: Center(
              child: Icon(
                Icons.camera_alt_rounded,
                size: 64,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),

          // Scanning overlay
          Center(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: 280 + (_pulseController.value * 10),
                  height: 280 + (_pulseController.value * 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.accent.withValues(
                        alpha: 0.4 + (_pulseController.value * 0.3),
                      ),
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Corner brackets
                      ...List.generate(4, (index) {
                        final isTop = index < 2;
                        final isLeft = index % 2 == 0;
                        return Positioned(
                          top: isTop ? -1 : null,
                          bottom: isTop ? null : -1,
                          left: isLeft ? -1 : null,
                          right: isLeft ? null : -1,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              border: Border(
                                top: isTop
                                    ? const BorderSide(color: AppColors.accent, width: 3)
                                    : BorderSide.none,
                                bottom: !isTop
                                    ? const BorderSide(color: AppColors.accent, width: 3)
                                    : BorderSide.none,
                                left: isLeft
                                    ? const BorderSide(color: AppColors.accent, width: 3)
                                    : BorderSide.none,
                                right: !isLeft
                                    ? const BorderSide(color: AppColors.accent, width: 3)
                                    : BorderSide.none,
                              ),
                            ),
                          ),
                        );
                      }),

                      // Scanning line animation
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Positioned(
                            top: _pulseController.value * 260,
                            left: 10,
                            right: 10,
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    AppColors.accent.withValues(alpha: 0.8),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCircleButton(
                      Icons.close,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.pop();
                      },
                    ),
                    Text(
                      'AI Visual Diagnosis',
                      style: AppTextStyles.heading4.copyWith(color: Colors.white),
                    ),
                    _buildCircleButton(
                      _torchOn ? Icons.flash_on : Icons.flash_off,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _torchOn = !_torchOn);
                      },
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 400.ms),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 48),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Point camera at affected area',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Gallery button
                      _buildActionButton(
                        Icons.photo_library_rounded,
                        'Gallery',
                        onTap: _pickFromGallery,
                      ),
                      // Capture button
                      GestureDetector(
                        onTap: _captureImage,
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accent.withValues(
                                      alpha: 0.3 + (_pulseController.value * 0.2),
                                    ),
                                    blurRadius: 20 + (_pulseController.value * 10),
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: AppColors.primaryGradient,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Info button
                      _buildActionButton(
                        Icons.info_outline_rounded,
                        'Help',
                        onTap: () => HapticFeedback.lightImpact(),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
