import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/family_member_model.dart';
import '../../data/local/hive_service.dart';

class ActiveMemberNotifier extends StateNotifier<FamilyMemberModel?> {
  ActiveMemberNotifier() : super(null) {
    _loadActiveMember();
  }

  void _loadActiveMember() {
    final activeId = HiveService.getActiveMemberId();
    if (activeId != null) {
      final members = HiveService.getAll(HiveService.ashaMembersBox);
      final match = members.where((m) => m['id'] == activeId).toList();
      if (match.isNotEmpty) {
        state = FamilyMemberModel.fromMap(match.first);
      }
    }

    // If no active member, try to load the primary user
    if (state == null) {
      final members = HiveService.getAll(HiveService.ashaMembersBox);
      final primary = members.where((m) => m['relation'] == 'self').toList();
      if (primary.isNotEmpty) {
        state = FamilyMemberModel.fromMap(primary.first);
        HiveService.setActiveMemberId(state!.id);
      }
    }
  }

  Future<void> switchMember(String memberId) async {
    final members = HiveService.getAll(HiveService.ashaMembersBox);
    final match = members.where((m) => m['id'] == memberId).toList();
    if (match.isNotEmpty) {
      state = FamilyMemberModel.fromMap(match.first);
      await HiveService.setActiveMemberId(memberId);
    }
  }

  List<FamilyMemberModel> getAllMembers() {
    return HiveService.getAll(HiveService.ashaMembersBox)
        .map((m) => FamilyMemberModel.fromMap(m))
        .toList();
  }

  Future<void> addMember(FamilyMemberModel member) async {
    await HiveService.put(
      HiveService.ashaMembersBox,
      member.id,
      member.toMap(),
    );
  }

  Future<void> removeMember(String memberId) async {
    await HiveService.delete(HiveService.ashaMembersBox, memberId);
    if (state?.id == memberId) {
      _loadActiveMember();
    }
  }

  Future<void> updateMember(FamilyMemberModel member) async {
    await HiveService.put(
      HiveService.ashaMembersBox,
      member.id,
      member.toMap(),
    );
    if (state?.id == member.id) {
      state = member;
    }
  }
}

final activeMemberProvider =
    StateNotifierProvider<ActiveMemberNotifier, FamilyMemberModel?>((ref) {
  return ActiveMemberNotifier();
});
