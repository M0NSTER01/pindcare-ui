import 'models/patient_model.dart';
import 'models/consultation_model.dart';
import 'models/prescription_model.dart';
import 'models/ai_scan_model.dart';

class MockData {
  MockData._();

  static PatientModel get currentPatient => PatientModel(
    id: 'PAT-001',
    name: 'Rajinder Singh',
    age: 45,
    gender: 'Male',
    village: 'Nabha',
    district: 'Patiala',
    state: 'Punjab',
    bloodGroup: 'B+',
    emergencyContact: '+91-98765-43210',
    emergencyContactName: 'Gurpreet Kaur',
    lastBp: 130,
    lastTemperature: 98.4,
    lastWeight: 72,
  );

  static List<ConsultationModel> get consultations => [
    ConsultationModel(
      id: 'CON-001',
      doctorName: 'Dr. Amandeep Kaur',
      doctorSpecialization: 'General Physician',
      doctorInitials: 'AK',
      doctorRating: 4.8,
      doctorLanguages: ['Punjabi', 'Hindi', 'English'],
      dateTime: DateTime.now().add(const Duration(hours: 2)),
      type: 'video',
      status: 'upcoming',
      symptoms: 'Persistent cough and fever',
      isOnline: true,
    ),
    ConsultationModel(
      id: 'CON-002',
      doctorName: 'Dr. Rakesh Sharma',
      doctorSpecialization: 'Dermatologist',
      doctorInitials: 'RS',
      doctorRating: 4.6,
      doctorLanguages: ['Hindi', 'English'],
      dateTime: DateTime.now().subtract(const Duration(days: 3)),
      type: 'video',
      status: 'completed',
      symptoms: 'Skin rash on arm',
      isOnline: false,
    ),
    ConsultationModel(
      id: 'CON-003',
      doctorName: 'Dr. Priya Patel',
      doctorSpecialization: 'Pediatrician',
      doctorInitials: 'PP',
      doctorRating: 4.9,
      doctorLanguages: ['Hindi', 'Gujarati', 'English'],
      dateTime: DateTime.now().subtract(const Duration(days: 7)),
      type: 'audio',
      status: 'completed',
      isOnline: true,
    ),
  ];

  static List<ConsultationModel> get upcomingConsultations =>
      consultations.where((c) => c.status == 'upcoming').toList();

