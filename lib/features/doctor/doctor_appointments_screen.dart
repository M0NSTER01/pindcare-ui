import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/appointment_model.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() => _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  int _selectedDay = 3; // today index
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Video', 'Audio', 'Chat', 'Pending'];

  final List<AppointmentModel> _appointments = [
    AppointmentModel(id: 'APT-001', patientId: 'P1', patientName: 'Rajinder Singh', patientAge: 45, patientVillage: 'Nabha', doctorId: 'D1', doctorName: 'Dr. Amandeep Kaur', doctorSpecialization: 'General Physician', dateTime: DateTime.now().subtract(const Duration(hours: 3)), type: 'video', status: 'completed', symptoms: 'Persistent cough and mild fever since 3 days'),
    AppointmentModel(id: 'APT-002', patientId: 'P2', patientName: 'Sukhwinder Kaur', patientAge: 38, patientVillage: 'Amloh', doctorId: 'D1', doctorName: 'Dr. Amandeep Kaur', doctorSpecialization: 'General Physician', dateTime: DateTime.now().subtract(const Duration(hours: 1)), type: 'audio', status: 'completed', symptoms: 'Joint pain and swelling'),
    AppointmentModel(id: 'APT-003', patientId: 'P3', patientName: 'Harpreet Gill', patientAge: 55, patientVillage: 'Nabha', doctorId: 'D1', doctorName: 'Dr. Amandeep Kaur', doctorSpecialization: 'General Physician', dateTime: DateTime.now(), type: 'video', status: 'in_progress', symptoms: 'Diabetic follow-up checkup'),
    AppointmentModel(id: 'APT-004', patientId: 'P4', patientName: 'Balwinder Kaur', patientAge: 42, patientVillage: 'Samana', doctorId: 'D1', doctorName: 'Dr. Amandeep Kaur', doctorSpecialization: 'General Physician', dateTime: DateTime.now().add(const Duration(hours: 2)), type: 'chat', status: 'upcoming', symptoms: 'Skin rash and itching'),
    AppointmentModel(id: 'APT-005', patientId: 'P5', patientName: 'Gurbachan Singh', patientAge: 62, patientVillage: 'Patiala', doctorId: 'D1', doctorName: 'Dr. Amandeep Kaur', doctorSpecialization: 'General Physician', dateTime: DateTime.now().add(const Duration(hours: 4)), type: 'video', status: 'upcoming', symptoms: 'Blood pressure monitoring'),
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: 3 - i)));
    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Appointments')),
      body: Column(
        children: [
          // Week date picker
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 7,
              itemBuilder: (context, index) {
                final day = days[index];
                final isSelected = index == _selectedDay;
                final isToday = index == 3;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedDay = index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 56,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: isSelected
                          ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))]
                          : [BoxShadow(color: AppColors.shadow, blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dayLabels[day.weekday - 1],
                          style: AppTextStyles.caption.copyWith(
                            color: isSelected ? Colors.white.withValues(alpha: 0.8) : AppColors.textHint,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${day.day}',
                          style: AppTextStyles.heading4.copyWith(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontSize: 18,
                          ),
                        ),
                        if (isToday)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Filter tabs
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = filter == _selectedFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    checkmarkColor: AppColors.primary,
                    labelStyle: AppTextStyles.labelSmall.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: isSelected ? AppColors.primary : AppColors.divider),
                    ),
                    onSelected: (_) => setState(() => _selectedFilter = filter),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Appointment list
          Expanded(
            child: _appointments.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _appointments.length,
                    itemBuilder: (context, index) => _buildAppointmentCard(_appointments[index], index),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => HapticFeedback.mediumImpact(),
        label: const Text('Block Time'),
        icon: const Icon(Icons.block_rounded),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appt, int index) {
    final statusColor = appt.status == 'completed'
        ? AppColors.success
        : appt.status == 'in_progress'
            ? AppColors.secondary
            : appt.status == 'cancelled'
                ? AppColors.error
                : AppColors.primary;

    final statusLabel = appt.status == 'in_progress'
        ? 'In Progress'
        : '${appt.status[0].toUpperCase()}${appt.status.substring(1)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    appt.patientName.split(' ').map((n) => n[0]).take(2).join(),
                    style: AppTextStyles.bodyBold.copyWith(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appt.patientName, style: AppTextStyles.bodyBold.copyWith(fontSize: 15)),
                    Text('${appt.patientAge} yrs • ${appt.patientVillage ?? ""}',
                        style: AppTextStyles.caption.copyWith(fontSize: 12)),
                  ],
                ),
              ),
              Icon(
                appt.type == 'video'
                    ? Icons.videocam_rounded
                    : appt.type == 'audio'
                        ? Icons.phone_rounded
                        : Icons.chat_bubble_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ],
          ),
          if (appt.symptoms != null) ...[
            const SizedBox(height: 8),
            Text(
              appt.symptoms!.length > 50 ? '${appt.symptoms!.substring(0, 50)}...' : appt.symptoms!,
              style: AppTextStyles.caption.copyWith(fontSize: 13),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 14, color: AppColors.textHint),
              const SizedBox(width: 4),
              Text(
                '${appt.dateTime.hour}:${appt.dateTime.minute.toString().padLeft(2, '0')} • ${appt.durationMinutes} min',
                style: AppTextStyles.caption.copyWith(fontSize: 12),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(statusLabel,
                    style: AppTextStyles.caption.copyWith(
                        color: statusColor, fontWeight: FontWeight.w700, fontSize: 12)),
              ),
              if (appt.status == 'upcoming' || appt.status == 'in_progress') ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => HapticFeedback.mediumImpact(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('Join', style: AppTextStyles.buttonSmall.copyWith(fontSize: 12)),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 100), duration: 300.ms);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_rounded, size: 64, color: AppColors.textHint.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text('No appointments for this day', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
