import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class DoctorDashboardScreen extends ConsumerWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildStatsRow(),
              const SizedBox(height: 24),
              _buildSectionTitle('Today\'s Schedule'),
              const SizedBox(height: 12),
              _buildSchedule(context),
              const SizedBox(height: 24),
              _buildSectionTitle('Pending Actions'),
              const SizedBox(height: 12),
              _buildPendingActions(context),
              const SizedBox(height: 24),
              _buildSectionTitle('Recent Patient Activity'),
              const SizedBox(height: 12),
              _buildRecentActivity(context),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good Morning, Dr. Amandeep 👋',
                      style: AppTextStyles.heading3.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'General Physician',
                        style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
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
          const SizedBox(height: 16),
          Row(
            children: [
              // Verification badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text('Verified', style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const Spacer(),
              // Online toggle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('Online', style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1);
  }

  Widget _buildStatsRow() {
    final stats = [
      _StatItem(label: "Today's Appts", value: '8', icon: Icons.calendar_today_rounded, color: AppColors.primary),
      _StatItem(label: 'Patients', value: '124', icon: Icons.people_rounded, color: AppColors.accent),
      _StatItem(label: 'Pending', value: '3', icon: Icons.assignment_rounded, color: AppColors.secondary),
      _StatItem(label: 'Messages', value: '5', icon: Icons.chat_bubble_rounded, color: AppColors.error),
    ];

    return SizedBox(
      height: 95,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final stat = stats[index];
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(stat.icon, color: stat.color, size: 18),
                    const SizedBox(width: 4),
                    Text(stat.value, style: AppTextStyles.heading4.copyWith(color: stat.color)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(stat.label, style: AppTextStyles.caption.copyWith(fontSize: 11), textAlign: TextAlign.center),
              ],
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 200 + index * 100), duration: 400.ms).slideY(begin: 0.2);
        },
      ),
    );
  }

  Widget _buildSchedule(BuildContext context) {
    final schedule = [
      {'time': '9:00 AM', 'patient': 'Rajinder Singh', 'type': 'Video', 'status': 'Completed', 'initials': 'RS'},
      {'time': '10:30 AM', 'patient': 'Sukhwinder Kaur', 'type': 'Audio', 'status': 'Completed', 'initials': 'SK'},
      {'time': '12:00 PM', 'patient': 'Harpreet Gill', 'type': 'Video', 'status': 'In Progress', 'initials': 'HG'},
      {'time': '2:00 PM', 'patient': 'Balwinder Kaur', 'type': 'Chat', 'status': 'Upcoming', 'initials': 'BK'},
      {'time': '3:30 PM', 'patient': 'Gurbachan Singh', 'type': 'Video', 'status': 'Upcoming', 'initials': 'GS'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: schedule.asMap().entries.map((entry) {
          final i = entry.key;
          final appt = entry.value;
          final status = appt['status']!;
          final statusColor = status == 'Completed'
              ? AppColors.success
              : status == 'In Progress'
                  ? AppColors.secondary
                  : AppColors.primary;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                // Time
                SizedBox(
                  width: 60,
                  child: Text(appt['time']!, style: AppTextStyles.labelSmall.copyWith(fontSize: 12)),
                ),
                // Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(appt['initials']!, style: AppTextStyles.labelSmall.copyWith(color: Colors.white, fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appt['patient']!, style: AppTextStyles.bodyBold.copyWith(fontSize: 14)),
                      Row(
                        children: [
                          Icon(
                            appt['type'] == 'Video'
                                ? Icons.videocam_rounded
                                : appt['type'] == 'Audio'
                                    ? Icons.phone_rounded
                                    : Icons.chat_rounded,
                            size: 14,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(width: 4),
                          Text(appt['type']!, style: AppTextStyles.caption.copyWith(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status + action
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        status,
                        style: AppTextStyles.caption.copyWith(color: statusColor, fontWeight: FontWeight.w700, fontSize: 11),
                      ),
                    ),
                    if (status == 'Upcoming' || status == 'In Progress')
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: GestureDetector(
                          onTap: () => HapticFeedback.mediumImpact(),
                          child: Text('Join Call',
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12)),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 300 + i * 80), duration: 300.ms);
        }).toList(),
      ),
    );
  }

  Widget _buildPendingActions(BuildContext context) {
    final actions = [
      {'patient': 'Rajinder Singh', 'action': 'Write Prescription', 'urgency': 'High'},
      {'patient': 'Sukhwinder Kaur', 'action': 'Review Lab Report', 'urgency': 'Medium'},
      {'patient': 'Harpreet Gill', 'action': 'Review AI Scan', 'urgency': 'Low'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: actions.map((action) {
          final urgencyColor = action['urgency'] == 'High'
              ? AppColors.error
              : action['urgency'] == 'Medium'
                  ? AppColors.secondary
                  : AppColors.success;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: urgencyColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.assignment_rounded, color: urgencyColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(action['patient']!, style: AppTextStyles.bodyBold.copyWith(fontSize: 14)),
                      Text(action['action']!, style: AppTextStyles.caption.copyWith(fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: urgencyColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(action['urgency']!,
                      style: AppTextStyles.caption.copyWith(color: urgencyColor, fontWeight: FontWeight.w700, fontSize: 11)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    final activities = [
      {'patient': 'Rajinder Singh', 'action': 'Shared AI Scan result', 'time': '10 min ago'},
      {'patient': 'Balwinder Kaur', 'action': 'Sent a message', 'time': '25 min ago'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: activities.map((a) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      a['patient']!.split(' ').map((n) => n[0]).take(2).join(),
                      style: AppTextStyles.labelSmall.copyWith(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a['patient']!, style: AppTextStyles.bodyBold.copyWith(fontSize: 14)),
                      Text(a['action']!, style: AppTextStyles.caption.copyWith(fontSize: 12)),
                    ],
                  ),
                ),
                Text(a['time']!, style: AppTextStyles.caption.copyWith(fontSize: 11)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(title, style: AppTextStyles.heading4),
    );
  }
}

class _StatItem {
  final String label, value;
  final IconData icon;
  final Color color;
  _StatItem({required this.label, required this.value, required this.icon, required this.color});
}
