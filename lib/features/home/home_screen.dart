import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock_data.dart';
import '../../shared/providers/connectivity_provider.dart';
import '../../shared/widgets/sync_status_chip.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(connectivityProvider);
    final patient = MockData.currentPatient;
    final upcoming = MockData.upcomingConsultations;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gradient Header Card
              _buildHeaderCard(context, patient, isOnline),

              const SizedBox(height: 20),

              // Quick Actions
              _buildQuickActions(context),

              const SizedBox(height: 24),

              // Upcoming Consultation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('Upcoming Consultation', style: AppTextStyles.heading4),
              ),
              const SizedBox(height: 12),
              _buildUpcomingConsultation(context, upcoming),

              const SizedBox(height: 24),

              // Medicine Reminder
              _buildMedicineReminder(context),

              const SizedBox(height: 24),

              // Recent Health Summary
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('Recent Health Summary', style: AppTextStyles.heading4),
              ),
              const SizedBox(height: 12),
              _buildHealthSummary(patient),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, dynamic patient, bool isOnline) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Namaste, ${patient.name.split(' ').first} 👋',
                    style: AppTextStyles.heading3.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'How are you feeling today?',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
              // Notification bell
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                  onPressed: () => HapticFeedback.lightImpact(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SyncStatusChip(isSynced: isOnline),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1);
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.videocam_rounded,
        label: 'Consult Now',
        color: AppColors.primary,
        route: '/consultation',
      ),
      _QuickAction(
        icon: Icons.description_rounded,
        label: 'My Records',
        color: AppColors.accent,
        route: '/health-records',
      ),
      _QuickAction(
        icon: Icons.medication_rounded,
        label: 'Medicines',
        color: AppColors.secondary,
        route: '/medicines',
      ),
      _QuickAction(
        icon: Icons.camera_enhance_rounded,
        label: 'AI Scan',
        color: AppColors.error,
        route: '/ai-scan',
      ),
    ];

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                context.push(action.route);
              },
              child: Container(
                width: 100,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: action.color.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: action.color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(action.icon, color: action.color, size: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      action.label,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: action.color,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: Duration(milliseconds: 100 * index), duration: 400.ms)
              .slideX(begin: 0.2);
        },
      ),
    );
  }

  Widget _buildUpcomingConsultation(BuildContext context, List upcoming) {
    if (upcoming.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 48,
                color: AppColors.textHint.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              Text(
                'No upcoming consultations',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    final consultation = upcoming.first;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
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
        child: Row(
          children: [
            // Doctor Avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  consultation.doctorInitials,
                  style: AppTextStyles.heading4.copyWith(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    consultation.doctorName,
                    style: AppTextStyles.bodyBold,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    consultation.doctorSpecialization,
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              'Today, 2 hrs',
                              style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Join Button
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.accent, AppColors.primary],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Join Call',
                  style: AppTextStyles.buttonSmall,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildMedicineReminder(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: AppColors.secondaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.medication_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💊 2 medicines due at 2:00 PM',
                    style: AppTextStyles.bodyBold.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Paracetamol, Cetirizine',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 28),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideX(begin: 0.1);
  }

  Widget _buildHealthSummary(dynamic patient) {
    final vitals = [
      _VitalCard(label: 'Blood Pressure', value: '${patient.lastBp?.toInt() ?? '--'}/85', unit: 'mmHg', icon: Icons.favorite_rounded, color: AppColors.error),
      _VitalCard(label: 'Temperature', value: '${patient.lastTemperature ?? '--'}', unit: '°F', icon: Icons.thermostat_rounded, color: AppColors.secondary),
      _VitalCard(label: 'Weight', value: '${patient.lastWeight?.toInt() ?? '--'}', unit: 'kg', icon: Icons.monitor_weight_rounded, color: AppColors.primary),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: vitals.asMap().entries.map((entry) {
          final index = entry.key;
          final vital = entry.value;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index < vitals.length - 1 ? 10 : 0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(vital.icon, color: vital.color, size: 24),
                    const SizedBox(height: 8),
                    Text(vital.value, style: AppTextStyles.heading4.copyWith(fontSize: 18)),
                    Text(vital.unit, style: AppTextStyles.caption),
                    const SizedBox(height: 4),
                    Text(
                      vital.label,
                      style: AppTextStyles.caption.copyWith(fontSize: 12),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: 500 + index * 100), duration: 400.ms)
                  .slideY(begin: 0.2),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final String route;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });
}

class _VitalCard {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  _VitalCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });
}