  static List<PrescriptionModel> get prescriptions => [
    PrescriptionModel(
      id: 'PRE-001',
      medicineName: 'Paracetamol',
      dosage: '500mg',
      frequency: 'Twice a day',
      duration: '5 days',
      doctorName: 'Dr. Amandeep Kaur',
      prescribedDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
    PrescriptionModel(
      id: 'PRE-002',
      medicineName: 'Cetirizine',
      dosage: '10mg',
      frequency: 'Once a day',
      duration: '7 days',
      doctorName: 'Dr. Rakesh Sharma',
      prescribedDate: DateTime.now().subtract(const Duration(days: 3)),
    ),
    PrescriptionModel(
      id: 'PRE-003',
      medicineName: 'Amoxicillin',
      dosage: '250mg',
      frequency: 'Thrice a day',
      duration: '7 days',
      doctorName: 'Dr. Amandeep Kaur',
      prescribedDate: DateTime.now().subtract(const Duration(days: 1)),
      notes: 'Take after meals',
    ),
  ];

  static List<AiScanModel> get aiScans => [
    AiScanModel(
      id: 'SCAN-001',
      imagePath: '',
      conditionName: 'Fungal Skin Infection',
      conditionType: 'fungal',
      confidence: 0.87,
      severity: 'moderate',
      description:
          'A common fungal infection affecting the outer layers of skin. It appears as a red, scaly rash with defined borders. This type of infection thrives in warm, moist environments.',
      firstAidSteps: [
        'Keep the affected area clean and dry',
        'Apply antifungal cream (clotrimazole) twice daily',
        'Avoid scratching the affected area',
        'Wear loose, breathable clothing',
        'Wash hands after touching the affected area',
      ],
      shouldSeeDoctor: true,
      doctorReasoning:
          'The infection covers a moderate area and may require prescription-strength antifungal medication for complete treatment.',
      scannedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    AiScanModel(
      id: 'SCAN-002',
      imagePath: '',
      conditionName: 'Minor Insect Bite',
      conditionType: 'bite',
      confidence: 0.92,
      severity: 'mild',
      description:
          'A small, localized allergic reaction to an insect bite. The area shows mild redness and swelling typical of common mosquito or ant bites.',
      firstAidSteps: [
        'Clean the area with soap and water',
        'Apply a cold compress to reduce swelling',
        'Use calamine lotion to relieve itching',
        'Avoid scratching to prevent infection',
      ],
      shouldSeeDoctor: false,
      doctorReasoning:
          'This is a minor bite that should heal on its own within a few days with basic first aid.',
      scannedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  static List<Map<String, dynamic>> get pharmacies => [
    {
      'name': 'Jan Aushadhi Kendra',
      'distance': '1.2 km',
      'hours': '8:00 AM - 9:00 PM',
      'isOpen': true,
      'medicines': [
        {'name': 'Paracetamol 500mg', 'status': 'inStock', 'price': '₹15'},
        {'name': 'Cetirizine 10mg', 'status': 'inStock', 'price': '₹12'},
        {'name': 'Amoxicillin 250mg', 'status': 'lowStock', 'price': '₹45'},
      ],
    },
    {
      'name': 'Gupta Medical Store',
      'distance': '2.3 km',
      'hours': '9:00 AM - 10:00 PM',
      'isOpen': true,
      'medicines': [
        {'name': 'Paracetamol 500mg', 'status': 'inStock', 'price': '₹18'},
        {'name': 'Cetirizine 10mg', 'status': 'outOfStock', 'price': '₹15'},
        {'name': 'Amoxicillin 250mg', 'status': 'inStock', 'price': '₹50'},
      ],
    },
    {
      'name': 'Life Care Pharmacy',
      'distance': '3.8 km',
      'hours': '7:00 AM - 11:00 PM',
      'isOpen': true,
      'medicines': [
        {'name': 'Paracetamol 500mg', 'status': 'inStock', 'price': '₹14'},
        {'name': 'Cetirizine 10mg', 'status': 'inStock', 'price': '₹10'},
        {'name': 'Amoxicillin 250mg', 'status': 'inStock', 'price': '₹42'},
      ],
    },
  ];

  static List<Map<String, dynamic>> get availableDoctors => [
    {
      'name': 'Dr. Amandeep Kaur',
      'specialization': 'General Physician',
      'initials': 'AK',
      'rating': 4.8,
      'languages': ['Punjabi', 'Hindi', 'English'],
      'nextSlot': 'Today, 4:00 PM',
      'isOnline': true,
      'consultationFee': '₹200',
    },
    {
      'name': 'Dr. Rakesh Sharma',
      'specialization': 'Dermatologist',
      'initials': 'RS',
      'rating': 4.6,
      'languages': ['Hindi', 'English'],
      'nextSlot': 'Tomorrow, 10:00 AM',
      'isOnline': false,
      'consultationFee': '₹350',
    },
    {
      'name': 'Dr. Priya Patel',
      'specialization': 'Pediatrician',
      'initials': 'PP',
      'rating': 4.9,
      'languages': ['Hindi', 'Gujarati', 'English'],
      'nextSlot': 'Today, 6:00 PM',
      'isOnline': true,
      'consultationFee': '₹250',
    },
    {
      'name': 'Dr. Harjeet Singh',
      'specialization': 'Orthopedic',
      'initials': 'HS',
      'rating': 4.7,
      'languages': ['Punjabi', 'Hindi'],
      'nextSlot': 'Tomorrow, 11:00 AM',
      'isOnline': true,
      'consultationFee': '₹400',
    },
    {
      'name': 'Dr. Nisha Gupta',
      'specialization': 'Gynecologist',
      'initials': 'NG',
      'rating': 4.5,
      'languages': ['Hindi', 'English'],
      'nextSlot': 'Tomorrow, 2:00 PM',
      'isOnline': false,
      'consultationFee': '₹300',
    },
  ];

  // Health records combining all types
  static List<Map<String, dynamic>> get healthRecords {
    final records = <Map<String, dynamic>>[];

    for (final c in consultations) {
      records.add({
        'type': 'consultation',
        'date': c.dateTime,
        'title': 'Consultation with ${c.doctorName}',
        'subtitle': c.doctorSpecialization,
        'syncStatus': c.syncStatus,
        'icon': 'video',
      });
    }

    for (final p in prescriptions) {
      records.add({
        'type': 'prescription',
        'date': p.prescribedDate,
        'title': p.medicineName,
        'subtitle': 'Prescribed by ${p.doctorName}',
        'syncStatus': p.syncStatus,
        'icon': 'medication',
      });
    }

    for (final s in aiScans) {
      records.add({
        'type': 'ai_scan',
        'date': s.scannedAt,
        'title': s.conditionName,
        'subtitle': 'AI Scan • ${(s.confidence * 100).toInt()}% confidence',
        'syncStatus': s.syncStatus,
        'icon': 'scan',
      });
    }

    records.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    return records;
  }
}
