/// Central configuration for all backend endpoints.
/// Replace [baseHost] with your actual server IP/hostname before testing.
class ApiConfig {
  static const String baseHost = 'https://jwzf19cj-3000.inc1.devtunnels.ms';
  static const String baseUrl = '$baseHost/api';
  static const String socketUrl = baseHost;

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';

  // Doctors
  static const String doctors = '/doctors';

  // Consultations
  static const String consultBook = '/consult/book';
  static const String consultMy = '/consult/my';
  static String consultMessages(String id) => '/consult/$id/messages';
  static String consultSendImage(String id) => '/consult/$id/send-image';

  // Health Records
  static String patientRecords(String patientId) => '/records/patient/$patientId';

  // Pharmacy
  static const String pharmacies = '/pharmacy';
  static String pharmacyStock(String id) => '/pharmacy/$id/stock';
  static const String searchMedicine = '/pharmacy/search-medicine';
  static const String medicineCatalog = '/pharmacy/medicines/catalog';
  static const String updateStock = '/pharmacy/update-stock';
  static const String heartbeat = '/pharmacy/heartbeat';

  // AI Triage
  static const String symptomCheck = '/ai/symptom-check';
  static const String summarizeForDoctor = '/ai/summarize-for-doctor';

  // Map
  static const String mapFacilities = '/map/facilities';
  static const String tileManifest = '/map/tile-manifest';

  // Sync
  static const String syncPull = '/sync';
  static const String syncPush = '/sync/push';

  // ASHA
  static const String managedPatients = '/patients/managed';
  static const String addManagedPatient = '/patients/add-managed';
}
