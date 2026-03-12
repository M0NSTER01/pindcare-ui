import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock_data.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patient = MockData.currentPatient;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Hero Section with gradient header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  // Avatar
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.2),
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: Center(
                          child: Text(
                            patient.name.split(' ').map((n) => n[0]).take(2).join(),
                            style: AppTextStyles.heading1.copyWith(
                              color: Colors.white,
                              fontSize: 36,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => HapticFeedback.lightImpact(),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.edit, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ).animate().scale(
                    begin: const Offset(0.7, 0.7),
                    duration: 500.ms,
                    curve: Curves.elasticOut,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    patient.name,
                    style: AppTextStyles.heading2.copyWith(color: Colors.white),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 4),

                  Text(
                    '${patient.village}, ${patient.district}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 12),

                  // Patient ID chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'ID: ${patient.id}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Info Cards Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildInfoCard(
                    'Blood Group',
                    patient.bloodGroup,
                    Icons.water_drop_rounded,
                    AppColors.error,
                    0,
                  ),
                  const SizedBox(width: 12),
                  _buildInfoCard(
                    'Age',
                    '${patient.age} yrs',
                    Icons.cake_rounded,
                    AppColors.secondary,
                    1,
                  ),
                  const SizedBox(width: 12),
                  _buildInfoCard(
                    'Gender',
                    patient.gender,
                    Icons.person_rounded,
                    AppColors.primary,
                    2,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Emergency Contact
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.emergency_rounded, color: AppColors.error, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Emergency Contact',
                            style: AppTextStyles.label.copyWith(color: AppColors.error),
                          ),
                          Text(
                            '${patient.emergencyContactName} • ${patient.emergencyContact}',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.phone_rounded, color: AppColors.error),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

            const SizedBox(height: 20),

            // Health Vitals Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Last Recorded Vitals', style: AppTextStyles.heading4),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildVitalRow(
                          'Blood Pressure',
                          '${patient.lastBp?.toInt() ?? '--'}/85 mmHg',
                          Icons.favorite_rounded,
                          AppColors.error,
                        ),
                        const Divider(height: 20),
                        _buildVitalRow(
                          'Temperature',
                          '${patient.lastTemperature ?? '--'} °F',
                          Icons.thermostat_rounded,
                          AppColors.secondary,
                        ),
                        const Divider(height: 20),
                        _buildVitalRow(
                          'Weight',
                          '${patient.lastWeight?.toInt() ?? '--'} kg',
                          Icons.monitor_weight_rounded,
                          AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 600.ms, duration: 400.ms),

            const SizedBox(height: 20),

            // Settings
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Settings', style: AppTextStyles.heading4),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildSettingsItem(Icons.language_rounded, 'Language', 'English', context),
                        const Divider(height: 1, indent: 56),
                        _buildSettingsItem(Icons.notifications_rounded, 'Notifications', 'On', context),
                        const Divider(height: 1, indent: 56),
                        _buildSettingsItem(Icons.storage_rounded, 'Offline Data', '24 MB', context),
                        const Divider(height: 1, indent: 56),
                        _buildSettingsItem(Icons.info_outline_rounded, 'About', 'v1.0.0', context),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 700.ms, duration: 400.ms),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, Color color, int index) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(value, style: AppTextStyles.heading4.copyWith(fontSize: 16)),
            Text(label, style: AppTextStyles.caption.copyWith(fontSize: 12)),
          ],
        ),
      ).animate().fadeIn(
        delay: Duration(milliseconds: 400 + index * 100),
        duration: 400.ms,
      ).slideY(begin: 0.2),
    );
  }

  Widget _buildVitalRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Text(label, style: AppTextStyles.bodyMedium),
        const Spacer(),
        Text(value, style: AppTextStyles.bodyBold.copyWith(color: color)),
      ],
    );
  }

  Widget _buildSettingsItem(IconData icon, String label, String value, BuildContext context) {
    return InkWell(
      onTap: () => HapticFeedback.lightImpact(),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: AppTextStyles.bodyMedium),
            ),
            Text(value, style: AppTextStyles.bodySmall),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 20),
          ],
        ),
      ),
    );
  }
}
