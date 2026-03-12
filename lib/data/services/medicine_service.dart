import '../models/pharmacy_model.dart';

class MedicineService {
  MedicineService._();
  static final MedicineService instance = MedicineService._();

  Future<List<PharmacyModel>> fetchNearbyPharmacies({
    double? lat,
    double? lng,
    double radiusKm = 5.0,
    List<String> filters = const [],
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    var pharmacies = List<PharmacyModel>.from(_mockPharmacies);

    if (filters.contains('openNow')) {
      pharmacies = pharmacies.where((p) => p.isOpen).toList();
    }
    if (filters.contains('24Hours')) {
      pharmacies = pharmacies.where((p) => p.is24Hours).toList();
    }
    if (filters.contains('within2km')) {
      pharmacies = pharmacies.where((p) => p.distance <= 2.0).toList();
    }
    if (filters.contains('within5km')) {
      pharmacies = pharmacies.where((p) => p.distance <= 5.0).toList();
    }
    if (filters.contains('hospital')) {
      pharmacies = pharmacies.where((p) => p.type == 'hospital').toList();
    }
    if (filters.contains('private')) {
      pharmacies = pharmacies.where((p) => p.type == 'private').toList();
    }

    return pharmacies;
  }

  List<PharmacyModel> searchMedicine(String query) {
    if (query.isEmpty) return _mockPharmacies;
    final q = query.toLowerCase();
    return _mockPharmacies.where((p) {
      return p.medicines.any((m) => m.name.toLowerCase().contains(q));
    }).toList();
  }

  List<Map<String, dynamic>> getPharmaciesByMedicine(String medicineName) {
    final results = <Map<String, dynamic>>[];
    final q = medicineName.toLowerCase();
    for (final pharmacy in _mockPharmacies) {
      for (final med in pharmacy.medicines) {
        if (med.name.toLowerCase().contains(q)) {
          results.add({
            'pharmacy': pharmacy,
            'medicine': med,
          });
        }
      }
    }
    return results;
  }

  static final List<String> commonMedicines = [
    'Paracetamol 500mg', 'Amoxicillin 250mg', 'Amoxicillin 500mg',
    'Metformin 500mg', 'Metformin 1000mg', 'Amlodipine 5mg',
    'Atorvastatin 10mg', 'ORS Packets', 'Antacid Gel',
    'Iron Tablets (Ferrous Sulphate)', 'Vitamin D3 60000 IU',
    'Ciprofloxacin 500mg', 'Ibuprofen 400mg', 'Azithromycin 500mg',
    'Insulin (Regular)', 'Salbutamol Inhaler', 'Omeprazole 20mg',
    'Cetirizine 10mg', 'Pantoprazole 40mg', 'Losartan 50mg',
    'Clopidogrel 75mg', 'Ranitidine 150mg', 'Diclofenac 50mg',
    'Doxycycline 100mg', 'Glimepiride 2mg', 'Montelukast 10mg',
    'Calcium + Vitamin D', 'Folic Acid 5mg', 'B-Complex Tablets',
    'Clotrimazole Cream',
  ];

  static List<MedicineStockModel> _randomMedicines(int pharmacyIndex) {
    final stockStatuses = ['inStock', 'inStock', 'inStock', 'lowStock', 'outOfStock'];
    return commonMedicines.map((name) {
      final idx = (name.hashCode + pharmacyIndex) % stockStatuses.length;
      final priceBase = (name.hashCode.abs() % 40) + 8;
      return MedicineStockModel(
        id: 'MED-${pharmacyIndex}-${name.hashCode.abs() % 10000}',
        name: name,
        genericName: name.split(' ').first,
        stockStatus: stockStatuses[idx.abs()],
        price: '₹$priceBase',
      );
    }).toList();
  }

  static final List<PharmacyModel> _mockPharmacies = [
    PharmacyModel(
      id: 'PH-001', name: 'Jan Aushadhi Kendra', type: 'government',
      address: 'Main Market, Nabha', lat: 30.3760, lng: 76.1445,
      phone: '+91-1765-224400', hours: '8:00 AM - 9:00 PM',
      isOpen: true, distance: 0.3, medicines: _randomMedicines(1),
    ),
    PharmacyModel(
      id: 'PH-002', name: 'Gupta Medical Store', type: 'private',
      address: 'Patiala Road, Nabha', lat: 30.3745, lng: 76.1455,
      phone: '+91-98765-33333', hours: '9:00 AM - 10:00 PM',
      isOpen: true, distance: 0.9, medicines: _randomMedicines(2),
    ),
    PharmacyModel(
      id: 'PH-003', name: 'Life Care Pharmacy', type: 'private',
      address: 'Railway Road, Nabha', lat: 30.3710, lng: 76.1500,
      phone: '+91-98765-44444', hours: '7:00 AM - 11:00 PM',
      isOpen: true, distance: 1.8, medicines: _randomMedicines(3),
    ),
    PharmacyModel(
      id: 'PH-004', name: 'Apollo Pharmacy', type: 'private',
      address: 'Hospital Road, Nabha', lat: 30.3775, lng: 76.1430,
      phone: '+91-98765-77777', hours: 'Open 24 Hours',
      isOpen: true, is24Hours: true, distance: 0.4, medicines: _randomMedicines(4),
    ),
    PharmacyModel(
      id: 'PH-005', name: 'Sanjivani Medical Store', type: 'private',
      address: 'Old Court Road, Nabha', lat: 30.3755, lng: 76.1415,
      phone: '+91-98765-99999', hours: '8:00 AM - 10:00 PM',
      isOpen: true, distance: 0.5, medicines: _randomMedicines(5),
    ),
    PharmacyModel(
      id: 'PH-006', name: 'Nabha Hospital Pharmacy', type: 'hospital',
      address: 'Hospital Road, Nabha', lat: 30.3785, lng: 76.1420,
      phone: '+91-1765-220101', hours: 'Open 24 Hours',
      isOpen: true, is24Hours: true, distance: 0.8, medicines: _randomMedicines(6),
    ),
    PharmacyModel(
      id: 'PH-007', name: 'Mehta Chemist', type: 'private',
      address: 'Cinema Road, Nabha', lat: 30.3730, lng: 76.1470,
      phone: '+91-98765-12345', hours: '8:30 AM - 9:30 PM',
      isOpen: true, distance: 1.3, medicines: _randomMedicines(7),
    ),
    PharmacyModel(
      id: 'PH-008', name: 'Wellness Pharmacy', type: 'private',
      address: 'Sangrur Road, Nabha', lat: 30.3690, lng: 76.1520,
      phone: '+91-98765-23456', hours: '9:00 AM - 9:00 PM',
      isOpen: true, distance: 2.5, medicines: _randomMedicines(8),
    ),
    PharmacyModel(
      id: 'PH-009', name: 'Civil Hospital Dispensary', type: 'hospital',
      address: 'Patiala Road, Nabha', lat: 30.3740, lng: 76.1480,
      phone: '+91-1765-220201', hours: '8:00 AM - 4:00 PM',
      isOpen: false, distance: 1.2, medicines: _randomMedicines(9),
    ),
    PharmacyModel(
      id: 'PH-010', name: 'Guru Nanak Medical', type: 'private',
      address: 'Gurudwara Road, Nabha', lat: 30.3770, lng: 76.1390,
      phone: '+91-98765-34567', hours: '8:00 AM - 10:30 PM',
      isOpen: true, distance: 0.6, medicines: _randomMedicines(10),
    ),
    PharmacyModel(
      id: 'PH-011', name: 'Amloh Road Pharmacy', type: 'private',
      address: 'Amloh Road, Nabha', lat: 30.3820, lng: 76.1350,
      phone: '+91-98765-45678', hours: '9:00 AM - 8:00 PM',
      isOpen: true, distance: 2.1, medicines: _randomMedicines(11),
    ),
    PharmacyModel(
      id: 'PH-012', name: 'Dera Pharmacy', type: 'private',
      address: 'Near Bus Stand, Nabha', lat: 30.3735, lng: 76.1460,
      phone: '+91-98765-56789', hours: '7:30 AM - 10:00 PM',
      isOpen: true, distance: 1.1, medicines: _randomMedicines(12),
    ),
    PharmacyModel(
      id: 'PH-013', name: 'PHC Dispensary', type: 'government',
      address: 'Main Market, Nabha', lat: 30.3800, lng: 76.1400,
      phone: '+91-1765-223301', hours: '8:00 AM - 5:00 PM',
      isOpen: true, distance: 0.5, medicines: _randomMedicines(13),
    ),
    PharmacyModel(
      id: 'PH-014', name: 'Gill Medical Store', type: 'private',
      address: 'Station Road, Nabha', lat: 30.3715, lng: 76.1495,
      phone: '+91-98765-67890', hours: '8:00 AM - 9:00 PM',
      isOpen: true, distance: 1.7, medicines: _randomMedicines(14),
    ),
    PharmacyModel(
      id: 'PH-015', name: 'Khalsa Medicos', type: 'private',
      address: 'College Road, Nabha', lat: 30.3805, lng: 76.1370,
      phone: '+91-98765-78901', hours: '9:00 AM - 8:30 PM',
      isOpen: false, distance: 1.5, medicines: _randomMedicines(15),
    ),
  ];
}
