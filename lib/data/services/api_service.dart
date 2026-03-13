import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../config/api_config.dart';

/// Singleton Dio HTTP client with automatic JWT injection.
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _storage = const FlutterSecureStorage();
  late final Dio _dio;

  void init() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        // Log errors; screens handle display
        handler.next(error);
      },
    ));
  }

  // ── AUTH ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login(String phone, String password) async {
    final res = await _dio.post(ApiConfig.login,
        data: {'phone_number': phone, 'password': password});
    final data = Map<String, dynamic>.from(res.data);
    if (data['token'] != null) {
      await _storage.write(key: 'jwt_token', value: data['token'] as String);
    }
    return data;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final res = await _dio.post(ApiConfig.register, data: userData);
    final data = Map<String, dynamic>.from(res.data);
    if (data['token'] != null) {
      await _storage.write(key: 'jwt_token', value: data['token'] as String);
    }
    return data;
  }

  Future<String?> getStoredToken() => _storage.read(key: 'jwt_token');

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }

  // ── DOCTORS ──────────────────────────────────────────────────────────────

  Future<List<dynamic>> getDoctors() async {
    final res = await _dio.get(ApiConfig.doctors);
    return List<dynamic>.from(res.data);
  }

  // ── CONSULTATIONS ────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> bookConsultation(Map<String, dynamic> data) async {
    final res = await _dio.post(ApiConfig.consultBook, data: data);
    return Map<String, dynamic>.from(res.data);
  }

  Future<List<dynamic>> getMyConsultations() async {
    final res = await _dio.get(ApiConfig.consultMy);
    return List<dynamic>.from(res.data);
  }

  Future<List<dynamic>> getChatMessages(String consultationId) async {
    final res = await _dio.get(ApiConfig.consultMessages(consultationId));
    return List<dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> uploadChatImage(
      String consultationId, String filePath) async {
    final form = FormData.fromMap({
      'image': await MultipartFile.fromFile(filePath),
    });
    final res = await _dio.post(ApiConfig.consultSendImage(consultationId),
        data: form);
    return Map<String, dynamic>.from(res.data);
  }

  // ── HEALTH RECORDS ───────────────────────────────────────────────────────

  Future<List<dynamic>> getPatientRecords(String patientId) async {
    final res = await _dio.get(ApiConfig.patientRecords(patientId));
    return List<dynamic>.from(res.data);
  }

  // ── PHARMACY ─────────────────────────────────────────────────────────────

  Future<List<dynamic>> getPharmacies() async {
    final res = await _dio.get(ApiConfig.pharmacies);
    return List<dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> getPharmacyStock(String pharmacyId) async {
    final res = await _dio.get(ApiConfig.pharmacyStock(pharmacyId));
    return Map<String, dynamic>.from(res.data);
  }

  Future<List<dynamic>> searchMedicine(String name) async {
    final res = await _dio.get(ApiConfig.searchMedicine,
        queryParameters: {'name': name});
    return List<dynamic>.from(res.data);
  }

  Future<List<dynamic>> getMedicineCatalog() async {
    final res = await _dio.get(ApiConfig.medicineCatalog);
    return List<dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> updatePharmacyStock(List<dynamic> items) async {
    final res = await _dio.post(ApiConfig.updateStock, data: {'items': items});
    return Map<String, dynamic>.from(res.data);
  }

  Future<void> sendHeartbeat() async {
    try {
      await _dio.post(ApiConfig.heartbeat);
    } catch (_) {}
  }

  // ── AI TRIAGE ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> checkSymptoms(
      String patientId, String symptoms, String lang) async {
    final res = await _dio.post(ApiConfig.symptomCheck, data: {
      'patient_id': patientId,
      'symptoms_text': symptoms,
      'language': lang,
    });
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> summarizeForDoctor(
      List<dynamic> chatHistory) async {
    final res = await _dio.post(ApiConfig.summarizeForDoctor,
        data: {'chat_history': chatHistory});
    return Map<String, dynamic>.from(res.data);
  }

  // ── MAP ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getFacilities(
      double lat, double lon, double radius) async {
    final res = await _dio.get(ApiConfig.mapFacilities,
        queryParameters: {'lat': lat, 'lon': lon, 'radius_km': radius});
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> getTileManifest(
      double lat, double lon, double radius) async {
    final res = await _dio.get(ApiConfig.tileManifest,
        queryParameters: {'lat': lat, 'lon': lon, 'radius_km': radius});
    return Map<String, dynamic>.from(res.data);
  }

  // ── SYNC ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> pullSync(
      String lastSync, String patientId) async {
    final res = await _dio.get(ApiConfig.syncPull,
        queryParameters: {'last_sync': lastSync, 'patient_id': patientId});
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> pushOfflineActions(
      List<dynamic> actions) async {
    final res = await _dio
        .post(ApiConfig.syncPush, data: {'actions': actions});
    return Map<String, dynamic>.from(res.data);
  }

  // ── ASHA WORKER ──────────────────────────────────────────────────────────

  Future<List<dynamic>> getManagedPatients() async {
    final res = await _dio.get(ApiConfig.managedPatients);
    return List<dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> addManagedPatient(
      Map<String, dynamic> data) async {
    final res = await _dio.post(ApiConfig.addManagedPatient, data: data);
    return Map<String, dynamic>.from(res.data);
  }
}
