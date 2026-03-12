import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock_data.dart';

class MedicinesScreen extends StatefulWidget {
  const MedicinesScreen({super.key});

  @override
  State<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends State<MedicinesScreen> {
  final _searchController = TextEditingController();
  String _currentLocation = '📍 Nabha, Punjab';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getStockColor(String status) {
    switch (status) {
      case 'inStock':
        return AppColors.inStock;
      case 'outOfStock':
        return AppColors.outOfStock;
      case 'lowStock':
        return AppColors.lowStock;
      default:
        return AppColors.textHint;
    }
  }

  String _getStockLabel(String status) {
    switch (status) {
      case 'inStock':
        return '🟢 In Stock';
      case 'outOfStock':
        return '🔴 Out of Stock';
      case 'lowStock':
        return '🟡 Low Stock';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final pharmacies = MockData.pharmacies;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Medicine Availability'),
        backgroundColor: AppColors.background,
      ),
      body: Column(
        children: [
          // Search + Location
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search medicine...',
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.textHint),
              ),
            ),
          ).animate().fadeIn(duration: 300.ms),

          // Location chip
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          _currentLocation,
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down, color: AppColors.primary, size: 16),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => HapticFeedback.lightImpact(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: const Icon(Icons.filter_list_rounded, color: AppColors.textSecondary, size: 20),
                  ),
                ),
              ],
            ),
          ),

          // Pharmacies List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const BouncingScrollPhysics(),
              itemCount: pharmacies.length,
              itemBuilder: (context, index) {
                final pharmacy = pharmacies[index];
                final medicines = pharmacy['medicines'] as List;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(18),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pharmacy Header
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.local_pharmacy_rounded,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pharmacy['name'] as String,
                                  style: AppTextStyles.bodyBold,
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(Icons.directions_walk, size: 14, color: AppColors.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      pharmacy['distance'] as String,
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Hours chip
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: pharmacy['isOpen'] == true
                                  ? AppColors.successLight
                                  : AppColors.errorLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              pharmacy['isOpen'] == true ? 'Open' : 'Closed',
                              style: AppTextStyles.caption.copyWith(
                                color: pharmacy['isOpen'] == true
                                    ? AppColors.success
                                    : AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 56),
                        child: Text(
                          pharmacy['hours'] as String,
                          style: AppTextStyles.caption,
                        ),
                      ),

                      const Divider(height: 24),

                      // Medicines
                      ...medicines.map((med) {
                        final stockColor = _getStockColor(med['status'] as String);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      med['name'] as String,
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                    Text(
                                      med['price'] as String,
                                      style: AppTextStyles.caption.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: stockColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getStockLabel(med['status'] as String),
                                  style: AppTextStyles.caption.copyWith(
                                    color: stockColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: 150 * index), duration: 400.ms)
                    .slideY(begin: 0.1);
              },
            ),
          ),
        ],
      ),
    );
  }
}
