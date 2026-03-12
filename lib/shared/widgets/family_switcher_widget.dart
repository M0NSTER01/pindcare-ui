import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/family_member_model.dart';
import '../providers/active_member_provider.dart';

class FamilySwitcherWidget extends ConsumerWidget {
  const FamilySwitcherWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeMember = ref.watch(activeMemberProvider);
    if (activeMember == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
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
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(
                activeMember.initials,
                style: AppTextStyles.bodyBold.copyWith(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Managing: ${activeMember.name}',
                  style: AppTextStyles.bodyBold.copyWith(color: Colors.white, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        activeMember.isPrimary ? 'You (Primary)' : activeMember.relation,
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              _showSwitchSheet(context, ref);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
              ),
              child: Text(
                'Switch',
                style: AppTextStyles.buttonSmall.copyWith(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSwitchSheet(BuildContext context, WidgetRef ref) {
    final members = ref.read(activeMemberProvider.notifier).getAllMembers();
    final activeId = ref.read(activeMemberProvider)?.id;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Select Profile', style: AppTextStyles.heading3),
              const SizedBox(height: 20),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: members.length,
                  itemBuilder: (ctx, index) {
                    final member = members[index];
                    final isActive = member.id == activeId;
                    return Padding(
                      padding: EdgeInsets.only(right: index < members.length - 1 ? 14 : 0),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          ref.read(activeMemberProvider.notifier).switchMember(member.id);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Switched to ${member.name}'s profile"),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 90,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary.withValues(alpha: 0.08)
                                : AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isActive ? AppColors.primary : AppColors.divider,
                              width: isActive ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        member.initials,
                                        style: AppTextStyles.bodyBold
                                            .copyWith(color: Colors.white, fontSize: 14),
                                      ),
                                    ),
                                  ),
                                  if (isActive)
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          color: AppColors.success,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                        child: const Icon(Icons.check, color: Colors.white, size: 10),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                member.name.split(' ').first,
                                style: AppTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: isActive ? AppColors.primary : null,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  member.isPrimary ? 'You' : member.relation,
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: 9,
                                    color: AppColors.secondaryDark,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
