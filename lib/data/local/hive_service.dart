import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String patientsBox = 'patients';
  static const String consultationsBox = 'consultations';
  static const String prescriptionsBox = 'prescriptions';
  static const String aiScansBox = 'ai_scans';
  static const String settingsBox = 'settings';
  static const String appConfigBox = 'app_config';
  static const String usersBox = 'users';
  static const String doctorsBox = 'doctors';
  static const String ashaMembersBox = 'asha_members';
  static const String appointmentsBox = 'appointments';
  static const String chatMessagesBox = 'chat_messages';
  static const String conversationsBox = 'conversations';
  static const String pharmaciesBox = 'pharmacies';
  static const String medicinesBox = 'medicines';
  static const String abhaRecordsBox = 'abha_records';
  static const String facilitiesBox = 'facilities';
  static const String syncQueueBox = 'sync_queue';
  static const String medicineListBox = 'medicine_list';
  static const String roadNetworkBox = 'road_network';
  static const String notificationsBox = 'notifications';
  static const String offlineCacheBox = 'offline_cache'; // delta sync cache

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(patientsBox);
    await Hive.openBox(consultationsBox);
    await Hive.openBox(prescriptionsBox);
    await Hive.openBox(aiScansBox);
    await Hive.openBox(settingsBox);
    await Hive.openBox(appConfigBox);
    await Hive.openBox(usersBox);
    await Hive.openBox(doctorsBox);
    await Hive.openBox(ashaMembersBox);
    await Hive.openBox(appointmentsBox);
    await Hive.openBox(chatMessagesBox);
    await Hive.openBox(conversationsBox);
    await Hive.openBox(pharmaciesBox);
    await Hive.openBox(medicinesBox);
    await Hive.openBox(abhaRecordsBox);
    await Hive.openBox(facilitiesBox);
    await Hive.openBox(syncQueueBox);
    await Hive.openBox(medicineListBox);
    await Hive.openBox(roadNetworkBox);
    await Hive.openBox(notificationsBox);
    await Hive.openBox(offlineCacheBox);
  }

  // Generic CRUD operations
  static Box getBox(String boxName) => Hive.box(boxName);

  static Future<void> put(String boxName, String key, Map<String, dynamic> data) async {
    final box = getBox(boxName);
    await box.put(key, data);
  }

  static Map<String, dynamic>? get(String boxName, String key) {
    final box = getBox(boxName);
    final data = box.get(key);
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  static List<Map<String, dynamic>> getAll(String boxName) {
    final box = getBox(boxName);
    return box.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  static Future<void> delete(String boxName, String key) async {
    final box = getBox(boxName);
    await box.delete(key);
  }

  static Future<void> clear(String boxName) async {
    final box = getBox(boxName);
    await box.clear();
  }

  // App config helpers
  static Future<void> setUserRole(String role) async {
    await put(appConfigBox, 'user_role', {'value': role});
  }

  static String? getUserRole() {
    final data = get(appConfigBox, 'user_role');
    return data?['value'] as String?;
  }

  static Future<void> setActiveMemberId(String memberId) async {
    await put(appConfigBox, 'active_member_id', {'value': memberId});
  }

  static String? getActiveMemberId() {
    final data = get(appConfigBox, 'active_member_id');
    return data?['value'] as String?;
  }

  static Future<void> setOnboardingComplete(bool complete) async {
    await put(appConfigBox, 'onboarding_complete', {'value': complete});
  }

  static bool isOnboardingComplete() {
    final data = get(appConfigBox, 'onboarding_complete');
    return data?['value'] as bool? ?? false;
  }

  static Future<void> setRegistrationComplete(bool complete) async {
    await put(appConfigBox, 'registration_complete', {'value': complete});
  }

  static bool isRegistrationComplete() {
    final data = get(appConfigBox, 'registration_complete');
    return data?['value'] as bool? ?? false;
  }

  // Sync-related helpers
  static List<Map<String, dynamic>> getPendingSync(String boxName) {
    return getAll(boxName)
        .where((record) => record['syncStatus'] == 'pending')
        .toList();
  }

  static Future<void> markSynced(String boxName, String key) async {
    final data = get(boxName, key);
    if (data != null) {
      data['syncStatus'] = 'synced';
      await put(boxName, key, data);
    }
  }
}
