import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import '../local/hive_service.dart';
import 'api_service.dart';

/// Manages offline queueing and delta sync when connectivity is restored.
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  static const String _cacheBox = 'offline_cache';

  // ── Offline Queue ──────────────────────────────────────────────────────────

  /// Queue an action to be pushed to the server once connectivity is restored.
  Future<void> queueAction(Map<String, dynamic> action) async {
    final box = await Hive.openBox(HiveService.syncQueueBox);
    await box.add({...action, 'queued_at': DateTime.now().toIso8601String()});
  }

  /// Push all queued offline actions to the backend and clear the queue.
  Future<void> flushQueue() async {
    final box = Hive.isBoxOpen(HiveService.syncQueueBox)
        ? Hive.box(HiveService.syncQueueBox)
        : await Hive.openBox(HiveService.syncQueueBox);
    if (box.isEmpty) return;
    final actions = box.values.toList();
    try {
      final result = await ApiService().pushOfflineActions(actions);
      if (result['success'] == true) await box.clear();
    } catch (_) {
      // Will retry on next reconnect
    }
  }

  // ── Delta Sync ────────────────────────────────────────────────────────────

  /// Pull all data that changed since last sync into Hive offline cache.
  Future<void> pullDelta(String patientId) async {
    final cacheBox = Hive.isBoxOpen(_cacheBox)
        ? Hive.box(_cacheBox)
        : await Hive.openBox(_cacheBox);
    final lastSync = cacheBox.get('last_sync',
        defaultValue: '2020-01-01T00:00:00Z') as String;
    try {
      final data = await ApiService().pullSync(lastSync, patientId);
      if (data['health_records'] != null) {
        await cacheBox.put('health_records', data['health_records']);
      }
      if (data['consultations'] != null) {
        await cacheBox.put('consultations', data['consultations']);
      }
      if (data['pharmacy_stock'] != null) {
        await cacheBox.put('pharmacy_stock', data['pharmacy_stock']);
      }
      if (data['doctors'] != null) {
        await cacheBox.put('doctors', data['doctors']);
      }
      if (data['sync_time'] != null) {
        await cacheBox.put('last_sync', data['sync_time']);
      }
    } catch (_) {
      // Silently fail — cached data stays valid
    }
  }

  // ── Connectivity Watch ────────────────────────────────────────────────────

  /// Call once after login. Listens for reconnect events and auto-syncs.
  void watchConnectivity(String patientId) {
    Connectivity().onConnectivityChanged.listen((results) async {
      final connected = results.any((r) => r != ConnectivityResult.none);
      if (connected) {
        await flushQueue();
        await pullDelta(patientId);
      }
    });
  }

  // ── Cache helpers ─────────────────────────────────────────────────────────

  static Future<dynamic> getCached(String key) async {
    final box = Hive.isBoxOpen(_cacheBox)
        ? Hive.box(_cacheBox)
        : await Hive.openBox(_cacheBox);
    return box.get(key);
  }
}
