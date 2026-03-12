import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock_data.dart';
import '../../shared/widgets/gradient_button.dart';

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  @override
  Widget build(BuildContext context) {
    final doctors = MockData.availableDoctors;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Book Consultation'),
        backgroundColor: AppColors.background,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        physics: const BouncingScrollPhysics(),
        itemCount: doctors.length,
        itemBuilder: (context, index) {
          final doctor = doctors[index];
          final isOnline = doctor['isOnline'] as bool;
          final languages = (doctor['languages'] as List).join(', ');

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(18),
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
              children: [
                Row(
                  children: [
                    // Avatar with online indicator
                    Stack(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              doctor['initials'] as String,
                              style: AppTextStyles.heading4.copyWith(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: isOnline ? AppColors.online : AppColors.offline,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor['name'] as String,
                            style: AppTextStyles.bodyBold,
                          ),
                          Text(
                            doctor['specialization'] as String,
                            style: AppTextStyles.bodySmall.copyWith(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: AppColors.secondary, size: 16),
                              const SizedBox(width: 2),
                              Text(
                                '${doctor['rating']}',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.secondary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(Icons.language, size: 14, color: AppColors.textHint),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  languages,
                                  style: AppTextStyles.caption.copyWith(fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 14),

                Row(
                  children: [
                    // Next slot
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            doctor['nextSlot'] as String,
                            style: AppTextStyles.labelSmall.copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      doctor['consultationFee'] as String,
                      style: AppTextStyles.bodyBold.copyWith(color: AppColors.primary),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        _showBookingFlow(context, doctor);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          'Book Now',
                          style: AppTextStyles.buttonSmall,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: Duration(milliseconds: 100 * index), duration: 400.ms)
              .slideY(begin: 0.1);
        },
      ),
    );
  }

  void _showBookingFlow(BuildContext context, Map<String, dynamic> doctor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BookingSheet(doctor: doctor),
    );
  }
}

class _BookingSheet extends StatefulWidget {
  final Map<String, dynamic> doctor;

  const _BookingSheet({required this.doctor});

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  int _step = 0;
  int _selectedDateIndex = 0;
  int _selectedTimeIndex = -1;
  String _consultationType = 'video';
  final _symptomsController = TextEditingController();

  final _timeSlots = [
    '9:00 AM', '10:00 AM', '11:00 AM',
    '2:00 PM', '3:00 PM', '4:00 PM',
    '5:00 PM', '6:00 PM',
  ];

  @override
  void dispose() {
    _symptomsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Step indicator
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: List.generate(4, (index) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: index <= _step
                          ? AppColors.primary
                          : AppColors.divider,
                    ),
                  ),
                );
              }),
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildStepContent(),
            ),
          ),

          // Bottom buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (_step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        setState(() => _step--);
                      },
                      child: const Text('Back'),
                    ),
                  ),
                if (_step > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GradientButton(
                    text: _step == 3 ? 'Confirm Booking' : 'Continue',
                    onPressed: () {
                      if (_step < 3) {
                        setState(() => _step++);
                      } else {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Booking confirmed! ✅'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return _buildDateStep();
      case 1:
        return _buildTimeStep();
      case 2:
        return _buildSymptomsStep();
      case 3:
        return _buildConfirmStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDateStep() {
    final dates = List.generate(7, (i) => DateTime.now().add(Duration(days: i)));
    final dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Date', style: AppTextStyles.heading3),
        const SizedBox(height: 16),
        SizedBox(
          height: 85,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
              final isSelected = _selectedDateIndex == index;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedDateIndex = index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 60,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected ? null : Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayNames[date.weekday % 7],
                        style: AppTextStyles.caption.copyWith(
                          color: isSelected ? Colors.white70 : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${date.day}',
                        style: AppTextStyles.heading4.copyWith(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Time', style: AppTextStyles.heading3),
        const SizedBox(height: 8),

        // Consultation type toggle
        Row(
          children: [
            _buildTypeChip('📹 Video', 'video'),
            const SizedBox(width: 8),
            _buildTypeChip('📞 Audio', 'audio'),
            const SizedBox(width: 8),
            _buildTypeChip('💬 Chat', 'chat'),
          ],
        ),

        const SizedBox(height: 18),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _timeSlots.asMap().entries.map((entry) {
            final isSelected = _selectedTimeIndex == entry.key;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedTimeIndex = entry.key);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                  border: isSelected ? null : Border.all(color: AppColors.divider),
                ),
                child: Text(
                  entry.value,
                  style: AppTextStyles.label.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTypeChip(String label, String type) {
    final isSelected = _consultationType == type;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _consultationType = type);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withValues(alpha: 0.15) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isSelected ? AppColors.accent : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildSymptomsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Describe Symptoms', style: AppTextStyles.heading3),
        const SizedBox(height: 16),
        TextField(
          controller: _symptomsController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Describe your symptoms here...',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => HapticFeedback.lightImpact(),
          icon: const Icon(Icons.camera_enhance_rounded, size: 18),
          label: const Text('Attach AI Scan'),
        ),
      ],
    );
  }

  Widget _buildConfirmStep() {
    final dates = List.generate(7, (i) => DateTime.now().add(Duration(days: i)));
    final selectedDate = dates[_selectedDateIndex];
    final selectedTime = _selectedTimeIndex >= 0 ? _timeSlots[_selectedTimeIndex] : 'Not selected';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Booking Summary', style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          _buildSummaryRow('Doctor', widget.doctor['name'] as String),
          _buildSummaryRow('Specialization', widget.doctor['specialization'] as String),
          _buildSummaryRow('Date', '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
          _buildSummaryRow('Time', selectedTime),
          _buildSummaryRow('Type', _consultationType.toUpperCase()),
          _buildSummaryRow('Fee', widget.doctor['consultationFee'] as String),
          if (_symptomsController.text.isNotEmpty)
            _buildSummaryRow('Symptoms', _symptomsController.text),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: AppTextStyles.label),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.bodyMedium),
          ),
        ],
      ),
    );
  }
}
