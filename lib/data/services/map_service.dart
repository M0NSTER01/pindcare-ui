import '../models/facility_model.dart';

class MapDataService {
  MapDataService._();
  static final MapDataService instance = MapDataService._();

  // Nabha, Punjab center coordinates
  static const double centerLat = 30.3764;
  static const double centerLng = 76.1436;

  Future<List<FacilityModel>> loadNearbyFacilities() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockFacilities;
  }

  FacilityModel? getNearestFacility(double lat, double lng, String type) {
    final filtered = _mockFacilities.where((f) => f.type == type).toList();
    if (filtered.isEmpty) return null;
    filtered.sort((a, b) {
      final distA = _distance(lat, lng, a.lat, a.lng);
      final distB = _distance(lat, lng, b.lat, b.lng);
      return distA.compareTo(distB);
    });
    return filtered.first;
  }

  double _distance(double lat1, double lng1, double lat2, double lng2) {
    final dLat = lat2 - lat1;
    final dLng = lng2 - lng1;
    return (dLat * dLat + dLng * dLng);
  }

  static final List<FacilityModel> _mockFacilities = [
    FacilityModel(
      id: 'FAC-001', name: 'Nabha Government Hospital', type: 'hospital',
      lat: 30.3785, lng: 76.1420, address: 'Hospital Road, Nabha, Patiala',
      phone: '+91-1765-220100', hours: 'Open 24 Hours', isOpen: true, distance: 0.8,
      doctors: ['Dr. Gurjeet    Singh', 'Dr. Manpreet Kaur', 'Dr. Balwinder Singh'],
    ),
    FacilityModel(
      id: 'FAC-002', name: 'Civil Hospital Nabha', type: 'hospital',
      lat: 30.3740, lng: 76.1480, address: 'Patiala Road, Nabha',
      phone: '+91-1765-220200', hours: 'Open 24 Hours', isOpen: true, distance: 1.2,
      doctors: ['Dr. Amandeep Kaur', 'Dr. Rajinder Pal'],
    ),
    FacilityModel(
      id: 'FAC-003', name: 'PHC Nabha', type: 'clinic',
      lat: 30.3800, lng: 76.1400, address: 'Main Market, Nabha',
      phone: '+91-1765-223300', hours: '8:00 AM - 5:00 PM', isOpen: true, distance: 0.5,
      doctors: ['Dr. Harpreet Singh'],
    ),
    FacilityModel(
      id: 'FAC-004', name: 'Arora Clinic', type: 'clinic',
      lat: 30.3750, lng: 76.1460, address: 'Patiala Road, near Bus Stand, Nabha',
      phone: '+91-98765-11111', hours: '9:00 AM - 8:00 PM', isOpen: true, distance: 1.0,
      doctors: ['Dr. Rakesh Arora'],
    ),
    FacilityModel(
      id: 'FAC-005', name: 'Singh Eye Care', type: 'doctor_clinic',
      lat: 30.3770, lng: 76.1390, address: 'Gurudwara Road, Nabha',
      phone: '+91-98765-22222', hours: '10:00 AM - 6:00 PM', isOpen: true, distance: 0.6,
      doctors: ['Dr. Jaswinder Singh'],
    ),
    FacilityModel(
      id: 'FAC-006', name: 'Jan Aushadhi Kendra', type: 'pharmacy',
      lat: 30.3760, lng: 76.1445, address: 'Main Market, Nabha',
      phone: '+91-1765-224400', hours: '8:00 AM - 9:00 PM', isOpen: true, distance: 0.3,
    ),
    FacilityModel(
      id: 'FAC-007', name: 'Gupta Medical Store', type: 'pharmacy',
      lat: 30.3745, lng: 76.1455, address: 'Patiala Road, Nabha',
      phone: '+91-98765-33333', hours: '9:00 AM - 10:00 PM', isOpen: true, distance: 0.9,
    ),
    FacilityModel(
      id: 'FAC-008', name: 'Life Care Pharmacy', type: 'pharmacy',
      lat: 30.3710, lng: 76.1500, address: 'Railway Road, Nabha',
      phone: '+91-98765-44444', hours: '7:00 AM - 11:00 PM', isOpen: true, distance: 1.8,
    ),
    FacilityModel(
      id: 'FAC-009', name: 'Dr. Priya Patel Clinic', type: 'doctor_clinic',
      lat: 30.3795, lng: 76.1410, address: 'Near Grain Market, Nabha',
      phone: '+91-98765-55555', hours: '10:00 AM - 2:00 PM, 5:00 - 8:00 PM', isOpen: true, distance: 0.7,
      doctors: ['Dr. Priya Patel'],
    ),
    FacilityModel(
      id: 'FAC-010', name: 'Guru Gobind Singh Hospital', type: 'hospital',
      lat: 30.3820, lng: 76.1350, address: 'Amloh Road, Nabha',
      phone: '+91-1765-225500', hours: 'Open 24 Hours', isOpen: true, distance: 2.1,
      doctors: ['Dr. Harjeet Singh', 'Dr. Nisha Gupta', 'Dr. Sukhdev Singh'],
    ),
    FacilityModel(
      id: 'FAC-011', name: 'Kaur Health Centre', type: 'clinic',
      lat: 30.3690, lng: 76.1520, address: 'Sangrur Road, Nabha',
      phone: '+91-98765-66666', hours: '8:30 AM - 7:00 PM', isOpen: true, distance: 2.5,
    ),
    FacilityModel(
      id: 'FAC-012', name: 'Apollo Pharmacy', type: 'pharmacy',
      lat: 30.3775, lng: 76.1430, address: 'Hospital Road, Nabha',
      phone: '+91-98765-77777', hours: 'Open 24 Hours', isOpen: true, distance: 0.4,
    ),
    FacilityModel(
      id: 'FAC-013', name: 'Sharma Dental Clinic', type: 'doctor_clinic',
      lat: 30.3730, lng: 76.1470, address: 'Cinema Road, Nabha',
      phone: '+91-98765-88888', hours: '10:00 AM - 7:00 PM', isOpen: false, distance: 1.3,
      doctors: ['Dr. Rakesh Sharma'],
    ),
    FacilityModel(
      id: 'FAC-014', name: 'Sub District Hospital', type: 'hospital',
      lat: 30.3700, lng: 76.1380, address: 'Samana Road, Nabha',
      phone: '+91-1765-226600', hours: 'Open 24 Hours', isOpen: true, distance: 2.8,
    ),
    FacilityModel(
      id: 'FAC-015', name: 'Sanjivani Medical Store', type: 'pharmacy',
      lat: 30.3755, lng: 76.1415, address: 'Old Court Road, Nabha',
      phone: '+91-98765-99999', hours: '8:00 AM - 10:00 PM', isOpen: true, distance: 0.5,
    ),
  ];
}
