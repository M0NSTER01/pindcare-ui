import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock_data.dart';
import '../../shared/widgets/empty_state_widget.dart';

class HealthRecordsScreen extends StatefulWidget {
  const HealthRecordsScreen({super.key});

  @override
  State<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen> {
  String _selectedFilter = 'All';
  final _searchController = TextEditingController();

  final List<String> _filters = ['All', 'Consultations', 'Prescriptions', 'AI Scans'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getRecordColor(String type) {
    switch (type) {
      case 'consultation':
        return AppColors.primary;
      case 'prescription':
        return AppColors.secondary;
      case 'ai_scan':
        return AppColors.accent;
      default:
        return AppColors.textHint;
    }
  }

  IconData _getRecordIcon(String type) {
    switch (type) {
      case 'consultation':
        return Icons.videocam_rounded;
      case 'prescription':
        return Icons.medication_rounded;
      case 'ai_scan':
        return Icons.camera_enhance_rounded;
      default:
        return Icons.description_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final records = MockData.healthRecords;
    final filteredRecords = _selectedFilter == 'All'
        ? records
        : records.where((r) {
            switch (_selectedFilter) {
              case 'Consultations':
                return r['type'] == 'consultation';
              case 'Prescriptions':
                return r['type'] == 'prescription';
              case 'AI Scans':
                return r['type'] == 'ai_scan';
              default:
                return true;
            }
          }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Health Records'),
        backgroundColor: AppColors.background,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search records...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ).animate().fadeIn(duration: 300.ms),

          // Filter Chips
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        filter,
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
                        setState(() => _selectedFilter = filter);
                      },
                    ),
                  );
                },
              ),
            ),
          ),

          // Sync pending banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.warningLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.sync_rounded, color: AppColors.warning, size: 18),
                const SizedBox(width: 8),
                Text(
                  '3 records pending sync — will upload when connected',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Records Timeline
          Expanded(
            child: filteredRecords.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.folder_open_rounded,
                    title: 'No Records Found',
                    message: 'Your health records will appear here',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredRecords.length,
                    itemBuilder: (context, index) {
                      final record = filteredRecords[index];
                      final date = record['date'] as DateTime;
                      final color = _getRecordColor(record['type'] as String);
                      final isSynced = record['syncStatus'] == 'synced';

                      return IntrinsicHeight(
                        child: Row(
                          children: [
                            // Timeline line
                            SizedBox(
                              width: 24,
                              child: Column(
                                children: [
                                  if (index > 0)
                                    Expanded(
                                      child: Container(
                                        width: 2,
                                        color: color.withValues(alpha: 0.3),
                                      ),
                                    ),
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: color,
                                      border: Border.all(
                                        color: color.withValues(alpha: 0.3),
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                  if (index < filteredRecords.length - 1)
                                    Expanded(
                                      child: Container(
                                        width: 2,
                                        color: color.withValues(alpha: 0.3),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Record Card
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.cardBackground,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.shadow,
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                  border: Border(
                                    left: BorderSide(color: color, width: 3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        _getRecordIcon(record['type'] as String),
                                        color: color,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            record['title'] as String,
                                            style: AppTextStyles.bodyBold.copyWith(fontSize: 15),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            record['subtitle'] as String,
                                            style: AppTextStyles.caption,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.surfaceVariant,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  '${date.day}/${date.month}/${date.year}',
                                                  style: AppTextStyles.caption.copyWith(fontSize: 12),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Icon(
                                                isSynced ? Icons.cloud_done : Icons.wifi_off,
                                                size: 14,
                                                color: isSynced
                                                    ? AppColors.success
                                                    : AppColors.warning,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      color: AppColors.textHint,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(
                            delay: Duration(milliseconds: 100 * index),
                            duration: 400.ms,
                          )
                          .slideX(begin: 0.1);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
