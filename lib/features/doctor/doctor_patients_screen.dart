import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class DoctorPatientsScreen extends StatefulWidget {
  const DoctorPatientsScreen({super.key});

  @override
  State<DoctorPatientsScreen> createState() => _DoctorPatientsScreenState();
}

class _DoctorPatientsScreenState extends State<DoctorPatientsScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Recent', 'Critical', 'Chronic'];

  final List<Map<String, dynamic>> _patients = [
    {'name': 'Rajinder Singh', 'age': 45, 'village': 'Nabha', 'initials': 'RS', 'lastVisit': '2 days ago', 'conditions': ['Diabetes', 'Hypertension'], 'isCritical': false},
    {'name': 'Sukhwinder Kaur', 'age': 38, 'village': 'Amloh', 'initials': 'SK', 'lastVisit': '1 week ago', 'conditions': ['Arthritis'], 'isCritical': false},
    {'name': 'Harpreet Gill', 'age': 55, 'village': 'Nabha', 'initials': 'HG', 'lastVisit': 'Today', 'conditions': ['Diabetes'], 'isCritical': true},
    {'name': 'Balwinder Kaur', 'age': 42, 'village': 'Samana', 'initials': 'BK', 'lastVisit': '3 days ago', 'conditions': ['Asthma'], 'isCritical': false},
    {'name': 'Gurbachan Singh', 'age': 62, 'village': 'Patiala', 'initials': 'GS', 'lastVisit': '5 days ago', 'conditions': ['Heart Disease', 'Hypertension'], 'isCritical': true},
    {'name': 'Manpreet Kaur', 'age': 28, 'village': 'Nabha', 'initials': 'MK', 'lastVisit': '2 weeks ago', 'conditions': [], 'isCritical': false},
    {'name': 'Jaswinder Singh', 'age': 50, 'village': 'Sangrur', 'initials': 'JS', 'lastVisit': '1 month ago', 'conditions': ['Diabetes'], 'isCritical': false},
  ];

  List<Map<String, dynamic>> get _filteredPatients {
    var list = _patients;
    if (_searchQuery.isNotEmpty) {
      list = list.where((p) => (p['name'] as String).toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    if (_selectedFilter == 'Critical') {
      list = list.where((p) => p['isCritical'] == true).toList();
    } else if (_selectedFilter == 'Chronic') {
      list = list.where((p) => (p['conditions'] as List).isNotEmpty).toList();
    } else if (_selectedFilter == 'Recent') {
      list = list.take(3).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Patients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            onPressed: () => context.push('/abdm-history'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Search patients by name, village...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          const SizedBox(height: 12),

          // Filter chips
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

          // Patient list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredPatients.length,
              itemBuilder: (context, index) {
                final patient = _filteredPatients[index];
                return _buildPatientCard(patient, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> patient, int index) {
    final conditions = patient['conditions'] as List;
    return GestureDetector(
      onTap: () => context.push('/doctor/patient-detail'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
              child: Center(
                child: Text(patient['initials'], style: AppTextStyles.bodyBold.copyWith(color: Colors.white)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(patient['name'], style: AppTextStyles.bodyBold.copyWith(fontSize: 15)),
                      if (patient['isCritical'] == true) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('Critical', style: AppTextStyles.caption.copyWith(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('${patient['age']} yrs • ${patient['village']}',
                      style: AppTextStyles.caption.copyWith(fontSize: 12)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Last: ${patient['lastVisit']}',
                            style: AppTextStyles.caption.copyWith(fontSize: 11)),
                      ),
                      const SizedBox(width: 6),
                      ...conditions.take(2).map((c) => Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(c, style: AppTextStyles.caption.copyWith(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600)),
                            ),
                          )),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 22),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 80), duration: 300.ms);
  }
}
